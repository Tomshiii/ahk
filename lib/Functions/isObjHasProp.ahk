/** */
isObjHasProp(obj, prop, bool) {
    return (IsObject(obj) && obj.HasProp(prop) && obj.%prop% != "" && obj.%prop% != bool)
}