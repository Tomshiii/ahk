import { EffectEntry } from "./EffectUtils"; // adjust path/filename to wherever EffectEntry actually lives
interface XmlRecord { tag: string; content: string; }
declare const JSON: {
  stringify(value: any): string;
  parse(text: string): any;
};

export class Utils {
  static ticksPerSecond = 254016000000;

  static getFirstSelectedClip(videoClip: Boolean) {
    const currentSequence = app.project.activeSequence;
    const tracks = videoClip ? currentSequence.videoTracks : currentSequence.audioTracks;
    for (let i = 0; i < tracks.numTracks; i++) {
      for (let j = 0; j < tracks[i].clips.numItems; j++) {
        const currentClip = tracks[i].clips[j];
        if (currentClip.isSelected()) {
          return {
            clip: currentClip,
            trackIndex: i,
            clipIndex: j
          }
        }
      }
    }
    return null;
  }

  static isSelected() {
    var activeSequence = app.project.activeSequence;
    var selection = activeSequence.getSelection();

    if (!selection.length) {
      return false;
    }
    return true;
  }

  static isSelectedMultiple() {
    var activeSequence = app.project.activeSequence;
    var selection = activeSequence.getSelection();

    if (!selection.length || selection.length <= 1) {
      return false;
    }
    return true;
  }

  static isClipEnabled() {
    var activeSequence = app.project.activeSequence;
    var selection = activeSequence.getSelection();

    if (selection[0].disabled == false)
      return true;
    return false;

  }

  static toggleEnabled() {
    const activeSequence = app.project.activeSequence;
    const selection = activeSequence.getSelection();
    const len = selection.length

    for (let i = 0; i < len; i++) {
      selection[i].disabled = !selection[i].disabled;
    }
  }

  static getClipTrackIndex() {
    var sequence = app.project.activeSequence;
    if (!sequence)
      return false;

    var selection = sequence.getSelection();
    if (selection.length <= 0)
      return false;
    var clip = selection[0];

    return clip.parentTrackIndex;
  }

  static movePlayheadFrames(subtract: string, frames: number) {
    const currentSequence = app.project.activeSequence;
    const timebase = parseInt(currentSequence.timebase)
    if (subtract == "false") {
      var newPlayhead = parseInt(currentSequence.getPlayerPosition().ticks) + (timebase * frames);
    } else {
      var newPlayhead = parseInt(currentSequence.getPlayerPosition().ticks) - (timebase * frames);
    }
    currentSequence.setPlayerPosition(String(newPlayhead));
  }

  static movePlayhead(subtract: string, seconds: number) {
    const currentSequence = app.project.activeSequence;
    if (subtract == "false") {
      var newPlayhead = parseInt(currentSequence.getPlayerPosition().ticks) + (this.ticksPerSecond * seconds);
    } else {
      var newPlayhead = parseInt(currentSequence.getPlayerPosition().ticks) - (this.ticksPerSecond * seconds);
    }
    currentSequence.setPlayerPosition(String(newPlayhead));
  }

  static toggleLinearColour(enableMaxRenderQual: boolean) {
    const currentSequence = app.project.activeSequence;
    var currSettings = currentSequence.getSettings();
    currSettings.compositeLinearColor = !currSettings.compositeLinearColor;
    if (currSettings.compositeLinearColor == true && enableMaxRenderQual == true) {
      currSettings.maximumRenderQuality = true
    }
    var setNewVal = currentSequence.setSettings(currSettings);
    if (setNewVal == false)
      return "failure"
    return currSettings.compositeLinearColor
  }

  static moveClip(seconds: number) {
    const currentSequence = app.project.activeSequence;
    const selection = currentSequence.getSelection();

    for (let i = 0; i < selection.length; i++) {
      selection[i].move(seconds);
    }
  }

  static getVideoClip(trackIndex: number, clipIndex: number) {
    const currentSequence = app.project.activeSequence;
    return currentSequence.videoTracks[trackIndex].clips[clipIndex];
  }

  static setZoomOfCurrentClip(zoomLevel: number, xPos?: number, yPos?: number, anchorX?: number, anchorY?: number) {
    const clipInfo = Utils.getFirstSelectedClip(true)
    const scaleInfo = clipInfo.clip.components[1].properties[1];
    const currentSequence = app.project.activeSequence;
    const frameSizeHorizontal = currentSequence.frameSizeHorizontal
    const frameSizeVertical = currentSequence.frameSizeVertical
    // set zoom level
    scaleInfo.setValue(zoomLevel, true);
    // set x/y pos
    if (typeof xPos !== 'undefined' && typeof yPos !== 'undefined') {
      clipInfo.clip.components[1].properties[0].setValue([xPos / frameSizeHorizontal, yPos / frameSizeVertical], true);
    }
    // set anchor points
    if (typeof anchorX !== 'undefined' && typeof anchorY !== 'undefined') {
      clipInfo.clip.components[1].properties[5].setValue([anchorX / frameSizeHorizontal, anchorY / frameSizeVertical], true);
    }
  }

