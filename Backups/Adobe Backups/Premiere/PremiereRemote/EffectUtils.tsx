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