import { Utils } from "./Utils";
import { MarkerUtils } from "./MarkerUtils";
import { EffectUtils } from "./EffectUtils";

// JSON genuinely exists at runtime in ExtendScript -- this just tells
// TypeScript about it without pulling in the rest of the ES5 lib
// (which would type-check other ES5 methods that don't actually
// exist in ExtendScript's ES3-based engine).
declare const JSON: {
  stringify(value: any): string;
  parse(text: string): any;
};

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

  applyEffectSlotJSON: function (data: string) {
    var payload;
    try {
      payload = Utils.readAndDecodeText(data);
    } catch (e) {
      return "ERROR at decode/parse: " + e.toString();
    }
    if (!payload) return "ERROR: could not read/parse preset data";

    try {
      app.enableQE();
    } catch (e) {
      return "ERROR at enableQE: " + e.toString();
    }

    var seq, selection;
    try {
      seq = app.project.activeSequence;
      selection = seq.getSelection();
    } catch (e) {
      return "ERROR at getSelection: " + e.toString();
    }
    if (!selection || selection.length === 0) return "ERROR: no clip selected";

    var allResults = [];

    for (var i = 0; i < selection.length; i++) {
      var targetTrackItem = selection[i];

      var bucket = null;
      for (var b = 0; b < payload.length; b++) {
        if (payload[b].mediaType === targetTrackItem.mediaType) {
          bucket = payload[b];
          break;
        }
      }
      if (!bucket) {
        allResults.push("[" + targetTrackItem.mediaType + "]: SKIPPED (no saved effects for this media type)");
        continue;
      }

      var qeTargetClip;
      try {
        qeTargetClip = EffectUtils.findQEClipForTrackItem(targetTrackItem);
      } catch (e) {
        allResults.push("[" + targetTrackItem.mediaType + "] ERROR at findQEClipForTrackItem: " + e.toString());
        continue;
      }
      if (!qeTargetClip) {
        allResults.push("[" + targetTrackItem.mediaType + "] ERROR: could not locate QE clip");
        continue;
      }

      try {
        var results = EffectUtils.applyEffectsToClip(targetTrackItem, qeTargetClip, bucket.effects);
        allResults.push("[" + targetTrackItem.mediaType + "]:\n" + results.join("\n"));
      } catch (e) {
        allResults.push("[" + targetTrackItem.mediaType + "] ERROR at applyEffectsToClip: " + e.toString());
      }
    }

    return "DONE:\n" + allResults.join("\n\n");
  },

  saveEffectSlotJSON: function () {
    try {
      app.enableQE();
      var seq = app.project.activeSequence;
      var selection = seq.getSelection();
      if (!selection || selection.length === 0) return "ERROR: no clip selected";

      var payload = [];
      for (var i = 0; i < selection.length; i++) {
        var trackItem = selection[i];
        payload.push({
          mediaType: trackItem.mediaType, // "Video" or "Audio"
          effects: EffectUtils.copyEffectsFromClip(trackItem)
        });
      }

      return JSON.stringify(payload);
    } catch (e) {
      return "ERROR in saveSelectedClipEffects: " + e.toString();
    }
  },


  projPath: function () {
    return app.project.path
  },

  projName: function () {
    return app.project.name
  },

  premVer: function () {
    return app.version
  },

  premPrefs: function () {
    return app.getPProPrefPath;
  },

  premPrefsPath: function () {
    return app.getAppPrefPath;
  },

  getProperty: function (property: string) {
    if (app.properties.doesPropertyExist(property)) {
      return app.properties.getProperty(property);
    }
    return false;
  },

  getSeqFrameRate: function () {
    const currentSequence = app.project.activeSequence;
    const settings = currentSequence.getSettings();
    const ticksPerFrame = Number(settings.videoFrameRate.ticks);

    const TICKS_PER_SECOND = 254016000000;
    const fps = TICKS_PER_SECOND / ticksPerFrame;

    // Round to 2 decimal places to get clean values like 29.97, 23.98, 59.94
    return Math.round(fps * 100) / 100;
  },

  setProperty: function (property: string, value: any, persistent: string, createIfNotExist: string) {
    if (app.properties.doesPropertyExist(property)) {
      if (app.properties.isPropertyReadOnly(property)) {
        alert('Could not rename property "' + property + '" because it is read-only.');
        return;
      } else {
        app.properties.setProperty(property, value, Boolean(persistent), Boolean(createIfNotExist));
        return;
      }
    }
  },

  saveProj: function () {
    return !!app.project.save();
  },

  getActiveSequenceID: function () {
    return app.project.activeSequence.sequenceID;
  },

  getActiveSequenceName: function () {
    return app.project.activeSequence.name;
  },

  focusSequence: function (ID: string) {
    app.project.openSequence(ID);
  },

  renderPreviews: function () {
    qe.project.getActiveSequence().renderAll();
  },

  sourceMonName: function () {
    const varr = app.sourceMonitor.getProjectItem();
    return varr.name;
  },

  loadInSourceMonitor: function (itemPath: string) {
    // itemPath can be just a filename or a full path like "_Assets/Footage/clip.mov"
    const projItem = Utils.findProjectItemByPath(itemPath);
    if (!projItem) {
      // alert("Could not find item '" + itemName + "' in folder");
      return false;
    }

    app.sourceMonitor.openProjectItem(projItem);
    return true;
  },

  organiseProj: function () {
    Utils.organiseProject();
  },

  clipType: function () {
    var selection = app.project.activeSequence.getSelection();
    const mediaType = selection[0].mediaType
    return mediaType
  },

  /**
   * @swagger
   * /deselectAll:
   *      get:
   *          description: Deselects all video and audio clips
   */
  deselectAll: function () {
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
  changeAudioLevels: function (level: string) {
    return EffectUtils.changeAllAudioLevels(parseFloat(level));
  },

  setZoomOfCurrentClip: function (zoomLevel: string, xPos: string, yPos: string, anchorX: string, anchorY: string) {
    Utils.setZoomOfCurrentClip(parseFloat(zoomLevel), parseFloat(xPos), parseFloat(yPos), parseFloat(anchorX), parseFloat(anchorY));
  },

  setScale: function (scale: string) {
    Utils.setScaleOfCurrentClip(parseFloat(scale));
  },

  getProxyToggle: function () {
    return app.getEnableProxies();
  },

  setProxies: function (toggle: string) {
    app.setEnableProxies(parseInt(toggle));
  },

  setZeroPoint: function (tick: string) {
    app.project.activeSequence.setZeroPoint(tick);
  },

  movePlayhead: function (subtract: string, seconds: string) {
    Utils.movePlayhead(subtract, parseInt(seconds));
  },

  movePlayheadFrames: function (subtract: string, frames: string) {
    Utils.movePlayheadFrames(subtract, parseInt(frames));
  },

  moveClip: function (seconds: string) {
    Utils.moveClip(parseInt(seconds));
  },

  isSelected: function () {
    return Utils.isSelected();
  },

  isSelectedMultiple: function () {
    return Utils.isSelectedMultiple();
  },

  isSelectedAudio: function () {
    return Utils.isSelectedAudio();
  },

  toggleLinearColour: function (enableMaxRenderQual: boolean) {
    return Utils.toggleLinearColour(enableMaxRenderQual);
  },

  toggleEnabled: function () {
    Utils.toggleEnabled();
  },

  isClipEnabled: function () {
    return Utils.isClipEnabled();
  },

  getAudioTracks: function () {
    return Utils.getAudioTracks();
  },

  getVideoTracks: function () {
    return Utils.getVideoTracks();
  },

  closeActiveSequence: function (allExcept: boolean) {
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
  searchForBinWithName: function (nameToFind: string, inFolder?: ProjectItem) {
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
  setMarker: function (colour: string) {
    return MarkerUtils.setMarker(colour);
  },

  removeMarkerAtPlayhead: function () {
    return MarkerUtils.removeMarkerAtPlayhead();
  },

  applyEffectOnAllSelectedClips: function (effectName: string) {
    return EffectUtils.applyEffectOnAllSelectedClips(effectName);
  },

  listEffectsOnSelectedClip: function () {
    return EffectUtils.listEffectsOnSelectedClip();
  },

  isPlaying: function () {
    return Utils.isPlaying();
  },

  checkObjParams: function () {
    Utils.checkObjParams();
  },

  checkFuncParams: function (inspectPath: string) {
    Utils.checkFuncParams(inspectPath);
  },

  startPlayback: function () {
    qe.startPlayback();
  },

  togglePlayback: function () {
    qe.project.getActiveSequence().multicam.stop();
  },

  isSequence: function () {
    Utils.isSequence();
  },

  moveToAssetsBin: function (folderPath: any) {
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

  enableAllVideoTracks: function () {
    Utils.enableAllVideoTracks();
  },

  unmuteAllMutedTracks: function () {
    Utils.unmuteAllMutedTracks();
  },

  getClipTrackIndex: function () {
    return Utils.getClipTrackIndex();
  },

  renderInPrem: function (outputPath: string, presetPath: string) {
    return Utils.renderInPrem(outputPath, presetPath);
  },

  selectionIsSequence: function () {
    return Utils.selectionIsSequence();
  },

  getSelectionBinPath: function () {
    return Utils.getSelectionBinPath();
  },

  importFile: function (filePath: string, importPath: string, importAsStills: string) {
    var targetFolder = app.project.rootItem;
    if (importPath) {
      var folder = Utils.findOrCreateFolderPath(app.project.rootItem, importPath, true);
      if (folder) targetFolder = folder;
    }
    return app.project.importFiles([filePath], false, targetFolder, Boolean(importAsStills));
  },

  closeClipSourceMon: function () {
    app.sourceMonitor.closeClip();
  },

  closeAllClipSourceMon: function () {
    app.sourceMonitor.closeAllClips();
  },

  // this function expects a `|` delimited list of param/value pairs; x-y-z|x2-y-z2 where `x` is the name of the setting in premiere's settings object, `y` is the new value, `z` is either `true`/`false` to determine if the `y` value should be interpreted as a number instead of as a string
  // params/values must be distinguished by `-` and settings must be separated by `|`.
  // ie. videoFrameHeight-2160-true|videoFrameWidth-3840-true|videoFrameRate-29.97-true
  setSeqSettings: function (params: string) {
    // alert(params)
    const currentSequence = app.project.activeSequence;
    var currSettings = currentSequence.getSettings();
    // alert(String(currSettings.videoFrameRate))

    for (const v of params.split("|")) {
      var split = v.split("-")
      // alert(split[0] + split[1])
      if (split[0] == "videoFrameRate") {
        var newFrameRate = new Time();
        newFrameRate.seconds = 1 / Number(split[1])
        currSettings.videoFrameRate = newFrameRate;
        continue
      }
      currSettings[split[0]] = (split[2] == "false") ? split[1] : Number(split[1])
    }
    var setNewVal = currentSequence.setSettings(currSettings);
    if (setNewVal == false)
      return "failure"
  },

  setAllEnableDisabled: function (enabled: string) {
    if (!Utils.isSelected())
      return false

    const activeSequence = app.project.activeSequence;
    const selection = activeSequence.getSelection();
    const shouldDisable = enabled !== "true";
    const len = selection.length;

    for (let i = 0; i < len; i++) {
      selection[i].disabled = shouldDisable;
    }
    return true
  },

  isMainThreadFree: function () {
    try {
      // app.project.documentID is a trivial property read
      // that still requires main thread access
      var id = app.project.documentID;
      return true;
    } catch (e) {
      return false;
    }
  },

  /**
   * Adds `adjustmentLayerPath` to the timeline, sized to exactly cover the
   * currently selected clip(s), on the first video track above the
   * highest selected clip that has enough free space. If none is found,
   * a new track is created above the topmost existing track.
   */
  addMatchedAdjustmentLayer: function (adjustmentLayerPath: string, makeSelection: boolean): void {
    var sequence = app.project.activeSequence;
    if (!sequence) {
      alert('No active sequence.');
      return;
    }

    var projItem = Utils.findProjectItemByPath(adjustmentLayerPath);
    if (!projItem) {
      alert('Could not find adjustment layer at path: ' + adjustmentLayerPath);
      return;
    }

    var selectedVideoClips = Utils.getSelectedVideoClips(sequence);
    if (selectedVideoClips.length === 0) {
      alert('No video clips are selected in the timeline.');
      return;
    }

    // --- Compute overall time range + the highest (topmost) selected track ---
    // Using .ticks (an exact integer, as a string) rather than .seconds, since
    // .seconds is a lossy float for non-integer frame rates (29.97, 23.976,
    // 59.94, etc.) -- round-tripping through it was the cause of occasional
    // 1-frame-short placements.
    var overallStartTicks = Number.MAX_VALUE;
    var overallEndTicks = -Number.MAX_VALUE;
    var highestTrackIndex = -1;

    for (var i = 0; i < selectedVideoClips.length; i++) {
      var entry = selectedVideoClips[i];
      var s = Number(entry.clip.start.ticks);
      var e = Number(entry.clip.end.ticks);
      if (s < overallStartTicks) overallStartTicks = s;
      if (e > overallEndTicks) overallEndTicks = e;
      if (entry.trackIndex > highestTrackIndex) highestTrackIndex = entry.trackIndex;
    }

    var durationTicks = overallEndTicks - overallStartTicks;
    if (durationTicks <= 0) {
      alert('Invalid selection duration.');
      return;
    }

    // --- Find first video track above the highest selected clip with enough free space ---
    var targetTrackIndex = -1;
    var numVideoTracks = sequence.videoTracks.numTracks;

    for (var t = highestTrackIndex + 1; t < numVideoTracks; t++) {
      var candidateTrack = sequence.videoTracks[t];
      if (Utils.isTrackRangeFree(candidateTrack, overallStartTicks, overallEndTicks)) {
        targetTrackIndex = t;
        break;
      }
    }

    if (targetTrackIndex === -1) {
      // There is no track-adding function in the standard ExtendScript DOM at all —
      // confirmed via Adobe community threads. The QE (Quality Engineering) DOM is
      // the only way, via an unsupported/undocumented addTracks method. Its real
      // signature (per community reverse-engineering, not official docs):
      // addTracks(numVideoTracks, afterWhichVideoTrackIndex, numAudioTracks,
      //           audioTrackType, afterWhichAudioTrackIndex, numSubmixTracks, submixTrackType)
      // The "after which" argument is 1-based, so passing numVideoTracks (the topmost
      // existing track's 1-based position) lands the new track above everything else.
      app.enableQE();
      var qeSequence = qe.project.getActiveSequence();
      qeSequence.addTracks(1, numVideoTracks, 0, 0, 0, 0, 0);
      targetTrackIndex = sequence.videoTracks.numTracks - 1;
    }

    var targetTrack = sequence.videoTracks[targetTrackIndex];
    if (!targetTrack) {
      alert('Failed to resolve target track at index ' + targetTrackIndex + '.');
      return;
    }

    // --- Temporarily set the adjustment layer's project-item in/out points ---
    // We do this instead of trimming after insertion because the inserted clip's
    // duration is driven by the project item's current in/out points at insert time.
    var originalInPoint = projItem.getInPoint ? projItem.getInPoint() : null;
    var originalOutPoint = projItem.getOutPoint ? projItem.getOutPoint() : null;

    var zeroTime = new Time();
    zeroTime.ticks = '0';

    var durationTime = new Time();
    durationTime.ticks = String(durationTicks);

    var startTime = new Time();
    startTime.ticks = String(overallStartTicks);

    projItem.setInPoint(zeroTime, 1);
    projItem.setOutPoint(durationTime, 1);

    // overwriteClip (rather than insertClip) is used so nothing on the target
    // track ripples/shifts — we've already confirmed the range is free.
    // Passed as a Time object (ticks-based) rather than a plain seconds number,
    // for the same exact-arithmetic reason as above.
    targetTrack.overwriteClip(projItem, startTime);

    // --- Restore the project item's original in/out points ---
    if (originalInPoint) {
      projItem.setInPoint(originalInPoint, 1);
    } else if (projItem.clearInPoint) {
      projItem.clearInPoint(1);
    }

    if (originalOutPoint) {
      projItem.setOutPoint(originalOutPoint, 1);
    } else if (projItem.clearOutPoint) {
      projItem.clearOutPoint(1);
    }

    // --- Optionally make the newly-placed adjustment layer the selection ---
    if (makeSelection) {
      for (var si = 0; si < selectedVideoClips.length; si++) {
        selectedVideoClips[si].clip.setSelected(0, 0);
      }

      var newClip = null;
      for (var ci = 0; ci < targetTrack.clips.numItems; ci++) {
        if (Number(targetTrack.clips[ci].start.ticks) === overallStartTicks) {
          newClip = targetTrack.clips[ci];
          break;
        }
      }

      if (newClip) {
        newClip.setSelected(1, 1);
      }
    }
  },

  getPlayheadPosTicks: function (): string {
    const currentSequence = app.project.activeSequence;
    return currentSequence.getPlayerPosition().ticks;
  },

  setPlayheadPosTicks: function (ticks: string) {
    const currentSequence = app.project.activeSequence;
    return currentSequence.setPlayerPosition(String(ticks));;
  },

  anchorToPosition: function () {
    // bail if more than one clip selected
    if (this.isSelectedMultiple()) {
      return false;
    }
    // bail if nothing selected
    if (!this.isSelected()) {
      return false;
    }

    var activeSequence = app.project.activeSequence;
    var selection = activeSequence.getSelection();
    var clip = selection[0];

    // find all "Transform" components on the clip
    var transformEffects = [];
    for (var i = 0; i < clip.components.numItems; i++) {
      var component = clip.components[i];
      if (component.displayName === "Transform") {
        transformEffects.push(component);
      }
    }

    // bail if no or more than one Transform effect
    if (transformEffects.length === 0 || transformEffects.length > 1) {
      return false;
    }

    var transform = transformEffects[0];
    var anchorPointProp = null;
    var positionProp = null;

    for (var p = 0; p < transform.properties.numItems; p++) {
      var prop = transform.properties[p];
      if (prop.displayName === "Anchor Point") {
        anchorPointProp = prop;
      } else if (prop.displayName === "Position") {
        positionProp = prop;
      }
    }

    if (!anchorPointProp || !positionProp) {
      return false;
    }

    var anchorValue = anchorPointProp.getValue();
    positionProp.setValue(anchorValue, true);
    return true;
  }
}

/**
 * These functions are only used internally.
 */
export const framework = {
  enableQualityEngineering: function () {
    app.enableQE();
  }
};
