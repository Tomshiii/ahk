import { Utils } from "./Utils";

declare global {
  interface Track {
    overwriteClip(clipProjectItem: ProjectItem, time: Time): void;
  }
}

export class MarkerUtils {

  static setMarker(colour: string) {
    var activeSequence = app.project.activeSequence;
    var selection = activeSequence.getSelection();

    Utils.fixPlayHeadPosition();

    const playheadTime = activeSequence.getPlayerPosition().seconds;

    // no selection — add sequence marker
    if (!selection || selection.length === 0) {
      var seqMarkers = activeSequence.markers;
      var existingSeqMarker = null;
      var tolerance = 0.001;

      for (var j = 0; j < seqMarkers.numMarkers; j++) {
        var seqMarker = seqMarkers[j];
        if (Math.abs(seqMarker.start.seconds - playheadTime) <= tolerance) {
          existingSeqMarker = seqMarker;
          break;
        }
      }

      if (existingSeqMarker) {
        existingSeqMarker.setColorByIndex(parseInt(colour));
      } else {
        var newSeqMarker = seqMarkers.createMarker(playheadTime);
        newSeqMarker.setColorByIndex(parseInt(colour));
      }
      return;
    }

    // clips selected — add clip markers
    for (var i = 0; i < selection.length; i++) {
      var trackItem = selection[i];

      if (trackItem.mediaType && trackItem.projectItem) {
        const clipInPoint = trackItem.inPoint.seconds;
        const clipStart = trackItem.start.seconds;
        const markerPositionInSource = clipInPoint + (playheadTime - clipStart);

        var markers = trackItem.projectItem.getMarkers();
        var existingMarker = null;
        var tolerance = 0.001;

        for (var j = 0; j < markers.numMarkers; j++) {
          var marker = markers[j];
          if (Math.abs(marker.start.seconds - markerPositionInSource) <= tolerance) {
            existingMarker = marker;
            break;
          }
        }

        if (existingMarker) {
          existingMarker.setColorByIndex(parseInt(colour));
        } else {
          var newMarker = markers.createMarker(markerPositionInSource);
          newMarker.setColorByIndex(parseInt(colour));
        }
      }
    }
  }

  static removeMarkerAtPlayhead(): void {
    const activeSequence = app.project.activeSequence;
    const selection = activeSequence.getSelection();

    Utils.fixPlayHeadPosition();

    const ticksPerFrame = parseInt(activeSequence.getSettings().videoFrameRate.ticks);
    const playheadTicks = parseInt(activeSequence.getPlayerPosition().ticks);
    const playheadFrame = this.ticksToFrame(playheadTicks, ticksPerFrame);

    if (!selection || selection.length === 0) {
      const seqMarkers = activeSequence.markers;
      const match = this.findMarkerAtFrame(seqMarkers, playheadFrame, ticksPerFrame);

      if (match) {
        seqMarkers.deleteMarker(match);
      }
      return;
    }

    for (var i = 0; i < selection.length; i++) {
      const trackItem = selection[i];
      if (!trackItem.mediaType || !trackItem.projectItem) continue;

      const clipInPointTicks = parseInt(trackItem.inPoint.ticks);
      const clipStartTicks = parseInt(trackItem.start.ticks);
      const markerPositionTicks = clipInPointTicks + (playheadTicks - clipStartTicks);
      const markerPositionFrame = this.ticksToFrame(markerPositionTicks, ticksPerFrame);

      const markers = trackItem.projectItem.getMarkers();
      const match = this.findMarkerAtFrame(markers, markerPositionFrame, ticksPerFrame);

      if (match) {
        markers.deleteMarker(match);
      }
    }
  }

  /**
   * Converts a raw tick value to a frame index (rounded to nearest frame).
   */
  static ticksToFrame(ticks: number, ticksPerFrame: number): number {
    return Math.round(ticks / ticksPerFrame);
  }

  /**
   * Finds a marker whose start time falls on the exact same frame index
   * as targetFrame. No tolerance window — adjacent frames never match.
   */
  static findMarkerAtFrame(markers: any, targetFrame: number, ticksPerFrame: number): any | null {
    for (var j = 0; j < markers.numMarkers; j++) {
      const markerTicks = parseInt(markers[j].start.ticks);
      const markerFrame = this.ticksToFrame(markerTicks, ticksPerFrame);
      if (markerFrame === targetFrame) {
        return markers[j];
      }
    }
    return null;
  }

  static getMarkerItemInMarkerFolder(
    markerColor: string
  ): undefined | ProjectItem {

    //return undefined;

    for (let i = 0; i < app.project.rootItem.children.numItems; i++) {
      const child = app.project.rootItem.children[i];

      if (child.name === "marker") {
        for (let j = 0; j < child.children.numItems; j++) {
          const markerChild = child.children[j];

          if (markerChild.name === markerColor) {
            return markerChild;
          }
        }
      }
    }
    return undefined;
  }

  static getLastUnnamedMarkerClip(): TrackItem {
    const currentSequence = app.project.activeSequence;
    const markerLayer =
      currentSequence.videoTracks[currentSequence.videoTracks.numTracks - 1];
    const markerClips = markerLayer.clips;
    const markerCount = markerClips.numItems;

    const lastMarker = markerClips[markerCount - 1];
    debugger;

    if (/[0-9]+/.test(lastMarker.name)) {
      return lastMarker;
    }
    return markerClips[markerCount - 2];
  }

