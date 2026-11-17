/**
 * @fileoverview After Effects actions. Everything in `src/actions/ae/` is exposed under the `ae/` namespace
 * (e.g. `ae/custom/save`) and is only registered when the panel runs inside After Effects.
 *
 * @aiDisclosure Written against the After Effects UXP API reference (https://developer.adobe.com/after-effects/uxp/after-effects-api/).
 * The AE UXP API is in beta and has no published TypeScript types yet, so the host objects are typed loosely.
 * Collections follow the AE DOM: `comp.layers` / `comp.layer(i)` / `property(i)` are 1-based, `comp.selectedLayers` is 0-based.
 */

// eslint-disable-next-line @typescript-eslint/no-require-imports
const aeModule: any = require("aftereffects");
// The official docs show `require("aftereffects")` being the app itself, but at least in 27.1 the app is `.app`.
// Support both so a future fix by Adobe doesn't break this.
const app: any = aeModule?.app ?? aeModule;

/** Runs `fn` as a single undo step in After Effects. */
async function undoable<T>(name: string, fn: () => T | Promise<T>): Promise<T> {
    app.beginUndoGroup(name);
    try {
        return await fn();
    } finally {
        app.endUndoGroup();
    }
}

/** The composition that is currently active (open in the timeline/viewer), or null if the active item is not a comp. */
function getActiveComp(): any | null {
    const item = app.project?.activeItem;
    return isCompItem(item) ? item : null;
}

/** True if `item` is a composition. Duck-typing: only a CompItem has a layer collection. */
function isCompItem(item: any): boolean {
    return !!item && item.layers !== undefined && typeof item.numLayers === "number";
}

/** True if both references point at the same project item (host wrappers are not guaranteed to be identical objects). */
function sameItem(a: any, b: any): boolean {
    return a === b || (a?.id !== undefined && a.id === b?.id);
}

/** The selected layers of the active composition (0-based array). Empty if there is no active comp or no selection. */
function getSelectedLayers(): any[] {
    const comp = getActiveComp();
    if (!comp) return [];
    return Array.from(comp.selectedLayers ?? []);
}

let panelVisible = false;
/**
 * sets panel state var
 */
export async function setPanelVisible(v: boolean) { panelVisible = v; }

/**
 * a simple ping to confirm the UXP extension is currently loaded in After Effects and able to respond
 * @returns {string}
 */
export async function isPanelOpen(): Promise<string> {
    return `uxp visible=${panelVisible}`;
}

/**
 * returns the After Effects name, version and build, e.g. "After Effects 27.1.0 (build 21)"
 * @returns {string}
 */
export async function getHostInfo(): Promise<string> {
    return `${app.appName} ${app.version} (build ${app.buildNumber})`;
}

/**
 * saves the current project. If the project has never been saved, After Effects shows a Save dialog
 * @returns {boolean}
 */
export async function save(): Promise<boolean> {
    if (!app.project) return false;
    return !!app.project.save();
}

/**
 * opens a project file
 * @param {string} [filePath] absolute path to an .aep file
 * @returns {boolean}
 */
export async function openProject(filePath: string): Promise<boolean> {
    return !!app.open(filePath);
}

/**
 * returns the absolute path of the open project, or an empty string if it has not been saved yet
 * @returns {string}
 */
export async function getProjectPath(): Promise<string> {
    return app.project?.file ?? "";
}

/**
 * determine if the project has unsaved changes
 * @returns {boolean}
 */
export async function isProjectDirty(): Promise<boolean> {
    return !!app.project?.dirty;
}

/**
 * imports a file into the project. UNVERIFIED: the AE UXP docs do not yet show how ImportOptions.file is set, so this assumes a path string works
 * @param {string} [filePath] absolute path of the file to import
 * @returns {boolean}
 */
export async function importFile(filePath: string): Promise<boolean> {
    const options = new aeModule.ImportOptions();
    options.file = filePath;
    return !!(await undoable("Import File", () => app.project.importFile(options)));
}

/**
 * returns the name of the active composition, or null if the active item is not a composition
 * @returns {string | null}
 */
export async function getActiveCompName(): Promise<string | null> {
    return getActiveComp()?.name ?? null;
}

/**
 * returns details of the active composition as a JSON string: name, width, height, frameRate, duration, numLayers
 * @returns {string | null}
 */
