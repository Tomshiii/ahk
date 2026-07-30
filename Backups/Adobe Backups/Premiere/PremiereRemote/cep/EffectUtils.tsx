import { Utils } from "./Utils";

export interface EffectEntry {
    matchName: string;
    displayName: string;
    properties: PropertyEntry[];
    anchorInPoint?: string;
    anchorOutPoint?: string;
}
interface PropertyEntry {
    displayName: string;
    isTimeVarying: boolean;
    value?: any;
    keyframes?: { time: string; value: any }[];
}
var SKIPPED_MATCH_NAMES: { [key: string]: boolean } = {
    "AE.ADBE Motion": true,
    "AE.ADBE Opacity": true,
    "Internal Volume Stereo": true,
    "Internal Channel Volume Stereo": true,
    "Internal Volume Mono": true
};

export class EffectUtils {

    static changeAudioLevel(clip: TrackItem, levelInDb: number) {
        const levelInfo = clip.components[0].properties[1];
        const level = 20 * Math.log(parseFloat(levelInfo.getValue())) * Math.LOG10E + 15;
        const newLevel = level + levelInDb;
        const encodedLevel = Math.min(Math.pow(10, (newLevel - 15) / 20), 1.0);
        levelInfo.setValue(encodedLevel, true);
    }

    static changeKeyframeLevel(clip: TrackItem, levelInDb: number) {
        const levelInfo = clip.components[0].properties[1];
        const isTimeVarying = levelInfo.isTimeVarying();
        if (isTimeVarying == 0) {
            levelInfo.setTimeVarying(true);
            clip.setSelected(false, true);
            clip.setSelected(true, true);
        }

        const currSeq = app.project.activeSequence
        const playheadTime = currSeq.getPlayerPosition().seconds;
        const clipInPoint = clip.inPoint.seconds;
        const clipStart = clip.start.seconds;
        const clipPos = clipInPoint + (playheadTime - clipStart);

        // check if a keyframe already exists at the playhead
        var checkVal = levelInfo.getValueAtKey(clipPos)
        if (checkVal == 0 || checkVal == null) {
            // if it doesn't, get the current value at the playhead
            // we use getValueAtTime here so that in the even that the playhead
            // is inbetween two keyframes, it will automatically grab the interpolated value
            const checkTimeVal = levelInfo.getValueAtTime(clipPos);
            if (checkTimeVal !== 0 && checkTimeVal !== null) {
                // then we add a keyframe and set it to the previously checked value
                // we do this because for whatever reason, simply adding a keyframe
                // will result in a messed up value. I was seeing like -800+ or -infinity
                levelInfo.addKey(clipPos);
                levelInfo.setValueAtKey(clipPos, checkTimeVal, true); // this line specifically technically isn't needed but good as a safety
                checkVal = checkTimeVal
            }
        }
        const level = 20 * Math.log(parseFloat(checkVal)) * Math.LOG10E + 15;
        const newLevel = level + levelInDb;
        const encodedLevel = Math.min(Math.pow(10, (newLevel - 15) / 20), 1.0);
        return levelInfo.setValueAtKey(clipPos, encodedLevel, true);
    }

    static changeAllAudioLevels(levelInDb: number) {
        const currentSequence = app.project.activeSequence;
        for (let i = 0; i < currentSequence.audioTracks.numTracks; i++) {
            for (let j = 0; j < currentSequence.audioTracks[i].clips.numItems; j++) {
                const currentClip = currentSequence.audioTracks[i].clips[j];
                if (currentClip.isSelected()) {
                    //  this.changeAudioLevel(currentClip, levelInDb);
                    return this.changeKeyframeLevel(currentClip, levelInDb);
                }
            }
        }
    }

    static applyEffectOnFirstSelectedVideoClip(effectName: String) {
        const clipInfo = Utils.getFirstSelectedClip(true)
        const qeClip = Utils.getQEVideoClipByStart(clipInfo.trackIndex, clipInfo.clip.start.ticks)
        var effect = qe.project.getVideoEffectByName(effectName);
        qeClip.addVideoEffect(effect);

        // For better usability, always return the newest effects (this ones) properties!
        return clipInfo.clip.components[2].properties;
    }

    static _videoEffectCache: any = null;