  static addCustomMarker(color: string): void {
    const currentSequence = app.project.activeSequence;
    const markerLayer =
      currentSequence.videoTracks[currentSequence.videoTracks.numTracks - 1];

    Utils.fixPlayHeadPosition();
    const currentPlayheadPosition = currentSequence.getPlayerPosition();

    const markerChild = MarkerUtils.getMarkerItemInMarkerFolder(color);

    if (markerChild === undefined) {
      alert("No 'marker' folder found. Please use a viable preset.");
    } else {
      markerLayer.overwriteClip(markerChild, currentPlayheadPosition);
    }
  }

  static loadMarkersFromCSVFile(): void {
    const csvFileDialog = File.openDialog("Target CSV File", "*.csv");
    const csvFile = csvFileDialog.fsName;

    const currentSequence = app.project.activeSequence;
    const markerLayer =
      currentSequence.videoTracks[currentSequence.videoTracks.numTracks - 1];
    const currentPlayheadPosition = currentSequence.getPlayerPosition();

    if (csvFile) {
      const file = File(csvFile);
      file.open("r");
      const fullText = file.read();
      file.close();

      const lines = fullText.split("\n");

      for (let i = 0; i < lines.length; i++) {
        const entry = lines[i].split(",");

        if (entry.length === 7) {
          // Parse csv
          const seconds =
            parseInt(entry[0]) * 3600 +
            parseInt(entry[1]) * 60 +
            parseInt(entry[2]) +
            parseInt(entry[3]) / 1000;
          const mode = entry[4];
          const message = entry[5];
          const color = entry[6];

          // Insert clip
          const markerChild = MarkerUtils.getMarkerItemInMarkerFolder(color);
          const targetInSeconds = currentPlayheadPosition.seconds + seconds;
          markerLayer.overwriteClip(markerChild, targetInSeconds);

          // Retrieve clip
          const clip = MarkerUtils.getLastUnnamedMarkerClip();

          // Set name
          clip.name = message;

          // Set length
          if (mode === "mode") {
            // If mode == mode, get next item with mode mode and calculate length
            let nextItemSeconds = -1;
            for (let j = i + 1; j < lines.length; j++) {
              const newEntry = lines[j].split(",");
              const nextSeconds =
                parseInt(newEntry[0]) * 3600 +
                parseInt(newEntry[1]) * 60 +
                parseInt(newEntry[2]) +
                parseInt(newEntry[3]) / 1000;
              const nextMode = newEntry[4];

              if (nextMode === "mode") {
                nextItemSeconds = nextSeconds;
                break;
              }
            }
            if (nextItemSeconds > 0) {
              const endTime = new Time();
              endTime.seconds =
                nextItemSeconds + currentPlayheadPosition.seconds;
              clip.end = endTime; // not my fault, types problem
            }
          }
        }
      }
    }
  }

  static saveCustomMarkerToTextFile(): void {
    const currentSequence = app.project.activeSequence;
    const markerLayer =
      currentSequence.videoTracks[currentSequence.videoTracks.numTracks - 1];
    const markerClips = markerLayer.clips;
    const markerCount = markerClips.numItems;
    const projectName = app.project.name;

    let output = "Project: " + projectName + "\n";
    output += "Sequence: " + currentSequence.name + "\n";
    output += "Marker count: " + markerCount + "\n\n";

    for (let i = 0; i < markerCount; i++) {
      const clip = markerClips[i];
      let trueSeconds = parseInt("" + clip.start.seconds);

      const hours = parseInt("" + trueSeconds / 3600);
      trueSeconds -= hours * 3600;

      const minutes = parseInt("" + trueSeconds / 60);
      trueSeconds -= minutes * 60;

      const seconds = trueSeconds;

      if (hours > 0) {
        output += Utils.pad(hours, 2) + ":";
      }
      output += Utils.pad(minutes, 2) + ":";
      output += Utils.pad(seconds, 2) + " - ";

      output += clip.name + "\n";
    }
    try {
      const file = new File();
      const fileNew = file.saveDlg("Save new file", "*.txt");
      fileNew.encoding = "UTF8";
      fileNew.open("w");
      fileNew.write(output);
      fileNew.close();
    } catch (error) {
      // User hit cancel
    }
  }

  static selectCurrentMarker(): void {
    const clip = MarkerUtils.getCurrentMarkerClip();

    if (clip !== undefined) {
      clip.setSelected(true, true);
    }
  }

  static getCurrentMarkerClip(): TrackItem {
    const currentSequence = app.project.activeSequence;
    const markerLayer =
      currentSequence.videoTracks[currentSequence.videoTracks.numTracks - 1];
    const markerClips = markerLayer.clips;
    const markerCount = markerClips.numItems;

    Utils.fixPlayHeadPosition();
    const currentPlayheadPosition = currentSequence.getPlayerPosition().ticks;

    for (let i = 0; i < markerCount; i++) {
      const clip = markerClips[i];
      const startTicks = clip.start.ticks;
      const endTicks = clip.end.ticks;

      if (
        parseInt(startTicks) <= parseInt(currentPlayheadPosition) &&
        parseInt(currentPlayheadPosition) < parseInt(endTicks)
      ) {
        return clip;
      }
    }
  }
  static deselectAll(): void {
    const currentSequence = app.project.activeSequence;
    for (let i = 0; i < currentSequence.videoTracks.numTracks; i++) {
      const track = currentSequence.videoTracks[i];
      for (let j = 0; j < track.clips.numItems; j++) {
        const clip = track.clips[j];
        clip.setSelected(false, true);
      }
    }
    for (let i = 0; i < currentSequence.audioTracks.numTracks; i++) {
      const track = currentSequence.videoTracks[i];
      for (let j = 0; j < track.clips.numItems; j++) {
        const clip = track.clips[j];
        clip.setSelected(false, true);
      }
    }
  }
}