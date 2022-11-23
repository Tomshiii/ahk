/**
 * This function turns the inbuilt function `SplitPath` into a function that returns an object.
 *
 * Example Dir;
 * `E:\Github\ahk\My Scripts.ahk`
 *
 * script.`Name`       -- `My Scripts.ahk`
 *
 * script.`Dir`        -- `E:\Github\ahk`
 *
 * script.`Ext`        -- `ahk`
 *
 * script.`NameNoExt`  -- `My Scripts`
 *
 * script.`Drive`        -- `E:`
 * @param {any} Path is the input path that will be split
 * @returns {object} `x.path` - `x.name` - `x.dir` - `x.ext` - `x.namenoext` - `x.drive`
 */
SplitPathObj(Path) {
    SplitPath(Path, &Name, &Dir, &Ext, &NameNoExt, &Drive)
    return {Name: Name, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}