  static setScaleOfCurrentClip(zoomLevel: number) {
    const clipInfo = Utils.getFirstSelectedClip(true)
    const scaleInfo = clipInfo.clip.components[1].properties[1];
    // set zoom level
    scaleInfo.setValue(zoomLevel, true);
  }

  static zoomToFit(videoClip) {
    if (videoClip != null) {
      const clipSize = this.getClipSize(videoClip.clip);
      const frameHeight = app.project.activeSequence.frameSizeVertical;
      const frameWidth = app.project.activeSequence.frameSizeHorizontal;

      const verticalFactor = frameHeight / clipSize.height;
      const horizontalFactor = frameWidth / clipSize.width;

      const zoomLevel = Math.max(verticalFactor, horizontalFactor) * 100;

      Utils.setZoomOfCurrentClip(zoomLevel);
    }
  }

  static getClipSize(videoClip: TrackItem) {
    const projectItem = videoClip.projectItem;
    const videoInfo = Utils.getProjectMetadata(projectItem,
      ["Column.Intrinsic.VideoInfo"])[0][0].toString();

    const width = parseInt(videoInfo.split(' ')[0]);
    const height = parseInt(videoInfo.split(' ')[2]);
    return { "height": height, "width": width }
  }

  static getQEVideoClipByStart(trackIndex: number, startInTicks: string) {
    const currentSequence = qe.project.getActiveSequence();
    const videoTrack = currentSequence.getVideoTrackAt(trackIndex);

    for (let i = 0; i < videoTrack.numItems; i++) {
      const clip = videoTrack.getItemAt(i);

      if (clip.start.ticks === startInTicks) {
        return clip;
      }

    }
  }

  static getQEAudioClipByStart(trackIndex: number, startInTicks: string) {
    const currentSequence = qe.project.getActiveSequence();
    const audioTrack = currentSequence.getAudioTrackAt(trackIndex);

    for (let i = 0; i < audioTrack.numItems; i++) {
      const clip = audioTrack.getItemAt(i);

      if (clip.start.ticks === startInTicks) {
        return clip;
      }
    }

    return null;
  }

  static targetAllTracks(target: boolean) {
    const currentSequence = app.project.activeSequence;
    for (let i = 0; i < currentSequence.videoTracks.numTracks; i++) {
      currentSequence.videoTracks[i].setTargeted(target, true)
    }
    for (let i = 0; i < currentSequence.audioTracks.numTracks; i++) {
      currentSequence.audioTracks[i].setTargeted(target, true)
    }
  }

  static targetDefaultTracks() {
    const currentSequence = app.project.activeSequence;
    this.targetAllTracks(false);
    for (let i = 0; i < Math.min(3, currentSequence.videoTracks.numTracks); i++) {
      currentSequence.videoTracks[i].setTargeted(true, true);
    }
    if (currentSequence.audioTracks.numTracks > 0) {
      currentSequence.audioTracks[0].setTargeted(true, true);
    }
  }

  static targetTracks(videoTrack: number, audioTrack: number) {
    this.targetAllTracks(false);

    const currentSequence = app.project.activeSequence;

    if (currentSequence.videoTracks.numTracks > videoTrack) {
      currentSequence.videoTracks[videoTrack].setTargeted(true, true);
    }
    if (currentSequence.audioTracks.numTracks > audioTrack) {
      currentSequence.audioTracks[audioTrack].setTargeted(true, true);
    }
  }

  static fixPlayHeadPosition(): void {
    const currentSequence = app.project.activeSequence;
    const currentPlayheadPosition = currentSequence.getPlayerPosition().ticks;
    const ticksPerFrame = currentSequence.getSettings().videoFrameRate.ticks;
    const newPos = Math.ceil(parseInt(currentPlayheadPosition) / parseInt(ticksPerFrame));

    currentSequence.setPlayerPosition(String(newPos * parseInt(ticksPerFrame)));
  }

  static pad(num: number, size: number): string {
    let s = num.toString();
    while (s.length < size) s = "0" + s;
    return s;
  }

  static getProjectItemInRoot(itemName: string): ProjectItem {
    let projectItem = undefined;

    for (let i = 0; i < app.project.rootItem.children.numItems; i++) {
      const child = app.project.rootItem.children[i];
      if (child.name === itemName) {
        projectItem = child;
        break;
      }
    }

    return projectItem;
  }

