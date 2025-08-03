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

  getActiveSequence: function() {
    return app.project.activeSequence.sequenceID;
  },

  focusSequence: function(ID: string) {
    app.project.openSequence(ID);
  },

  sourceMonName: function() {
    const varr = app.sourceMonitor.getProjectItem();
    return varr.name;
  },

  setBarsAndTone: function() {
    // it should be noted this function very specifically looks for the bars and tone in the specific folder structure that I keep it in, which is;
    // [_Assets]
    //   [Other]
    //     .Bars and Tone - Rec 709
    for (let i = 0; i < app.project.rootItem.children.numItems; i++) {
      if(app.project.rootItem.children[i].name == "_Assets" && (app.project.rootItem.children[i].type == 2)) {
        const folder = app.project.rootItem.children[i]
        for (let i = 0; i < folder.children.numItems; i++) {
          if((folder.children[i].name == "Other" || folder.children[i].name == "01_Other") && (folder.children[i].type == 2)){
            const folder2 = folder.children[i]
            for (let i = 0; i < folder2.children.numItems; i++) {
              if(folder2.children[i].name == "Bars and Tone - Rec 709"){
                app.sourceMonitor.openProjectItem(folder2.children[i]);
                return;
              }
            }
          }
        }
      }
    }
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
    return EffectUtils.changeAllAudioLevels(parseFloat(level));
  },

  setZoomOfCurrentClip: function(zoomLevel: string, xPos: string, yPos: string, anchorX: string, anchorY: string) {
    Utils.setZoomOfCurrentClip(parseFloat(zoomLevel), parseFloat(xPos), parseFloat(yPos), parseFloat(anchorX), parseFloat(anchorY));
  },

  setScale: function(scale: string) {
    Utils.setScaleOfCurrentClip(parseFloat(scale));
  },

  getProxyToggle: function() {
    return app.getEnableProxies();
  },

  setProxies: function(toggle: string) {
    app.setEnableProxies(parseInt(toggle));
  },

  setZeroPoint: function(tick: string) {
    app.project.activeSequence.setZeroPoint(tick);
  },

  movePlayhead: function(subtract: string, seconds: string) {
    Utils.movePlayhead(subtract, parseInt(seconds));
  },

  moveClip: function (seconds: string) {
    Utils.moveClip(parseInt(seconds));
  },

  isSelected: function () {
    return Utils.isSelected();
  },

  toggleLinearColour: function() {
    Utils.toggleLinearColour();
  },

  toggleEnabled: function() {
    Utils.toggleEnabled();
  },

  closeActiveSequence: function() {
    const activeSequence = app.project.activeSequence;

    if (!activeSequence) {
        // alert("No active sequence is open.");
        return;
    }

    const activeID = activeSequence.sequenceID;
    const allSequences = app.project.sequences;
    const numSequences = allSequences.numSequences;

    for (let i = 0; i < numSequences; i++) {
        const seq = allSequences[i];
        if (seq.sequenceID === activeID) {
            const success = seq.close(); // Close the sequence tab
            if (!success) {
                // alert(`Failed to close sequence: ${seq.name}`);
                return;
            }
            return;
        }
    }

    // alert("Active sequence not found in project.sequences list.");
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
