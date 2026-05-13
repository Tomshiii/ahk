#Include "%A_Appdata%\tomshi\lib"
#Include Classes\Editors\Premiere.ahk

;// this script is to fix a situation where an editor hasn't used the multicam audio track and left
;// all camera audio sources in the timeline

+F3::ExitApp()
F3::
{
    __sendLoop(delay, inputs*) {
        SetKeyDelay(16)
        for i in inputs {
            Send(i)
            sleep delay
        }
    }
    loopAmount  := 80 ;// use the info tab to figure out how many clips there are
    loop loopAmount {
        __sendLoop(100, "d", "f", ",")
        sleep 400
        prem.__remoteFunc('closeAllClipSourceMon')
        sleep 100
        prem.__focusTimeline()
    }
    ExitApp()
}

;// or using api something like;
;// you'll just need to delete the resulting video track...
/**
(function () {
    function transferVideoClipsAudioToTrack(videoTrackIndex, audioTrackIndex) {
        var seq = app.project.activeSequence;
        if (!seq) { alert("No active sequence."); return; }

        var vTrack = seq.videoTracks[videoTrackIndex];
        var aTrack = seq.audioTracks[audioTrackIndex];

        if (!vTrack) { alert("Video track not found."); return; }
        if (!aTrack) { alert("Audio track not found."); return; }

        var lockedVideo = [];
        var lockedAudio = [];

        for (var v = 0; v < seq.videoTracks.numTracks; v++) {
            var vt = seq.videoTracks[v];
            if (!vt.isLocked()) {
                vt.setLocked(1);
                lockedVideo.push(v);
            }
        }
        for (var a = 0; a < seq.audioTracks.numTracks; a++) {
            if (a !== audioTrackIndex) {
                var at = seq.audioTracks[a];
                if (!at.isLocked()) {
                    at.setLocked(1);
                    lockedAudio.push(a);
                }
            }
        }

        var clips = vTrack.clips;

        for (var i = 0; i < clips.numItems; i++) {
            var clip = clips[i];
            var projectItem = clip.projectItem;

            if (!projectItem || projectItem.type !== 1) continue;

            var inPoint  = clip.inPoint;
            var outPoint = clip.outPoint;
            var start    = clip.start;

            var originalIn  = projectItem.getInPoint(4);
            var originalOut = projectItem.getOutPoint(4);

            projectItem.setInPoint(inPoint.seconds, 4);
            projectItem.setOutPoint(outPoint.seconds, 4);

            aTrack.overwriteClip(projectItem, start.seconds);

            projectItem.setInPoint(originalIn.seconds, 4);
            projectItem.setOutPoint(originalOut.seconds, 4);
        }

        for (var lv = 0; lv < lockedVideo.length; lv++) {
            seq.videoTracks[lockedVideo[lv]].setLocked(0);
        }
        for (var la = 0; la < lockedAudio.length; la++) {
            seq.audioTracks[lockedAudio[la]].setLocked(0);
        }
    }

    transferVideoClipsAudioToTrack(0, 1);
})();