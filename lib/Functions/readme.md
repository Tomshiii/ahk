# Info
This directory is to separate out most of the functions I use for various things. All of these functions use to be in various bigger ahk files, but it was getting way too large for its own good and was becoming a bit too much of a hassle to work with and find what I was looking for.

If one of these functions is needed within another script you will see `#Include <\Functions\func>` at the top of the script

A function is defined similar to;
```autohotkey
/**
 * These are comments that dynamically display information when displayed in VSCode,
 but also serve as general comments for anyone else
 *
 * This function does something
 * @param {Any} variableX is a value you pass into the function
 * @param {VarRef} variableY is a variable who's value will be passed back once the function is complete
 * @param {String} variableZ is a variable with a default value, it can be omitted
 */
func(variableX, &variableY, variableZ := "default")
{
  if variableX = Y
    return
  ...
  variableY := "value"
  if variableZ != "default"
    code(variableZ)
}
```
We then [`#Include`](https://lexikos.github.io/v2/docs/commands/_Include.htm) the function file in other scripts so we can achieve things like below;
```autoit
#Include <\Functions\func>
hotkey::
{
  func("variableValue", &variableYbutCalledAnything)
  ...
  MsgBox(variableYbutCalledAnything)
}
```
Note:
- `variableZ` doesn't have to be used and can be omitted from the function call
- An example of a function in this repo that passes back a variable & also uses defaults is [`isFullscreen()`](https://github.com/Tomshiii/ahk/blob/main/lib/Functions/Windows.ahk)

Functions can also be definied within a `class` and are called differently depending on how that class is structured. Most of the functions within my classes are defined as `static` functions which means we call the function like so;
```c++
class funcs {
    static example() {
        ...
    }

    nonstatic() {
        ...
    }
}
// To call the static func
funcs.example()

// To call the non static func
newDefinition := funcs()
newDefinition.nonstatic() // calls the func

```