export async function getActiveCompInfo(): Promise<string | null> {
    const comp = getActiveComp();
    if (!comp) return null;
    return JSON.stringify({
        name: comp.name,
        width: comp.width,
        height: comp.height,
        frameRate: comp.frameRate,
        duration: comp.duration,
        numLayers: comp.numLayers,
    });
}

/**
 * returns the playhead position of the active composition in seconds
 * @returns {number | null}
 */
export async function getPlayheadSeconds(): Promise<number | null> {
    const comp = getActiveComp();
    return comp ? comp.time : null;
}

/**
 * sets the playhead position of the active composition
 * @param {number} [seconds] the new position in seconds. Clamped to the composition's duration
 * @returns {boolean}
 */
export async function setPlayheadSeconds(seconds: number): Promise<boolean> {
    const comp = getActiveComp();
    if (!comp || !Number.isFinite(seconds)) return false;
    comp.time = Math.min(Math.max(seconds, 0), comp.duration);
    return true;
}

/**
 * Moves the playhead by a number of seconds, snapped to the frame grid.
 * @param {number} [seconds] Positive moves forward, negative moves backward.
 * @returns {boolean}
 */
export async function movePlayhead(seconds: number): Promise<boolean> {
    const comp = getActiveComp();
    if (!comp || !Number.isFinite(seconds) || seconds === 0) return false;

    const frame = comp.frameDuration;
    const target = Math.round((comp.time + seconds) / frame) * frame;
    comp.time = Math.min(Math.max(target, 0), comp.duration);
    return true;
}

/**
 * Moves the playhead by a number of frames.
 * @param {number} [frames] Positive moves forward, negative moves backward.
 * @returns {boolean}
 */
export async function movePlayheadFrames(frames: number): Promise<boolean> {
    const comp = getActiveComp();
    if (!comp || !Number.isInteger(frames) || frames === 0) return false;

    comp.frameTime = Math.max(comp.frameTime + frames, 0);
    return true;
}

/**
 * returns how many layers are selected in the active composition
 * @returns {number}
 */
export async function getSelectedLayerCount(): Promise<number> {
    return getSelectedLayers().length;
}

/**
 * returns the names of the selected layers, separated by `|`
 * @returns {string}
 */
export async function getSelectedLayerNames(): Promise<string> {
    return getSelectedLayers().map((layer) => layer.name).join("|");
}

/**
 * determine if there is a layer selection
 * @returns {boolean}
 */
export async function isSelected(): Promise<boolean> {
    return getSelectedLayers().length > 0;
}

/**
 * determine if exactly one layer is selected
 * @returns {boolean}
 */
export async function isSelectedSingle(): Promise<boolean> {
    return getSelectedLayers().length === 1;
}

/**
 * determine if multiple layers are selected
 * @returns {boolean}
 */
export async function isSelectedMultiple(): Promise<boolean> {
    return getSelectedLayers().length > 1;
}

/**
 * deselect all layers of the active composition
 * @returns {boolean}
 */
export async function deselectAll(): Promise<boolean> {
    const layers = getSelectedLayers();
    for (const layer of layers) layer.selected = false;
    return layers.length > 0;
}

/**
 * determine if the first selected layer is enabled (its video switch / eyeball is on)
 * @returns {boolean}
 */
export async function isLayerEnabled(): Promise<boolean> {
    const [layer] = getSelectedLayers();
    return !!layer?.enabled;
}

/**
 * toggles the enabled state (eyeball) of each selected layer individually
 * @returns {boolean}
 */
export async function toggleEnabled(): Promise<boolean> {
    const layers = getSelectedLayers();
    if (layers.length === 0) return false;

    await undoable("Toggle Enabled", () => {
        for (const layer of layers) layer.enabled = !layer.enabled;
    });
    return true;
}

/**
 * enable or disable all selected layers
 * @param {boolean} [enabled]
 * @returns {boolean}
 */
export async function setAllEnabledDisabled(enabled: boolean): Promise<boolean> {
    const layers = getSelectedLayers();
    if (layers.length === 0) return false;

    await undoable("Set Enabled/Disabled", () => {
        for (const layer of layers) layer.enabled = enabled;
    });
    return true;
}

/**
 * move the selected layers in time
 * @param {number} [seconds] Positive moves the layers later, negative moves them earlier.
 * @returns {boolean}
 */
export async function moveLayer(seconds: number): Promise<boolean> {
    const layers = getSelectedLayers();
    if (layers.length === 0 || !Number.isFinite(seconds) || seconds === 0) return false;

    await undoable("Move Layer", () => {
        for (const layer of layers) layer.startTime += seconds;
    });
    return true;
}