    static resolveVideoEffect(effectName: string) {
        if (!this._videoEffectCache) {
            this._videoEffectCache = {};
            const list = qe.project.getVideoEffectList();
            for (let i = 0; i < list.length; i++) {
                if (typeof list[i] === "string") {
                    this._videoEffectCache[list[i].toLowerCase()] = list[i];
                }
            }
        }

        const target = effectName.toLowerCase();

        // 1) display-name match (normal case)
        if (this._videoEffectCache[target]) {
            const effect = qe.project.getVideoEffectByName(this._videoEffectCache[target], false);
            if (effect) return effect;
        }

        // 2) matchName-mode fallback — try fully-qualified forms FIRST,
        //    raw effectName LAST, since an unqualified matchName can
        //    return an incorrect/garbled match instead of null
        const matchNameCandidates = [
            `AE.ADBE ${effectName}`,
            `PR.ADBE ${effectName}`,
            effectName,
        ];

        for (let i = 0; i < matchNameCandidates.length; i++) {
            try {
                const effect = qe.project.getVideoEffectByName(matchNameCandidates[i], true);
                if (effect) return effect;
            } catch (e) {
                // ignore and try next candidate
            }
        }

        // 3) fuzzy substring fallback on display names
        const candidates = [];
        for (const key in this._videoEffectCache) {
            if (key.indexOf(target) === -1) continue;
            if (key.indexOf("legacy") !== -1 || key.indexOf("obsolete") !== -1 || key.indexOf(" obs") !== -1) continue;
            candidates.push(this._videoEffectCache[key]);
        }
        for (let i = 0; i < candidates.length; i++) {
            const effect = qe.project.getVideoEffectByName(candidates[i], false);
            if (effect) return effect;
        }

        return null;
    }

    static applyEffectOnAllSelectedClips(effectName: string) {
        const activeSequence = app.project.activeSequence;
        const selection = activeSequence.getSelection();

        for (let i = 0; i < selection.length; i++) {
            const selectedClip = selection[i];
            const isVideoClip = selectedClip.mediaType === "Video";

            const effect = isVideoClip
                ? this.resolveVideoEffect(effectName)
                : qe.project.getAudioEffectByName(effectName);

            if (!effect) {
                alert("Effect not found: " + effectName);
                return false;
            }

            const trackIndex = this.findTrackIndexForClip(selectedClip, isVideoClip);
            if (trackIndex === -1) continue;

            const qeClip = isVideoClip
                ? Utils.getQEVideoClipByStart(trackIndex, selectedClip.start.ticks)
                : Utils.getQEAudioClipByStart(trackIndex, selectedClip.start.ticks);

            if (!qeClip) continue;

            const beforeCount = selectedClip.components.numItems;

            isVideoClip
                ? qeClip.addVideoEffect(effect)
                : qeClip.addAudioEffect(effect);

            // refresh BEFORE checking — app-side component list is stale until this happens
            selectedClip.setSelected(false, true);
            selectedClip.setSelected(true, true);

            const afterCount = selectedClip.components.numItems;
            if (afterCount <= beforeCount) {
                alert("Effect lookup succeeded but nothing was actually added for: " + effectName);
                continue;
            }

            switch (effectName) {
                case "Transform":
                    const transformProps = selectedClip.components[2].properties;
                    const uniform = transformProps[2];

                    uniform.setValue(true, true);
                    if (selection.length == 1) {
                        selectedClip.setSelected(false, true);
                        selectedClip.setSelected(true, true);
                    }
                    break;
            }
        }

        return true;
    }

    static findTrackIndexForClip(targetClip: any, isVideo: Boolean) {
        const currentSequence = app.project.activeSequence;
        const tracks = isVideo ? currentSequence.videoTracks : currentSequence.audioTracks;

        for (let i = 0; i < tracks.numTracks; i++) {
            for (let j = 0; j < tracks[i].clips.numItems; j++) {
                const currentClip = tracks[i].clips[j];

                // Match by start time and nodeId (or other unique identifier)
                if (currentClip.start.ticks === targetClip.start.ticks &&
                    currentClip.nodeId === targetClip.nodeId) {
                    return i;
                }
            }
        }

        return -1; // Not found
    }

    static applyDropShadowPreset() {
        const shadowEffectProperties = this.applyEffectOnFirstSelectedVideoClip("Schlagschatten");
        const opacity = shadowEffectProperties[1];
        const softness = shadowEffectProperties[4];

        opacity.setValue(255, true);
        softness.setValue(44, true);
    }

    static applyBlurPreset() {
        const blurEffectProperties = this.applyEffectOnFirstSelectedVideoClip("Gaußscher Weichzeichner");

        const blurriness = blurEffectProperties[0];
        const repeatBorderPixels = blurEffectProperties[2];

        blurriness.setValue(42, true);
        repeatBorderPixels.setValue(true, true);
    }

