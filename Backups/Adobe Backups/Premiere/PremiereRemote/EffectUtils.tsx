import { Utils } from "./Utils";

export class EffectUtils {

    static changeAudioLevel(clip: TrackItem, levelInDb: number) {
      const levelInfo = clip.components[0].properties[1];
      const level = 20 * Math.log(parseFloat(levelInfo.getValue())) * Math.LOG10E + 15;
      const newLevel = level + levelInDb;
      const encodedLevel = Math.min(Math.pow(10, (newLevel - 15)/20), 1.0);
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
      const clipPos = clipInPoint+(playheadTime-clipStart);

      // check if a keyframe already exists at the playhead
      var checkVal = levelInfo.getValueAtKey(clipPos)
      if(checkVal == 0 || checkVal == null) {
        // if it doesn't, get the current value at the playhead
        // we use getValueAtTime here so that in the even that the playhead
        // is inbetween two keyframes, it will automatically grab the interpolated value
        const checkTimeVal = levelInfo.getValueAtTime(clipPos);
        if(checkTimeVal !== 0 && checkTimeVal !== null) {
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
      const encodedLevel = Math.min(Math.pow(10, (newLevel - 15)/20), 1.0);
      return levelInfo.setValueAtKey(clipPos, encodedLevel, true);
    }

    static changeAllAudioLevels(levelInDb: number) {
      const currentSequence = app.project.activeSequence;
      for (let i = 0; i < currentSequence.audioTracks.numTracks; i++) {
        for (let j = 0; j < currentSequence.audioTracks[i].clips.numItems; j++) {
            const currentClip = currentSequence.audioTracks[i].clips[j];
            if(currentClip.isSelected()) {
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

    static applyEffectOnAllSelectedClips(effectName: String) {
      const activeSequence = app.project.activeSequence;
      const selection = activeSequence.getSelection();

      for (let i = 0; i < selection.length; i++) {
        const selectedClip = selection[i];
        const isVideoClip = selectedClip.mediaType === "Video";

        // Try to get the effect - might need matchName format
        let effect = isVideoClip
          ? qe.project.getVideoEffectByName(effectName)
          : qe.project.getAudioEffectByName(effectName);

        // If not found, try with "AE.ADBE" prefix
        if (!effect) {
          effect = qe.project.getVideoEffectByName("AE.ADBE " + effectName);
        }

        if (!effect) {
          alert("Effect not found: " + effectName);
          return false;
        }

        const trackIndex = this.findTrackIndexForClip(selectedClip, isVideoClip);

        if (trackIndex !== -1) {
          const qeClip = isVideoClip
            ? Utils.getQEVideoClipByStart(trackIndex, selectedClip.start.ticks)
            : Utils.getQEAudioClipByStart(trackIndex, selectedClip.start.ticks);

          if (qeClip) {
            isVideoClip
              ? qeClip.addVideoEffect(effect)
              : qeClip.addAudioEffect(effect);
          }
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

   /*  static applyEffectOnAllVideoClips(effectName: String) {
      const activeSequence = app.project.activeSequence;
      var selection = activeSequence.getSelection();
      var effect = qe.project.getVideoEffectByName(effectName);

      for (let i = 0; i < selection.length; i++) {
        const qeClip = Utils.getQEVideoClipByStart(i, selection[i].start.ticks)
        qeClip.addVideoEffect(effect);
      }

      return true
    } */

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
  }