/** The effects group of a layer, or null for layers that cannot have effects (cameras, lights, ...). */
function getEffectsGroup(layer: any): any | null {
    try {
        return layer.property("ADBE Effect Parade") ?? null;
    } catch {
        return null;
    }
}

/** Shared by `applyEffectOnAllSelectedLayers` and `applyEffectOnAllSelectedClips`. */
async function applyEffect(effectName: string): Promise<boolean> {
    const layers = getSelectedLayers();
    if (layers.length === 0) return false;

    let applied = 0;
    await undoable("Apply Effect: " + effectName, () => {
        for (const layer of layers) {
            const effectsGroup = getEffectsGroup(layer);
            if (!effectsGroup) continue; // skip cameras/lights, etc.

            let newEffect: any;
            try {
                // "Transform" is the effect with the match name ADBE Geometry2
                newEffect = effectsGroup.addProperty(effectName === "Transform" ? "ADBE Geometry2" : effectName);
            } catch (e) {
                console.log(`effect not found or could not be applied: "${effectName}" (layer "${layer.name}"):`, e);
                continue;
            }
            if (!newEffect) {
                console.log(`effect lookup succeeded but nothing was added for: "${effectName}"`);
                continue;
            }
            applied++;

            // a freshly added Transform effect should have "Uniform Scale" enabled
            if (effectName === "Transform") {
                try {
                    newEffect.property("Uniform Scale")?.setValue(true);
                } catch (e) {
                    console.log('could not enable "Uniform Scale":', e);
                }
            }
        }
    });
    return applied > 0;
}

/**
 * apply an effect to all selected layers. Adding "Transform" also turns on its "Uniform Scale"
 * @param {string} [effectName] the display name or match name of the effect, e.g. "Gaussian Blur" or "ADBE Gaussian Blur 2"
 * @returns {boolean} true if the effect was added to at least one layer
 */
export async function applyEffectOnAllSelectedLayers(effectName: string): Promise<boolean> {
    return applyEffect(effectName);
}

/**
 * same as applyEffectOnAllSelectedLayers, under the name the CEP version of AERemote used
 * @param {string} [effectName] the display name or match name of the effect, e.g. "Gaussian Blur" or "ADBE Gaussian Blur 2"
 * @returns {boolean} true if the effect was added to at least one layer
 */
export async function applyEffectOnAllSelectedClips(effectName: string): Promise<boolean> {
    return applyEffect(effectName);
}

/** Shared by `listEffectsOnSelectedLayer` and `listEffectsOnSelectedClip`. */
function listEffects(): string {
    if (!getActiveComp()) return "ERROR: no active composition";
    const [layer] = getSelectedLayers();
    if (!layer) return "ERROR: no layer selected";

    const effectsGroup = getEffectsGroup(layer);
    if (!effectsGroup) return "ERROR: selected layer type has no effects";

    let text = `Effects on layer "${layer.name}":\n`;
    for (let i = 1; i <= effectsGroup.numProperties; i++) {
        const effect = effectsGroup.property(i);
        text += `${i}: ${effect.name} (matchName: ${effect.matchName})\n`;
    }
    return text;
}

/**
 * list all effects on the first selected layer, one per line
 * @returns {string}
 */
export async function listEffectsOnSelectedLayer(): Promise<string> {
    return listEffects();
}

/**
 * same as listEffectsOnSelectedLayer, under the name the CEP version of AERemote used
 * @returns {string}
 */
export async function listEffectsOnSelectedClip(): Promise<string> {
    return listEffects();
}

/**
 * copies the anchor point of the single selected layer's "Transform" effect into that effect's position. Does nothing (returns false) unless exactly one layer is selected and it has exactly one Transform effect
 * @returns {boolean}
 */
export async function anchorToPosition(): Promise<boolean> {
    const layers = getSelectedLayers();
    if (layers.length !== 1) return false;

    const effectsGroup = getEffectsGroup(layers[0]);
    if (!effectsGroup) return false;

    const transforms: any[] = [];
    for (let i = 1; i <= effectsGroup.numProperties; i++) {
        const effect = effectsGroup.property(i);
        if (effect.matchName === "ADBE Geometry2" || effect.name === "Transform") transforms.push(effect);
    }
    if (transforms.length !== 1) return false;

    let anchorPoint: any = null;
    let position: any = null;
    for (let p = 1; p <= transforms[0].numProperties; p++) {
        const prop = transforms[0].property(p);
        if (prop.name === "Anchor Point") anchorPoint = prop;
        else if (prop.name === "Position") position = prop;
    }
    if (!anchorPoint || !position) return false;

    const value = anchorPoint.value;
    const copy = typeof value === "object" && value !== null ? Array.from(value as ArrayLike<number>) : value;
    await undoable("Sync Transform Anchor to Position", () => position.setValue(copy));
    return true;
}