  static getProjectMetadata(projectItem: ProjectItem, fieldNames) {
    // Based on: https://community.adobe.com/t5/premiere-pro/get-image-size-in-jsx/td-p/10554914?page=1&profile.language=de
    const kPProPrivateProjectMetadataURI = "http://ns.adobe.com/premierePrivateProjectMetaData/1.0/";
    if (app.isDocumentOpen()) {
      if (projectItem) {

        if (ExternalObject.AdobeXMPScript === undefined)
          ExternalObject.AdobeXMPScript = new ExternalObject("lib:AdobeXMPScript");
        if (ExternalObject.AdobeXMPScript !== undefined) {
          let retArray = [];
          let retArray2 = [];
          const projectMetadata = projectItem.getProjectMetadata();
          let xmp = new XMPMeta(projectMetadata);
          for (let pc = 0; pc < fieldNames.length; pc++) {
            if (xmp.doesPropertyExist(kPProPrivateProjectMetadataURI, fieldNames[pc])) {
              retArray.push([fieldNames[pc], xmp.getProperty(kPProPrivateProjectMetadataURI, fieldNames[pc])]);
              retArray2.push([xmp.getProperty(kPProPrivateProjectMetadataURI, fieldNames[pc])]);
            }
          }
          return retArray2;
        }
      }
    }
    return false;
  }

  static getAudioTracks() {
    var activeSequence = app.project.activeSequence;
    var audioTracks = activeSequence.audioTracks;
    var trackNum = String(audioTracks.numTracks)
    return trackNum
  }

  static getVideoTracks() {
    var activeSequence = app.project.activeSequence;
    var videoTracks = activeSequence.videoTracks;
    var trackNum = String(videoTracks.numTracks)
    return trackNum
  }

  static organiseProject() {
    var project = app.project;
    var projectItem = project.rootItem;

    for (let i = 0; i < projectItem.children.numItems; i++) {
      switch (app.project.rootItem.children[i].name) {
        case "_Assets":
          if (app.project.rootItem.children[i].type !== 2)
            continue;
          const assetFolder = app.project.rootItem.children[i]
          for (let j = 0; j < assetFolder.children.numItems; j++) {
            switch (assetFolder.children[j].name) {
              case "Images":
              case "02_Images":
                var imageFolder = assetFolder.children[j];
                break;
              case "Videos":
              case "06_Videos":
                var videoFolder = assetFolder.children[j];
                break;
            }
          }
          break;
        case "_linked comps & renders":
          var linkedCompsFolder = app.project.rootItem.children[i]
          break;
      }
    }

    if (typeof imageFolder == 'undefined') {
      var imageFolder = projectItem.createBin("Images");
    }
    var images = [];
    if (typeof videoFolder == 'undefined') {
      var videoFolder = projectItem.createBin("06_Videos");
    }
    var videos = [];
    if (typeof linkedCompsFolder == 'undefined') {
      var videoFolder = projectItem.createBin("_linked comps & renders");
    }
    var linkedComps = [];


    var thisName;
    for (var i = 0; i < projectItem.children.numItems; i++) {
      thisName = projectItem.children[i].name;
      var ext = thisName.substring(thisName.lastIndexOf('.') + 1).toLowerCase();

      if ((ext == "aep" && (thisName.indexOf("linked comp") !== -1 || thisName.indexOf("Linked Comp") !== -1)) || thisName.substring(thisName.length - 17, thisName.length).toLowerCase() == ".aep_rendered.mov" || thisName.substring(0, 15).toLowerCase() == "nested sequence") {
        linkedComps.push(projectItem.children[i]);
      }

      // images
      var imageExts = ["jpg", "jpeg", "png", "webp", "heic", "gif"];
      if (this.arrayContains(imageExts, ext)) {
        images.push(projectItem.children[i]);
      }

      // video
      var vidExts = ["mp4", "mov", "avi", "mkv"]
      if (this.arrayContains(vidExts, ext)) {
        videos.push(projectItem.children[i]);
      }
    }

    Utils.moveToFolder(images, imageFolder);
    Utils.moveToFolder(videos, videoFolder);
    Utils.moveToFolder(linkedComps, linkedCompsFolder);
  }

  static arrayContains(arr: any, value: string) {
    for (var j = 0; j < arr.length; j++) {
      if (arr[j] === value) return true;
    }
    return false;
  }

  static moveToFolder(items: any, folder: any) {
    for (var i = 0; i < items.length; i++) {
      items[i].moveBin(folder);
    }
  }

