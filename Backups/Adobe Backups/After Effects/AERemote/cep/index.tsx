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

  /**
   * @swagger
   * /yourNewFunction?param1={param1}&param2={param2}:
   *      get:
   *          description: Your new function, ready to be called!
   *          parameters:
   *              - name: param1
   *                description: Just a sample parameter
   *                in: path
   *                type: string
   *              - name: param2
   *                description: Just another sample parameter
   *                in: path
   *                type: string
   */
  yourNewFunction: function (param1, param2) {
    alert(param1 + " " + param2);
  },

  save: function () {
    return app.project.save();
  },

  applyEffectOnAllSelectedClips: function (effectName: string) {
    const comp = app.project.activeItem;
    if (!(comp && comp instanceof CompItem)) {
      alert("No active composition.");
      return false;
    }

    const selectedLayers = comp.selectedLayers;
    if (selectedLayers.length === 0) {
      alert("No layers selected.");
      return false;
    }

    app.beginUndoGroup("Apply Effect: " + effectName);

    for (let i = 0; i < selectedLayers.length; i++) {
      const layer = selectedLayers[i];

      if (!(layer instanceof AVLayer)) continue; // skip cameras/lights, etc.

      const effectsGroup = layer.property("ADBE Effect Parade") as PropertyGroup;
      if (!effectsGroup) continue;

      let newEffect: PropertyGroup | null = null;
      try {
        switch (effectName) {
          case "Transform":
            newEffect = effectsGroup.addProperty("ADBE Geometry2") as PropertyGroup;
            break;
          default:
            newEffect = effectsGroup.addProperty(effectName) as PropertyGroup;
            break;
        }

      } catch (e) {
        alert("Effect not found or could not be applied: " + effectName);
        continue;
      }

      if (!newEffect) {
        alert("Effect lookup succeeded but nothing was actually added for: " + effectName);
        continue;
      }

      switch (effectName) {
        case "Transform": {
          const uniformProp = (newEffect as PropertyGroup).property("Uniform Scale") as Property<BooleanType>;
          if (uniformProp) uniformProp.setValue(true);
          break;
        }
      }
    }

    app.endUndoGroup();
    return true;
  },

  listEffectsOnSelectedClip: function () {
    const comp = app.project.activeItem;
    if (!(comp && comp instanceof CompItem)) {
      alert("No active composition.");
      return;
    }

    const selectedLayers = comp.selectedLayers;
    if (selectedLayers.length === 0) {
      alert("No layer selected");
      return;
    }

    const layer = selectedLayers[0];
    if (!(layer instanceof AVLayer)) {
      alert("Selected layer type has no effects.");
      return;
    }

    const effectsGroup = layer.property("ADBE Effect Parade") as PropertyGroup;
    if (!effectsGroup) {
      alert("No effects group found on this layer.");
      return;
    }

    let effectsList = "Effects on layer \"" + layer.name + "\":\n";

    for (let i = 1; i <= effectsGroup.numProperties; i++) {
      const effect = effectsGroup.property(i) as PropertyGroup;
      effectsList += i + ": " + effect.name + " (matchName: " + effect.matchName + ")\n";
    }

    alert(effectsList);
  },

  syncTransformAnchorToPosition: function (): boolean {
    const comp = app.project.activeItem;
    if (!(comp && comp instanceof CompItem)) {
      return false;
    }

    const selectedLayers = comp.selectedLayers;

    // bail if nothing or more than one layer selected
    if (selectedLayers.length === 0 || selectedLayers.length > 1) {
      return false;
    }

    const layer = selectedLayers[0];
    if (!(layer instanceof AVLayer)) {
      return false;
    }

    const effectsGroup = layer.property("ADBE Effect Parade") as PropertyGroup;
    if (!effectsGroup) {
      return false;
    }

    // find all "Transform" effects on the layer
    const transformEffects: PropertyGroup[] = [];
    for (let i = 1; i <= effectsGroup.numProperties; i++) {
      const effect = effectsGroup.property(i) as PropertyGroup;
      if (effect.name === "Transform") {
        transformEffects.push(effect);
      }
    }

    // bail if no or more than one Transform effect
    if (transformEffects.length === 0 || transformEffects.length > 1) {
      return false;
    }

    const transform = transformEffects[0];
    let anchorPointProp: Property<TwoDType | ThreeDType> | null = null;
    let positionProp: Property<TwoDType | ThreeDType> | null = null;

    for (let p = 1; p <= transform.numProperties; p++) {
      const prop = transform.property(p) as Property<TwoDType | ThreeDType>;
      if (prop.name === "Anchor Point") {
        anchorPointProp = prop;
      } else if (prop.name === "Position") {
        positionProp = prop;
      }
    }

    if (!anchorPointProp || !positionProp) {
      return false;
    }

    const anchorValue = anchorPointProp.value;

    app.beginUndoGroup("Sync Transform Anchor to Position");
    positionProp.setValue(anchorValue);
    app.endUndoGroup();

    return true;
  },

  isSelected: function (): boolean {
    const comp = app.project.activeItem;
    if (!(comp && comp instanceof CompItem)) {
      return false;
    }

    return comp.selectedLayers.length > 0;
  },

  isSelectedMultiple: function (): boolean {
    const comp = app.project.activeItem;
    if (!(comp && comp instanceof CompItem)) {
      return false;
    }

    return comp.selectedLayers.length > 1;
  }
};