/**
 * sets the zoom of the active viewer
 * @param {number} [zoom] a percentage from 1 to 1600
 * @returns {boolean}
 */
export async function setViewerZoom(zoom: number): Promise<boolean> {
    if (!Number.isFinite(zoom) || zoom < 1 || zoom > 1600) return false;
    try {
        const viewer = app.activeViewer;
        if (!viewer) return false;

        viewer.setActive();
        viewer.views[0].options.zoom = zoom / 100; // the API takes a normalized value (1.0 = 100%)
        return true;
    } catch (e) {
        console.log("could not set the viewer zoom:", e);
        return false;
    }
}

/**
 * replaces the source of every layer (in all other comps) that uses one of the target comps with a different comp. Throws if the replacement comp can't be found
 * @param {string} [targetNames] a comma delimitted list of all pre-comp names you wish to replace
 * @param {string} [sequenceName] the name of the sequence you wish to replace the targets with
 * @returns {number} how many layers were replaced
 */
export async function replaceSeqWithSequence(targetNames: string, sequenceName: string): Promise<number> {
    const targets = targetNames
        .split(",")
        .map((name) => name.trim())
        .filter((name) => name !== "");

    return undoable("Replace Linked Comps with " + sequenceName, () => {
        const project = app.project;

        let replacement: any = null;
        for (let i = 1; i <= project.numItems; i++) {
            const item = project.item(i);
            if (isCompItem(item) && item.name === sequenceName) {
                replacement = item;
                break;
            }
        }
        if (!replacement) throw new Error(`Couldn't find a comp named '${sequenceName}'.`);

        let count = 0;
        for (let c = 1; c <= project.numItems; c++) {
            const comp = project.item(c);
            if (!isCompItem(comp) || sameItem(comp, replacement)) continue;

            for (let l = 1; l <= comp.numLayers; l++) {
                const layer = comp.layer(l);
                let source: any;
                try {
                    source = layer.source; // not set on cameras, lights, ...
                } catch {
                    continue;
                }
                if (!isCompItem(source) || !targets.includes(source.name)) continue;

                try {
                    layer.replaceSource(replacement, true);
                    count++;
                } catch (e) {
                    console.log(`could not replace the source of layer "${layer.name}" in comp "${comp.name}":`, e);
                }
            }
        }
        return count;
    });
}

/**
 * return all effects available in After Effects, one per line as `category|displayName|matchName`
 * @returns {string}
 */
export async function listAllAvailableEffects(): Promise<string> {
    const effects: { displayName: string; matchName: string; category: string }[] =
        Array.from(app.effects ?? []);
    return effects.map((e) => `${e.category}|${e.displayName}|${e.matchName}`).join("\n");
}

/**
 * runs a menu command by its exact menu text, e.g. "Save" or "Duplicate". Lookup depends on the After Effects UI language; use executeCommand with a fixed id for something locale-proof
 * @param {string} [menuText] the text of the menu command exactly as shown in the UI
 * @returns {boolean} false if no such command exists
 */
export async function runMenuCommand(menuText: string): Promise<boolean> {
    const id = app.findMenuCommandId(menuText);
    if (!id) return false;
    return !!app.executeCommand(id);
}

/**
 * finds the id of a menu command, to be used with executeCommand. Returns 0 if not found
 * @param {string} [menuText] the text of the menu command exactly as shown in the UI
 * @returns {number}
 */
export async function findMenuCommandId(menuText: string): Promise<number> {
    return app.findMenuCommandId(menuText) ?? 0;
}

/**
 * runs a menu command by its numeric id (find ids with findMenuCommandId during setup, then hard-code them)
 * @param {number} [commandId] the command id
 * @returns {boolean}
 */
export async function executeCommand(commandId: number): Promise<boolean> {
    if (!Number.isInteger(commandId) || commandId <= 0) return false;
    return !!app.executeCommand(commandId);
}