  static findOrCreateFolderPath(rootItem, folderPath, createIfMissing) {
    // Navigate to a folder path, optionally creating it if it doesn't exist
    // createIfMissing: if true, creates the final folder; if false, returns null if not found

    if (typeof createIfMissing === 'undefined') {
      createIfMissing = true; // Default to creating for backwards compatibility
    }

    // Split by forward slash or backslash
    var pathParts = folderPath.split(/[\/\\]+/);

    // Filter out empty parts
    var filteredParts = [];
    for (var k = 0; k < pathParts.length; k++) {
      if (pathParts[k]) {
        filteredParts.push(pathParts[k]);
      }
    }
    pathParts = filteredParts;

    var currentFolder = rootItem;

    // Navigate through each level of the path
    for (var partIndex = 0; partIndex < pathParts.length; partIndex++) {
      var folderName = pathParts[partIndex];
      var foundFolder = null;

      // Search for the folder at this level
      for (var childIndex = 0; childIndex < currentFolder.children.numItems; childIndex++) {
        var child = currentFolder.children[childIndex];
        if (child.type === 2 && child.name === folderName) { // type 2 is bin/folder
          foundFolder = child;
          break;
        }
      }

      // If folder doesn't exist
      if (!foundFolder) {
        var isLastFolder = (partIndex === pathParts.length - 1);

        if (createIfMissing && isLastFolder) {
          // Create the final folder if allowed
          foundFolder = currentFolder.createBin(folderName);
        } else if (!isLastFolder) {
          // Intermediate folder missing - can't continue
          alert("Folder path incomplete: could not find '" + folderName + "' in path '" + folderPath + "'");
          return null;
        } else {
          // Final folder missing and not allowed to create
          return null;
        }
      }

      currentFolder = foundFolder;
    }

    return currentFolder;
  }

  static getSelectionBinPath() {
    if (!this.selectionIsSequence()) return false;
    var selected = app.getCurrentProjectViewSelection();
    var projectItem = selected[0];

    var path = Utils.findItemBinPath(app.project.rootItem, projectItem.nodeId, "");
    return path !== null ? path : ""; // not found -> treat as root
  }

  static isPlaying() {
    var isPlaying = qe.project.getActiveSequence().player.isPlaying;
    return isPlaying
  }

  static isSequence() {
    var selection = app.project.activeSequence.getSelection();
    if (selection[0].mediaType != "Video")
      return false;

    var projectItem = selection[0].projectItem;
    if (!projectItem || !projectItem.isSequence())
      return false;
    return true;
  }

  static enableAllVideoTracks() {
    const seq = app.project.activeSequence;
    if (!seq)
      return
    const tracks = seq.videoTracks
    for (let i = 0; i < tracks.numTracks; i++) {
      tracks[i].setMute(0);
    }
  }

  static unmuteAllMutedTracks() {
    const seq = app.project.activeSequence;
    if (!seq)
      return
    const tracks = seq.audioTracks
    for (let i = 0; i < tracks.numTracks; i++) {
      tracks[i].setMute(0);
    }
  }

  static selectionIsSequence() {
    var selected = app.getCurrentProjectViewSelection();
    if (!selected || selected.length === 0) return false;

    var projectItem = selected[0];
    if (!projectItem.isSequence()) return false;
    return true;
  }

