; { \\ #Includes
#Include <Classes\Settings>
#Include <GUIs\tomshiBasic>
#Include <Classes\dark>
#Include <Classes\ptf>
;

/**
 * This function calls a GUI help guide the user on what to do now that they've gotten `My Scripts.ahk` to run. This function is called during firstCheck()
 */
todoGUI()
{
    if WinExist("What to Do - Tomshi Scripts")
        return
    todoGUI := tomshiBasic(,, "-Resize AlwaysOnTop", "What to Do - Tomshi Scripts")
	Title := todoGUI.Add("Text", "H30 X8 W300", "What to Do")
    Title.SetFont("S15")

    bodyText := todoGUI.Add("Text","X8 W550 Center", Format("
    (
        1. Once you've saved these scripts wherever you wish (the default value is ``E:\Github\ahk\`` if you want all the directory information to just line up without any editing) but if you wish to use a custom directory, my scripts should automatically adjust these variables when you run ``My Scripts.ahk`` (so if you're reading this, your directory should be ``{}``
             // do note; some ``Streamdeck AHK`` scripts still have other hard coded dir's as they are intended for my workflow and may error out if you try to run them. //

        2. Take a look at ``Keyboard Shortcuts.ini`` to set your own keyboard shortcuts for programs as well as define coordinates for a few remaining ImageSearches that cannot use variables for various reasons. These ``KSA`` values are used to allow for easy adjustments instead of needing to dig through scripts!

        3. Take a look at ``ptf.ahk`` in the class ``class ptf {`` to adjust all assigned filepaths!

        4. You can then edit and run any of the .ahk files to use to your liking!
    )", A_WorkingDir))
    closeButton := todoGUI.Add("Button", "x+-90 y+10", "Close")
    closeButton.OnEvent("Click", close)

    todoGUI.OnEvent("Escape", close)
    todoGUI.OnEvent("Close", close)
    close(*) => todoGUI.Destroy()

    todoGUI.Show()
}