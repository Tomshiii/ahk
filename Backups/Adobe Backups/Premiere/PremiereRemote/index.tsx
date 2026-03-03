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

  renderPreviews: function() {
    qe.project.getActiveSequence().renderAll();
  },

  sourceMonName: function() {
    const varr = app.sourceMonitor.getProjectItem();
    return varr.name;
  },

  /* loadInSourceMonitor: function(itemName: string, folder?: string) {
    // this method brute searches for the provided folder which may be preferred in some instances
    // but is ultimately far less reliable than providing an exact path
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
  }, */

  loadInSourceMonitor: function(itemPath: string) {
    // itemPath can be just a filename or a full path like "_Assets/Footage/clip.mov"

    // Find the last slash (backslash or forward slash)
    var lastSlashIndex = -1;
    for (var i = itemPath.length - 1; i >= 0; i--) {
      if (itemPath[i] === '\\' || itemPath[i] === '/') {
        lastSlashIndex = i;
        break;
      }
    }

    var folderPath = '';
    var itemName = '';

    if (lastSlashIndex > -1) {
      // Build folderPath from characters before the slash
      for (var i = 0; i < lastSlashIndex; i++) {
        folderPath += itemPath[i];
      }
      // Build itemName from characters after the slash
      for (var i = lastSlashIndex + 1; i < itemPath.length; i++) {
        itemName += itemPath[i];
      }
    } else {
      // No slash found, entire path is the item name
      itemName = itemPath;
    }

    // Find the folder (don't create)
    const searchFolder = folderPath
      ? Utils.findOrCreateFolderPath(app.project.rootItem, folderPath, false)
      : app.project.rootItem;

    if (!searchFolder) {
      alert("Could not find folder: " + folderPath);
      return false;
    }

    const projItem = this.searchForItemByName(searchFolder, itemName);
    if (!projItem) {
      alert("Could not find item '" + itemName + "' in folder");
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

  closeActiveSequence: function(allExcept: boolean) {
    const activeSequence = app.project.activeSequence;

    if (!activeSequence) {
        return;
    }

    const activeID = activeSequence.sequenceID;
    const allSequences = app.project.sequences;
    const numSequences = allSequences.numSequences;

    switch (allExcept == true) {
      case false:
        for (let i = 0; i < numSequences; i++) {
            const seq = allSequences[i];
            if (seq.sequenceID === activeID) {
                seq.close(); // Close the sequence tab
                return;
            }
        }
        break;
      case true:
        for (let i = 0; i < numSequences; i++) {
            const seq = allSequences[i];
            if (seq.sequenceID !== activeID) {
                seq.close(); // Close the sequence tab
                continue;
            }
        }
        break;
    }
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

  startPlayback: function() {
    qe.startPlayback();
  },

  togglePlayback: function() {
    qe.project.getActiveSequence().multicam.stop();
  },

  isSequence: function() {
    Utils.isSequence();
  },

  moveToAssetsBin: function(folderPath: any) {
    // Navigate to or create a folder path in the project panel
    // Examples: `_Sequences`, `_Assets\\01_Other`, `_Assets/Footage/Raw/Day1`
    var selected = app.getCurrentProjectViewSelection();
    if (!selected)
      return;

    var targetFolder = Utils.findOrCreateFolderPath(app.project.rootItem, folderPath, true);

    if (!targetFolder) {
      alert("Could not find or create folder: " + folderPath);
      return false;
    }

    Utils.moveToFolder(selected, targetFolder);
  },

  enableAllVideoTracks: function() {
    Utils.enableAllVideoTracks();
  },

  unmuteAllMutedTracks: function() {
    Utils.unmuteAllMutedTracks();
  },

  getClipTrackIndex: function() {
    return Utils.getClipTrackIndex();
  },

  renderInPrem: function(outputPath: string, presetPath: string) {
    return Utils.renderInPrem(outputPath, presetPath);
  },

  selectionIsSequence: function() {
    return Utils.selectionIsSequence();
  },

  importFile: function(filePath: string, importAsStills: string) {
    app.project.importFiles([filePath], true, app.project.rootItem, Boolean(importAsStills));
  },

  getPref: function(pref: string) {
    return app.properties.getProperty(pref);
  },

  setPref: function(pref: string, value: any, persistent: string, createIfNotExist: string) {
    return app.properties.setProperty(pref, value, Boolean(persistent), Boolean(createIfNotExist));
  },

  closeClipSourceMon: function() {
    app.sourceMonitor.closeClip();
  },

  closeAllClipSourceMon: function() {
    app.sourceMonitor.closeAllClips();
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