  static renderInPrem(outputPath: string, presetPath: string) {
    if (!this.selectionIsSequence()) return false;
    var selected = app.getCurrentProjectViewSelection();
    var projectItem = selected[0];

    var sequence = null;
    for (var i = 0; i < app.project.sequences.numSequences; i++) {
      if (app.project.sequences[i].projectItem.nodeId === projectItem.nodeId) {
        sequence = app.project.sequences[i];
        break;
      }
    }
    if (!sequence) return false;

    outputPath = outputPath.replace(/\//g, "\\");
    presetPath = presetPath.replace(/\//g, "\\");

    var presetFile = new File(presetPath);
    var extension = null;
    var fileTypeValue = null; // Store the actual value for error message

    if (presetFile.open("r")) {
      var content = presetFile.read();
      presetFile.close();

      var match = content.match(/<ExporterFileType>(\d+)<\/ExporterFileType>/);
      if (match) {
        var fileType = parseInt(match[1]);
        fileTypeValue = fileType; // Save for later

        switch (fileType) {
          case 1299148630: // 'Mqv ' - QuickTime MOV
            extension = ".mov";
            break;
          case 1212503619: // 'Hdmt' - H.265/HEVC MP4
            alert("Rendering h265 programmatically is unfortunately impossible.")
            return false;
          case 1211250228: // 'Hdv4' - H.264 MP4
            extension = ".mp4";
            break;
        }
      }
    }

    if (!extension) {
      alert("No extension defined for the current preset. ExporterFileType: " + fileTypeValue);
      return false;
    }

    var baseName = sequence.name;
    var finalPath = outputPath + "\\" + baseName;
    var counter = 1;

    while (this.fileExists(finalPath, extension)) {
      finalPath = outputPath + "\\" + baseName + "_" + counter;
      counter++;
    }

    sequence.exportAsMediaDirect(finalPath + extension, presetPath, 1);
    var stable = this.waitForFileStable(finalPath + extension, 1000, 120000);
    if (!stable) return false;
    $.sleep(500)
    return finalPath + extension;
  }

  static fileExists(basePath, ext) {
    var file = new File(basePath + ext);
    return file.exists;
  }

  static waitForFileStable(filePath: string, intervalMs: number, maxWaitMs: number): boolean {
    var file = new File(filePath);
    var elapsed = 0;
    var lastSize = -1;

    while (elapsed < maxWaitMs) {
      $.sleep(intervalMs);
      elapsed += intervalMs;

      if (!file.exists) continue;

      // ExtendScript File doesn't expose size directly, so re-open each time
      file.open("r");
      var currentSize = file.length;
      file.close();

      if (currentSize > 0 && currentSize === lastSize) {
        return true; // Size stable — write is complete
      }
      lastSize = currentSize;
    }
    return false;
  }

  // just fyi this function is ai slop through and through
  // I didn't know enough about typescript to make something like this myself
  static checkObjParams() {
    try {
      var seq = qe.project.getActiveSequence();
      const player = seq.multicam;
      // const player = seq.source;
      // const player = qe;

      var output = "=== PROPERTIES ===\n";
      for (var prop in player) {
        try {
          var value = player[prop];
          var valueType = typeof value;
          output += prop + ": " + value + " (type: " + valueType + ")\n";
        } catch (e) {
          output += prop + ": [Error accessing property]\n";
        }
      }

      output += "\n=== REFLECT INFO ===\n";
      if (player.reflect) {
        var info = player.reflect;
        output += "Name: " + info.name + "\n";
        output += "Methods: " + info.methods + "\n";
        output += "Properties: " + info.properties + "\n";
      } else {
        output += "No reflect info available\n";
      }

      var file = new File("~/Desktop/player_info.txt");
      file.open("w");
      file.write(output);
      file.close();

      alert("Info written to Desktop/player_info.txt");
    } catch (e) {
      alert("Error: " + e.toString());
    }
  }

  // just fyi this function is ai slop through and through
  // I didn't know enough about typescript to make something like this myself
  static checkFuncParams(inspectPath: string) {
    try {

      // var inspectPath = "qe.project.getActiveSequence().multicam.play";
      // Examples:
      // "qe.project.getActiveSequence().multicam.play"
      // "qe.project.getActiveSequence().getVideoTrackAt"
      // "qe.project.getActiveSequence().player.startPlayback"
      // ========================================

      // Parse the path
      var parts = inspectPath.split('.');
      var methodName = parts[parts.length - 1];

      // Start from qe (the root object)
      var current = qe;

      // Skip the first part if it's "qe" since we're already starting there
      var startIndex = parts[0] === 'qe' ? 1 : 0;

      for (var i = startIndex; i < parts.length - 1; i++) {
        var part = parts[i];

        // Handle function calls like getActiveSequence()
        if (part.indexOf('()') !== -1) {
          var funcName = part.replace('()', '');
          if (typeof current[funcName] === 'function') {
            current = current[funcName]();
          } else {
            throw new Error("Function '" + funcName + "' not found");
          }
        } else {
          current = current[part];
        }

        if (!current) {
          throw new Error("Could not traverse to '" + parts.slice(0, i + 1).join('.') + "'");
        }
      }

      var parentObj = current;
      var targetMethod = parentObj[methodName];

      var output = "=== INSPECTING: " + inspectPath + " ===\n\n";

      // Check if method exists
      if (!targetMethod) {
        output += "Method '" + methodName + "' not found on object\n";
      } else if (typeof targetMethod !== "function") {
        output += "'" + methodName + "' is not a function (type: " + typeof targetMethod + ")\n";
        output += "Value: " + targetMethod + "\n";
      } else {
        output += "=== METHOD DETAILS ===\n";
        output += "Method name: " + methodName + "\n";
        output += "Is function: YES\n\n";

        // Try to get function signature
        output += "Function toString:\n";
        var funcString = targetMethod.toString();
        output += funcString + "\n\n";

        // Check for reflect info on the method
        output += "=== REFLECT INFO (METHOD) ===\n";
        if (parentObj.reflect && parentObj.reflect.find) {
          try {
            var methodInfo = parentObj.reflect.find(methodName);
            if (methodInfo) {
              output += "Found reflect info for method!\n";
              output += "Data type: " + methodInfo.dataType + "\n";
              output += "Type: " + methodInfo.type + "\n";

              if (methodInfo.arguments) {
                output += "\nArguments from reflect:\n";
                if (typeof methodInfo.arguments === 'string') {
                  output += methodInfo.arguments + "\n";
                } else {
                  output += "Count: " + methodInfo.arguments.length + "\n";
                  for (var i = 0; i < methodInfo.arguments.length; i++) {
                    var arg = methodInfo.arguments[i];
                    var argStr = "  [" + i + "] ";

                    if (typeof arg === 'string') {
                      argStr += arg ? ("'" + arg + "'") : "(empty string)";
                    } else if (typeof arg === 'object' && arg !== null) {
                      // Try to extract more info if it's an object
                      argStr += "Object { ";
                      for (var key in arg) {
                        try {
                          argStr += key + ": " + arg[key] + ", ";
                        } catch (e) { }
                      }
                      argStr += "}";
                    } else {
                      argStr += typeof arg + ": " + arg;
                    }

                    output += argStr + "\n";
                  }
                }
              } else {
                output += "No arguments info\n";
              }

              // Check for additional reflect properties
              if (methodInfo.parameters) {
                output += "\nParameters property:\n";
                if (typeof methodInfo.parameters === 'string') {
                  output += methodInfo.parameters + "\n";
                } else if (typeof methodInfo.parameters === 'object') {
                  output += "Type: object\n";
                  for (var key in methodInfo.parameters) {
                    try {
                      output += "  " + key + ": " + methodInfo.parameters[key] + "\n";
                    } catch (e) { }
                  }
                } else {
                  output += methodInfo.parameters + "\n";
                }
              }

              if (methodInfo.min) {
                output += "\nMin arguments: " + methodInfo.min + "\n";
              }

              if (methodInfo.max) {
                output += "Max arguments: " + methodInfo.max + "\n";
              }

              if (methodInfo.description) {
                output += "\nDescription: " + methodInfo.description + "\n";
              }

              if (methodInfo.help) {
                output += "\nHelp: " + methodInfo.help + "\n";
              }

              // Dump all properties of methodInfo
              output += "\n=== ALL REFLECT PROPERTIES ===\n";
              for (var prop in methodInfo) {
                try {
                  var val = methodInfo[prop];
                  if (typeof val !== 'function') {
                    output += prop + ": " + val + " (type: " + typeof val + ")\n";
                  }
                } catch (e) { }
              }
            } else {
              output += "No reflect info found for this method\n";
            }
          } catch (reflectErr) {
            output += "Error getting reflect info: " + reflectErr.toString() + "\n";
          }
        } else {
          output += "Parent object has no reflect capability\n";
        }

        // Show all available methods on parent for context
        output += "\n=== OTHER METHODS ON PARENT OBJECT ===\n";
        if (parentObj.reflect && parentObj.reflect.methods) {
          output += "Available methods (count: " + parentObj.reflect.methods.length + "):\n";
          for (var i = 0; i < parentObj.reflect.methods.length; i++) {
            output += "  - " + parentObj.reflect.methods[i] + "\n";
          }
        } else {
          output += "Scanning object properties:\n";
          var methodCount = 0;
          for (var prop in parentObj) {
            try {
              if (typeof parentObj[prop] === "function") {
                output += "  - " + prop + "()\n";
                methodCount++;
              }
            } catch (e) {
              // Skip inaccessible properties
            }
          }
          output += "Total methods found: " + methodCount + "\n";
        }
      }

      // Create filename from the inspected path
      var filename = inspectPath.replace(/[()]/g, '').replace(/\./g, '_') + "_info.txt";

      var file = new File("~/Desktop/" + filename);
      file.open("w");
      file.write(output);
      file.close();

      alert("Info for '" + inspectPath + "' written to Desktop/" + filename);
    } catch (e) {
      alert("Error inspecting '" + (typeof inspectPath !== 'undefined' ? inspectPath : 'unknown') + "': " + e.toString());
    }
  }

  static base64Decode(input: string) {
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
    var output = "";
    var i = 0;
    while (i < input.length) {
      var enc1 = chars.indexOf(input.charAt(i++));
      var enc2 = chars.indexOf(input.charAt(i++));
      var enc3 = chars.indexOf(input.charAt(i++));
      var enc4 = chars.indexOf(input.charAt(i++));
      var chr1 = (enc1 << 2) | (enc2 >> 4);
      var chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
      var chr3 = ((enc3 & 3) << 6) | enc4;
      output += String.fromCharCode(chr1);
      if (enc3 !== 64) output += String.fromCharCode(chr2);
      if (enc4 !== 64) output += String.fromCharCode(chr3);
    }
    return output;
  }

  static buildXmlIndex(xml: string): { [id: string]: XmlRecord } {
    var index: { [id: string]: XmlRecord } = {};
    var openTagRe = /<([A-Za-z0-9_]+)([^>]*)>/g;
    var m: RegExpExecArray | null;
    while ((m = openTagRe.exec(xml)) !== null) {
      var fullTag = m[0];
      if (fullTag.charAt(fullTag.length - 2) === "/") continue;
      if (fullTag.charAt(1) === "/") continue;

      var tagName = m[1];
      var attrs = m[2];
      var idMatch = attrs.match(/\bObjectID="(\d+)"/);
      if (!idMatch) continue;

      var startIdx = (openTagRe as any).lastIndex; // cast: lastIndex isn't in this project's RegExp lib typing, but exists at runtime
      var closeTag = "</" + tagName + ">";
      var endIdx = xml.indexOf(closeTag, startIdx);
      if (endIdx === -1) continue;

      index[idMatch[1]] = { tag: tagName, content: xml.substring(startIdx, endIdx) };
      (openTagRe as any).lastIndex = endIdx + closeTag.length; // same cast here
    }
    return index;
  }

  static extractTag(content: string, tagName: string): string | null {
    var re = new RegExp("<" + tagName + "(?:\\s[^>]*)?>([\\s\\S]*?)<\\/" + tagName + ">");
    var m = content.match(re);
    return m ? m[1] : null;
  }

  static extractRef(content: string, tagName: string): string | null {
    var re = new RegExp("<" + tagName + "\\s+ObjectRef=\"(\\d+)\"\\s*\\/>");
    var m = content.match(re);
    return m ? m[1] : null;
  }

  static extractAllRefs(content: string, containerTag: string, itemTag: string): string[] {
    var container = this.extractTag(content, containerTag);
    if (!container) return [];
    var re = new RegExp("<" + itemTag + "\\s+Index=\"(\\d+)\"\\s+ObjectRef=\"(\\d+)\"\\s*\\/>", "g");
    var results: { index: number; ref: string }[] = [];
    var m: RegExpExecArray | null;
    while ((m = re.exec(container)) !== null) {
      results.push({ index: Number(m[1]), ref: m[2] });
    }
    results.sort(function (a, b) { return a.index - b.index; });
    var refs: string[] = [];
    for (var i = 0; i < results.length; i++) refs.push(results[i].ref);
    return refs;
  }

  static paramName(content: string): string {
    return this.extractTag(content, "Name") || this.extractTag(content, "n") || "";
  }

  static parseStartKeyframeValue(raw: string | null): any {
    if (!raw) return undefined;
    var rawValue = raw.split(",")[1];
    if (rawValue === "true") return true;
    if (rawValue === "false") return false;
    var num = Number(rawValue);
    return isNaN(num) ? rawValue : num;
  }

  static prfpsetXmlToBuckets(xmlText: string): { mediaType: string, effects: EffectEntry[] }[] {
    var index = this.buildXmlIndex(xmlText);
    var buckets: { [mediaType: string]: EffectEntry[] } = {};

    for (var id in index) {
      var rec = index[id];
      if (rec.tag !== "FilterPresetItem") continue;

      var presetRefs = this.extractAllRefs(rec.content, "FilterPresets", "FilterPreset");
      for (var pi = 0; pi < presetRefs.length; pi++) {
        var presetRec = index[presetRefs[pi]];
        if (!presetRec) continue;

        var matchName = this.extractTag(presetRec.content, "FilterMatchName") || "";
        var anchorInPoint = this.extractTag(presetRec.content, "AnchorInPoint") || "0";
        var anchorOutPoint = this.extractTag(presetRec.content, "AnchorOutPoint") || anchorInPoint;

        var componentRef = this.extractRef(presetRec.content, "Component");
        var componentRec = componentRef ? index[componentRef] : null;
        if (!componentRec) continue;

        var mediaType = componentRec.tag === "VideoFilterComponent" ? "Video" : "Audio";
        var innerBlock = this.extractTag(componentRec.content, "Component") || componentRec.content;
        var displayName = this.extractTag(innerBlock, "DisplayName") || "";

        var properties: any[] = [];
        var paramRefs = this.extractAllRefs(innerBlock, "Params", "Param");
        for (var pr = 0; pr < paramRefs.length; pr++) {
          var paramRec = index[paramRefs[pr]];
          if (!paramRec) {
            properties.push({ displayName: "", isTimeVarying: false, value: undefined });
            continue;
          }
          var name = this.paramName(paramRec.content);
          var isTimeVarying = (this.extractTag(paramRec.content, "IsTimeVarying") || "false") === "true";

          if (isTimeVarying) {
            var keyframesRaw = this.extractTag(paramRec.content, "Keyframes") || "";
            var keyframes: any[] = [];
            var entries = keyframesRaw.split(";");
            for (var e = 0; e < entries.length; e++) {
              var entry = entries[e].replace(/^\s+|\s+$/g, "");
              if (!entry) continue;
              var parts = entry.split(",");
              var time = parts[0];
              var rawValue = parts[1];
              var value: any;
              if (rawValue === "true") value = true;
              else if (rawValue === "false") value = false;
              else {
                var num = Number(rawValue);
                value = isNaN(num) ? rawValue : num;
              }
              keyframes.push({ time: time, value: value });
            }
            properties.push({ displayName: name, isTimeVarying: true, keyframes: keyframes });
          } else {
            var startKeyframeRaw = this.extractTag(paramRec.content, "StartKeyframe");
            properties.push({ displayName: name, isTimeVarying: false, value: this.parseStartKeyframeValue(startKeyframeRaw) });
          }
        }

        if (!buckets[mediaType]) buckets[mediaType] = [];
        buckets[mediaType].push({ matchName: matchName, displayName: displayName, anchorInPoint: anchorInPoint, anchorOutPoint: anchorOutPoint, properties: properties } as any);
      }
    }

    var result: { mediaType: string, effects: EffectEntry[] }[] = [];
    for (var mt in buckets) {
      result.push({ mediaType: mt, effects: buckets[mt] });
    }
    return result;
  }

  /**
   * reads a file path off disk, or falls back to treating the input as a
   * base64-encoded JSON string (for backwards compatibility with old callers)
   */
  static readAndDecodeText(filePathOrData) {
    var file = new File(filePathOrData);
    if (file.exists) {
      file.encoding = "UTF-8";
      file.open("r");
      var text = file.read();
      file.close();
      return this.parsePayloadText(text);
    }
    var decoded = this.base64Decode(filePathOrData);
    return this.parsePayloadText(decoded);
  }

  static parsePayloadText(text) {
    var trimmed = text.replace(/^\s+/, "");
    if (trimmed.indexOf("<?xml") === 0 || trimmed.indexOf("<PremiereData") === 0) {
      return this.prfpsetXmlToBuckets(text);
    }
    return JSON.parse(trimmed);
  }

  static findProjectItemByPath(itemPath: string) {
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
      for (var i = 0; i < lastSlashIndex; i++) {
        folderPath += itemPath[i];
      }
      for (var i = lastSlashIndex + 1; i < itemPath.length; i++) {
        itemName += itemPath[i];
      }
    } else {
      itemName = itemPath;
    }

    const searchFolder = folderPath
      ? Utils.findOrCreateFolderPath(app.project.rootItem, folderPath, false)
      : app.project.rootItem;

    if (!searchFolder) {
      return null;
    }

    return this.searchForItemByName(searchFolder, itemName);
  }

  // Recursively find the folder path (as a string) containing the item with the given nodeId.
  // Returns "" if the item lives directly under rootItem, or null if not found at all.
  static findItemBinPath(bin: ProjectItem, targetNodeId: string, currentPath: string): string | null {
    for (var i = 0; i < bin.children.numItems; i++) {
      var child = bin.children[i];
      if (!child) continue;

      if (child.type !== ProjectItemType.BIN && child.nodeId === targetNodeId) {
        return currentPath;
      }

      if (child.type === ProjectItemType.BIN) {
        var nextPath = currentPath ? (currentPath + "/" + child.name) : child.name;
        var found = this.findItemBinPath(child, targetNodeId, nextPath);
        if (found !== null) return found;
      }
    }
    return null;
  }

  // @link : https://github.com/Adobe-CEP/Samples/blob/fbc2f2fc090b41a07f07f9fffe2043d9bafb4988/PProPanel/jsx/PPRO/Premiere.jsx#L1119
  // @link : https://chatgpt.com/s/t_6924520380ec8191882f7441c64f1251
  static searchForItemByName(bin: ProjectItem, name: string): any | null {
    for (var i = 0; i < bin.children.numItems; i++) {
      var child = bin.children[i];
      if (!child) continue;

      if (child.type !== ProjectItemType.BIN && child.name === name) {
        return child;
      }

      if (child.type === ProjectItemType.BIN) {
        var found = this.searchForItemByName(child, name);
        if (found) return found;
      }
    }
    return null;
  }

  /**
   * TrackItem doesn't reliably expose its own track index across API
   * versions, so we find it by scanning every video track's clip list
   * and matching on nodeId.
   */
  static getVideoTrackIndexForClip(sequence: Sequence, clip: any): number {
    for (var t = 0; t < sequence.videoTracks.numTracks; t++) {
      var track = sequence.videoTracks[t];
      for (var c = 0; c < track.clips.numItems; c++) {
        if (track.clips[c].nodeId === clip.nodeId) {
          return t;
        }
      }
    }
    return -1;
  }

  /**
   * Returns { clip, trackIndex }[] for every currently selected clip that
   * lives on a video track (audio-only selections are ignored).
   */
  static getSelectedVideoClips(sequence: Sequence): Array<{ clip: any; trackIndex: number }> {
    var selection = sequence.getSelection ? sequence.getSelection() : [];
    var result: Array<{ clip: any; trackIndex: number }> = [];

    for (var i = 0; i < selection.length; i++) {
      var item = selection[i];
      var trackIndex = this.getVideoTrackIndexForClip(sequence, item);
      if (trackIndex !== -1) {
        result.push({ clip: item, trackIndex: trackIndex });
      }
    }
    return result;
  }

  /**
   * True if no clip on `track` overlaps the half-open range [startTicks, endTicks).
   * Compares .ticks (an exact integer count, as a string) rather than .seconds,
   * since .seconds is a lossy float for non-integer frame rates (29.97, 23.976,
   * 59.94, etc.).
   */
  static isTrackRangeFree(track: Track, startTicks: number, endTicks: number): boolean {
    for (var i = 0; i < track.clips.numItems; i++) {
      var clip = track.clips[i];
      var clipStart = Number(clip.start.ticks);
      var clipEnd = Number(clip.end.ticks);
      if (clipStart < endTicks && clipEnd > startTicks) {
        return false; // overlap
      }
    }
    return true;
  }
}