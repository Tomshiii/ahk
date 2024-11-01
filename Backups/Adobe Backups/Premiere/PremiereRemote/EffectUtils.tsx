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
      if (!levelInfo.isTimeVarying()) {
        levelInfo.setTimeVarying(true);
      }

      const currSeq = app.project.activeSequence
      const playheadTime = currSeq.getPlayerPosition().seconds;
      const clipInPoint = clip.inPoint.seconds;
      const clipStart = clip.start.seconds;
      const clipPos = clipInPoint+(playheadTime-clipStart);

      // doing the math like the original `changeAudioLevel` function runs into some rather annoying logical issues
      // if you want to "remove" or "add" a value from a keyframe... which nearby keyframe do you pick?
      // going strictly off the playhead position would get annoying if you're inbetween two other keyframes etc
      // makes more sense to just SET the value to the input number instead of adjust it by the desired amount
      // but if for some reason I ever want to try it again - `.getValue()` is for non keyframed values you'd need
      // `.getValueAt-`

      // const level = 20 * Math.log(parseFloat(levelInfo.getValue())) * Math.LOG10E + 15;
      const newLevel = levelInDb;
      const encodedLevel = Math.min(Math.pow(10, (newLevel - 15)/20), 1.0);

      levelInfo.addKey(clipPos);
      levelInfo.setValueAtKey(clipPos, encodedLevel, true);
    }

    static changeAllAudioLevels(levelInDb: number) {
      const currentSequence = app.project.activeSequence;
      for (let i = 0; i < currentSequence.audioTracks.numTracks; i++) {
        for (let j = 0; j < currentSequence.audioTracks[i].clips.numItems; j++) {
            const currentClip = currentSequence.audioTracks[i].clips[j];
            if(currentClip.isSelected()) {
            //  this.changeAudioLevel(currentClip, levelInDb);
             this.changeKeyframeLevel(currentClip, levelInDb);
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

  }