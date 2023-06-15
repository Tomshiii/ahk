/************************************************************************
 * @description A handy GUI to give a visual indication of whether some hotkeys/functions will focus the timeline
 * @author tomshi
 * @date 2023/06/15
 * @version 1.0.1
 ***********************************************************************/
; { \\ #Includes
#Include <Classes\Editors\Premiere>
#Include <Classes\ptf>
#Include <Classes\settings>
; }

ListLines(0)
class premTimelineGUI {
	timelineFocusGUI := ""
	guiTitle         := "timelineFocusStatus GUI"
	guiHiddenTitle   := "timelineFocusStatus GUI_hidden"

	checkGUITimer    := ObjBindMethod(this, '__checkGUI')
	show_hide        := ObjBindMethod(this, '__show_hide')
	callGUI          := ObjBindMethod(this, '__callGUI')

	/**
	 * this function acts as a timer determining when to generate & show the GUI
	 */
	__callGUI() {
		if !WinExist(prem.winTitle)
			return
		if this.timelineFocusGUI = ""
			this.__defGUI(prem.focusTimelineStatus)
		if (prem.timelineXValue = 0 || prem.timelineYValue = 0 || prem.timelineXControl = 0 || prem.timelineYControl = 0)
			return
		this.__showGUI({x: prem.timelineXControl - 124, y: prem.timelineYValue - 5})
		SetTimer(this.checkGUITimer.Bind(prem.focusTimelineStatus), 100)
		SetTimer(this.show_hide, 100)
		SetTimer(, 0)
		return
	}

	/**
	 * This function facilitates showing/hiding the GUI as the user moves to/from premiere.
	 *
	 * This function will also handle destroying the GUI once premiere has been closed
	 */
	__show_hide() {
		if !WinExist(prem.exeTitle) {
			SetTimer(, 0)
			this.timelineFocusGUI.Destroy()
			this.timelineFocusGUI := ""
			return
		}
		if this.timelineFocusGUI = ""
			return
		if (!WinActive(prem.exeTitle) && !WinActive(this.guiTitle)) && this.timelineFocusGUI.title != this.guiHiddenTitle {
			this.timelineFocusGUI.Hide()
			this.timelineFocusGUI.title := this.guiHiddenTitle
			return
		}
		if WinActive(prem.exeTitle) && this.timelineFocusGUI.title == this.guiHiddenTitle {
			this.timelineFocusGUI.Show("NoActivate")
			this.timelineFocusGUI.title := "timelineFocusStatus GUI"
			return
		}
	}

	/**
	 * checks whether the current icon is accurate or needs to be recreated
	 */
	__checkGUI(previousState) {
		if previousState = prem.focusTimelineStatus
			return
		this.timelineFocusGUI.Destroy()
		this.timelineFocusGUI := ""
		SetTimer(this.callGUI, 100)
		SetTimer(, 0)
		return
	}

	/**
	 * This function will generate the GUI required to show whether timeline focusing is enabled or disabled
	 * @param {Boolean} enabled_or_disabled whether to initally show the enabled or disabled icon
	 */
	__defGUI(enabled_or_disabled := true) {
		this.timelineFocusGUI := Gui("AlwaysOnTop ToolWindow", this.guiTitle)
		this.timelineFocusGUI.BackColor := "EEAA99"

		;// base path for icons
		basePath := ptf.Icons "\"
		;// define which image to load
		path := (enabled_or_disabled = true) ? basePath "premKey.png" : basePath "premKey_disabled.png"
		;// add the image
		this.timelineFocusGUI.AddPicture("w18 h-1", path)
	}

	/**
	 * shows the GUI
	 * @param {Object} coords the x/y coordinates `{x: 0, y:0}`
	 */
	__showGUI(coords) {
		coord.s()
		this.timelineFocusGUI.Show(Format("x{} y{} NoActivate", coords.x, coords.y))
		WinSetTransColor("EEAA99", this.timelineFocusGUI.Title)
		this.timelineFocusGUI.Opt("-Caption")
	}

}

;// check user's settings.ini file and see whether they want the gui to spawn
UserSettings := UserPref()
if UserSettings.prem_Focus_Icon = true {
	timerSet := ObjBindMethod(premTimelineGUI(), '__callGUI')
	SetTimer(timerSet, 2000)
}
UserSettings.__delAll()
UserSettings := ""