    static applyWarpStabilizer() {
        this.applyEffectOnFirstSelectedVideoClip("Verkrümmungsstabilisierung");
    }

    static listEffectsOnSelectedClip() {
        const clipInfo = Utils.getFirstSelectedClip(true);
        if (!clipInfo) {
            alert("No clip selected");
            return;
        }

        const clip = clipInfo.clip;
        let effectsList = "Effects on clip:\n";

        // Iterate through components (effects are typically in components)
        for (let i = 0; i < clip.components.numItems; i++) {
            const component = clip.components[i];
            effectsList += i + ": " + component.displayName + " (matchName: " + component.matchName + ")\n";
        }

        alert(effectsList);
    }

    static findQEClipForTrackItem(trackItem: any) {
        app.enableQE();

        var trackIndex = this.getTrackIndexForTrackItem(trackItem);
        if (trackIndex === -1) {
            alert("getTrackIndexForTrackItem returned -1 for mediaType=" + trackItem.mediaType + ", nodeId=" + trackItem.nodeId);
            return null;
        }

        var qeSeq = qe.project.getActiveSequence();
        var qeTrack = (trackItem.mediaType === "Video")
            ? qeSeq.getVideoTrackAt(trackIndex)
            : qeSeq.getAudioTrackAt(trackIndex);

        var targetTicks = Number(trackItem.start.ticks);
        var maxProbe = 5000;
        var scanned = [];

        for (var i = 0; i < maxProbe; i++) {
            var qeItem;
            try {
                qeItem = qeTrack.getItemAt(i);
            } catch (e) {
                break;
            }
            if (!qeItem) break;

            try {
                scanned.push(Number(qeItem.start.ticks));
                if (Number(qeItem.start.ticks) === targetTicks) {
                    return qeItem;
                }
            } catch (e) {
                // gap
            }
        }

        return null;
    }

    static getTrackIndexForTrackItem(trackItem: any) {
        var seq = app.project.activeSequence;
        var tracks = (trackItem.mediaType === "Video") ? seq.videoTracks : seq.audioTracks;

        for (var t = 0; t < tracks.numTracks; t++) {
            var track = tracks[t];
            for (var c = 0; c < track.clips.numItems; c++) {
                if (track.clips[c].nodeId === trackItem.nodeId) {
                    return t;
                }
            }
        }
        return -1;
    }

