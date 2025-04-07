// this was an attempt to recreate the hotkey inside of premiere's CEP engine
// never got it to work

static moveToNearestKeyframe(direction: string) {
    const currSeq = app.project.activeSequence;
    if (!currSeq) {
        alert("No active sequence.");
        return;
    }

    const clips = currSeq.getSelection();
    if (clips.length === 0) {
        alert("No clip selected.");
        return;
    }

    const clip = clips[0];
    const playheadTime = currSeq.getPlayerPosition().seconds; // Convert to seconds
    alert("Playhead Position: " + playheadTime);

    // Loop through all components
    for (let c = 0; c < clip.components.numItems; c++) {
        const component = clip.components[c];
        alert("Checking Component: " + c + " (" + component.displayName + ")");

        // Loop through all properties
        for (let p = 0; p < component.properties.numItems; p++) {
            const property = component.properties[p];
            alert("Checking Property: " + p + " (" + property.displayName + ")");

            // Check if the property supports keyframes
            if (property.getKeys) {
                alert("Property '" + property.displayName + "' supports keyframes.");

                try {
                    // Get keyframes directly and log them
                    const keyframes = property.getKeys();
                    alert("Raw keyframes for '" + property.displayName + "': " + keyframes);

                    // Log the keyframe types and values to inspect their structure
                    const keyframeTimes: number[] = [];
                    if (keyframes && keyframes.numItems > 0) {
                        for (let i = 0; i < keyframes.numItems; i++) {
                            const keyframe = keyframes[i];
                            const keyframeTime = keyframe.seconds; // Get the time in seconds
                            alert("Keyframe " + i + ": " + keyframeTime + " seconds");

                            // Check the type of the keyframe to ensure it's a valid Time object
                            alert("Keyframe type: " + typeof keyframe);
                            keyframeTimes.push(keyframeTime);
                        }

                        // Check the times of the keyframes logged
                        alert("All keyframe times: " + keyframeTimes);

                        // Manually find the nearest keyframe based on simple comparison
                        let nearestKey: number | null = null;

                        if (direction === "back") {
                            // Find the nearest keyframe backwards
                            for (let i = keyframeTimes.length - 1; i >= 0; i--) {
                                if (keyframeTimes[i] < playheadTime) {
                                    nearestKey = keyframeTimes[i];
                                    break;
                                }
                            }
                        } else if (direction === "forward") {
                            // Find the nearest keyframe forwards
                            for (let i = 0; i < keyframeTimes.length; i++) {
                                if (keyframeTimes[i] > playheadTime) {
                                    nearestKey = keyframeTimes[i];
                                    break;
                                }
                            }
                        }

                        // If a keyframe is found, move the playhead
                        if (nearestKey !== null) {
                            alert("Nearest keyframe found: " + nearestKey);
                            currSeq.setPlayerPosition(nearestKey.toString()); // Convert to string
                            alert("Moved playhead to: " + nearestKey);
                            return;
                        } else {
                            alert("No keyframe found in the specified direction.");
                        }
                    } else {
                        alert("No keyframes found for '" + property.displayName + "'.");
                    }
                } catch (error) {
                    alert("Error getting keyframes for '" + property.displayName + "': " + error);
                }
            } else {
                alert("Property '" + property.displayName + "' does NOT support keyframes.");
            }
        }
    }

    alert("No keyframes found in any properties.");
}