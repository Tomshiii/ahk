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

  premVer: function() {
    return app.version
  },

  saveProj: function () {
    return !!app.project.save();
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

  loadInSourceMonitor: function(itemName: string, folder?: string) {
    const searchFolder: ProjectItem | null = folder
        ? this.searchForBinWithName(folder)
        : app.project.rootItem;

    if (!searchFolder) {
        return false;
    }

    const projItem = this.searchForItemByName(searchFolder, itemName);
    if (!projItem) {
        return false;
    }

    app.sourceMonitor.openProjectItem(projItem);
    return true;
  },

  organiseProj: function() {
    Utils.organiseProject();
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

  movePlayheadFrames: function(subtract: string, frames: string) {
    Utils.movePlayheadFrames(subtract, parseInt(frames));
  },

  moveClip: function (seconds: string) {
    Utils.moveClip(parseInt(seconds));
  },

  isSelected: function () {
    return Utils.isSelected();
  },

  toggleLinearColour: function(enableMaxRenderQual: boolean) {
    return Utils.toggleLinearColour(enableMaxRenderQual);
  },

  toggleEnabled: function() {
    Utils.toggleEnabled();
  },

  isClipEnabled: function() {
    return Utils.isClipEnabled();
  },

  getAudioTracks: function() {
    return Utils.getAudioTracks();
  },

  getVideoTracks: function() {
    return Utils.getVideoTracks();
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
  },

  // @link : https://github.com/Adobe-CEP/Samples/blob/fbc2f2fc090b41a07f07f9fffe2043d9bafb4988/PProPanel/jsx/PPRO/Premiere.jsx#L425
  searchForBinWithName : function(nameToFind: string, inFolder?: ProjectItem) {
    if (!inFolder) {
      var inFolder = app.project.rootItem
    }
		// deep-search a folder by name in project
		var deepSearchBin = function (inFolder) {
			if (inFolder && inFolder.name === nameToFind && inFolder.type === 2) {
				return inFolder;
			} else {
				for (var i = 0; i < inFolder.children.numItems; i++) {
					if (inFolder.children[i] && inFolder.children[i].type === 2) {
						var foundBin = deepSearchBin(inFolder.children[i]);
						if (foundBin) {
							return foundBin;
						}
					}
				}
			}
		};
		return deepSearchBin(inFolder);
	},

  // @link : https://github.com/Adobe-CEP/Samples/blob/fbc2f2fc090b41a07f07f9fffe2043d9bafb4988/PProPanel/jsx/PPRO/Premiere.jsx#L1119
  // @link : https://chatgpt.com/s/t_6924520380ec8191882f7441c64f1251
  searchForItemByName: function(bin: ProjectItem, name: string) {
    for (var i = 0; i < bin.children.numItems; i++) {
        var child = bin.children[i];

        if (!child) continue;

        // Match file
        if (child.type !== ProjectItemType.BIN && child.name === name) {
            return child;
        }

        // Search inside sub-bins
        if (child.type === ProjectItemType.BIN) {
            var found = this.searchForItemByName(child, name);
            if (found) return found;
        }
    }
    return null;
  },

  setMarker: function(colour: string) {
    return MarkerUtils.setMarker(colour);
  },

  applyEffectOnAllSelectedClips: function(effect: string) {
    return EffectUtils.applyEffectOnAllSelectedClips(effect);
  },

  listEffectsOnSelectedClip: function() {
    return EffectUtils.listEffectsOnSelectedClip();
  },

  isPlaying: function() {
    return Utils.isPlaying();
  },

  checkObjParams: function() {
    Utils.checkObjParams();
  },

  checkFuncParams: function(inspectPath: string) {
    Utils.checkFuncParams(inspectPath);
  },

  stopPlayback: function() {
    Utils.stopPlayback();
  },

  // @param {String} [speed=1] set playback speed (1 - normal speed, 2 - double, 1/2 half, -1 - play backwards, etc.)
  startPlayback: function(speed?: string) {
    // this function requires premiere to be focused
    Utils.startPlayback(parseFloat(speed || "1"));
  },

  togglePlayback: function() {
    qe.project.getActiveSequence().multicam.stop();
  },

  isSequence: function() {
    Utils.isSequence();
  },

  moveToAssetsBin: function(folder: string) {
    // This function does not have an incredible amount of logic and is very specifically tailored to my project folder structure.
    // it should be noted this function very specifically looks through both a specific "_Assets" folder AND the "Root" folder - so if you have conflicting bin names, that could be an issue. The "Asset" folder stucture is as follows;
      // root
      // ┗━ [_Assets]
      //   ┗━ [Folder]
    // As the bin name "_Assets" is at the top of sorting, this folder is likely to be checked first in most circumstances
    var selected = app.getCurrentProjectViewSelection()
      if (!selected)
        return
    var project = app.project;
    var projectItem = project.rootItem;

    for (let i = 0; i < projectItem.children.numItems; i++) {
      if (projectItem.children[i].type !== 2)
        continue;
      switch (projectItem.children[i].name) {
        case "_Assets":
          const assetFolder = projectItem.children[i]
          for (let j = 0; j < assetFolder.children.numItems; j++) {
              if (assetFolder.children[j].type !== 2)
                continue;
              if (assetFolder.children[j].name == folder) {
                var moveFolder = assetFolder.children[j];
                break;
              }
            }
          break;
        case folder:
          var moveFolder = projectItem.children[i];
          break;
      }
    }

    if (typeof moveFolder == 'undefined') {
      alert("Desired folder does not seem to exist");
      return false;
    }
    Utils.moveToFolder(selected, moveFolder);
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
