import { Utils } from "./Utils";
import { MarkerUtils } from "./MarkerUtils";
import { EffectUtils } from "./EffectUtils";

/**
 * ALL functions defined here are visible via the localhost service.
 */
export const host = {
  /**
   * @swagger
   *
   * /kill:
   *      get:
   *          description: This method is only there for debugging purposes.
   *                       For more information, please have a look at the index.js file.
   */
  kill: function () { },

  projPath: function () {
    return app.project.path
  },

  projName: function () {
    return app.project.name
  },

  saveProj: function () {
    app.project.save();
  },

  /**
   * @swagger
   * /deselectAll:
   *      get:
   *          description: Deselects all video and audio clips
   */
  deselectAll: function() {
    MarkerUtils.deselectAll();
  },

  /**
   * @swagger
   * /changeAudioLevels?level={level}:
   *      get:
   *          description: Changes the audio level of all selected audio track items.
   *          parameters:
   *              - name: level
   *                description: level change in dB (levels over +15dB are not supported)
   *                in: path
   *                type: number
   */
  changeAudioLevels: function(level: string) {
    EffectUtils.changeAllAudioLevels(parseInt(level));
  },

  setZoomOfCurrentClip: function(zoomLevel: string, xPos: string, yPos: string, anchorX: string, anchorY: string) {
    Utils.setZoomOfCurrentClip(parseFloat(zoomLevel), parseFloat(xPos), parseFloat(yPos), parseFloat(anchorX), parseFloat(anchorY))
  }
};

/**
 * These functions are only used internally.
 */
export const framework = {
  enableQualityEngineering: function () {
    app.enableQE();
  }
};