    static applyEffectsToClip(targetTrackItem: any, qeTargetClip: any, effectData: EffectEntry[]) {
        var results: string[] = [];
        var TICKS_PER_SECOND = 254016000000;

        for (var e = 0; e < effectData.length; e++) {
            var fx = effectData[e];

            var isSkipped = false;
            try {
                isSkipped = !!SKIPPED_MATCH_NAMES[fx.matchName];
            } catch (skipErr) {
                results.push(fx.matchName + ": SKIPPED_MATCH_NAMES check FAILED -- " + skipErr.toString());
            }
            if (isSkipped) {
                results.push(fx.matchName + ": SKIPPED (excluded by design)");
                continue;
            }

            try {
                var isAudio = targetTrackItem.mediaType === "Audio";
                var qeEffect = null;

                try {
                    qeEffect = isAudio
                        ? qe.project.getAudioEffectByName(fx.displayName || fx.matchName)
                        : qe.project.getVideoEffectByName(fx.matchName, true);
                } catch (lookupErr) {
                    results.push(fx.matchName + ": FAILED at getEffectByName -- " + lookupErr.toString());
                    continue;
                }

                if (!qeEffect) {
                    results.push(fx.matchName + ": SKIPPED (effect lookup returned nothing)");
                    continue;
                }

                // Snapshot existing component count BEFORE adding, so we can
                // reliably identify which one is the new instance afterward --
                // don't assume it lands at the end or any particular index.
                var beforeCount = targetTrackItem.components.numItems;

                try {
                    if (isAudio) {
                        qeTargetClip.addAudioEffect(qeEffect);
                    } else {
                        qeTargetClip.addVideoEffect(qeEffect);
                    }
                } catch (addErr) {
                    results.push(fx.matchName + ": FAILED at addEffect -- " + addErr.toString());
                    continue;
                }

                var afterCount = targetTrackItem.components.numItems;
                if (afterCount <= beforeCount) {
                    results.push(fx.matchName + ": FAILED (added via QE but component count didn't increase)");
                    continue;
                }

                // Find the new component: the one with this matchName that
                // wasn't present in the pre-add snapshot. Since matchName isn't
                // unique when duplicates exist, compare by identity/index diff
                // instead of by matchName lookup.
                var targetComp = null;
                if (afterCount === beforeCount + 1) {
                    for (var c = afterCount - 1; c >= 0; c--) {
                        if (targetTrackItem.components[c].matchName === fx.matchName) {
                            targetComp = targetTrackItem.components[c];
                            break;
                        }
                    }
                }

                if (!targetComp) {
                    results.push(fx.matchName + ": FAILED (added via QE but could not identify new component afterward)");
                    continue;
                }

                for (var j = 0; j < fx.properties.length && j < targetComp.properties.numItems; j++) {
                    var savedProp = fx.properties[j];
                    var liveProp = targetComp.properties[j];
                    try {
                        if (savedProp.isTimeVarying && savedProp.keyframes) {
                            if (!liveProp.isTimeVarying()) liveProp.setTimeVarying(true);
                            results.push(fx.matchName + "." + savedProp.displayName + ": isTimeVarying after set = " + liveProp.isTimeVarying());

                            var hasAnchors = fx.anchorInPoint !== undefined && fx.anchorOutPoint !== undefined;
                            var anchorIn, originalSpan, scaleRatio;

                            if (hasAnchors) {
                                anchorIn = Number(fx.anchorInPoint);
                                var anchorOut = Number(fx.anchorOutPoint);
                                originalSpan = anchorOut - anchorIn;
                                var clipDurationTicks = Number(targetTrackItem.duration.ticks);
                                scaleRatio = originalSpan > 0 ? (clipDurationTicks / originalSpan) : 1;
                            }

                            for (var k = 0; k < savedProp.keyframes.length; k++) {
                                var kf = savedProp.keyframes[k];
                                var t = new Time();

                                if (hasAnchors) {
                                    var relativeOffsetTicks = Number(kf.time) - anchorIn;
                                    var scaledOffsetTicks = relativeOffsetTicks * scaleRatio;
                                    t.seconds = scaledOffsetTicks / TICKS_PER_SECOND;
                                } else {
                                    t.seconds = Number(kf.time) / TICKS_PER_SECOND;
                                }

                                var addResult = liveProp.addKey(t);
                                var setResult = liveProp.setValueAtKey(t, kf.value, true);
                                results.push(fx.matchName + "." + savedProp.displayName + " kf" + k + ": t.seconds=" + t.seconds + " addKey=" + addResult + " setValueAtKey=" + setResult);
                            }
                        } else if (savedProp.value !== undefined) {
                            liveProp.setValue(savedProp.value, true);
                        }
                    } catch (propErr) {
                        results.push(fx.matchName + "." + savedProp.displayName + ": property error -- " + propErr.toString());
                    }
                }

                results.push(fx.matchName + ": OK");
            } catch (fxErr) {
                results.push((fx ? fx.matchName : "?") + ": FAILED -- " + fxErr.toString());
            }
        }

        return results;
    }

    static copyEffectsFromClip(sourceTrackItem: any) {
        var effects: EffectEntry[] = [];

        for (var i = 0; i < sourceTrackItem.components.numItems; i++) {
            var comp = sourceTrackItem.components[i];
            if (!comp.properties) {
                alert("comp[" + i + "] (" + comp.matchName + ") has no properties collection at all");
                continue;
            }

            if (!comp) {
                alert("component[" + i + "] is null/undefined, skipping");
                continue;
            }

            if (SKIPPED_MATCH_NAMES[comp.matchName]) continue;

            var props: PropertyEntry[] = [];

            for (var j = 0; j < comp.properties.numItems; j++) {
                var p = comp.properties[j];

                if (!p) {
                    alert("comp[" + i + "] (" + comp.matchName + ") property[" + j + "] is null/undefined, skipping");
                    continue;
                }

                try {
                    var entry: PropertyEntry = {
                        displayName: p.displayName,
                        isTimeVarying: p.isTimeVarying()
                    };

                    if (entry.isTimeVarying) {
                        var keys = p.getKeys();
                        entry.keyframes = [];
                        if (keys) {
                            for (var k = 0; k < keys.length; k++) {
                                var key = keys[k];
                                if (!key) continue;
                                entry.keyframes.push({ time: key.ticks, value: p.getValueAtKey(key) });
                            }
                        }
                    } else {
                        entry.value = p.getValue();
                    }
                    props.push(entry);
                } catch (propErr) {
                    alert("comp[" + i + "] (" + comp.matchName + ") property[" + j + "] (" + p.displayName + ") threw: " + propErr.toString());
                }
            }

            effects.push({ matchName: comp.matchName, displayName: comp.displayName, properties: props });
        }
        return effects;
    }
}