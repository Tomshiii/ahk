#Requires AutoHotkey v2.0
#SingleInstance

#include Notify.ahk
#Include '.\Lib\GuiCtrlTips.ahk'
#Include '.\Lib\LV_GridColor.ahk'
#Include '.\Lib\GuiButtonIcon.ahk'
#Include '.\Lib\ColorPicker.ahk'
#Include '.\Lib\Color.ahk'

/********************************************************************************************
 * Notify Creator - Explore all customization settings of the Notify class, create themes, generate ready-to-copy code snippets, and more.
 * @author Martin Chartier (XMCQCX)
 * @date 2025/04/09
 * @version 1.3.0
 * @see {@link https://github.com/XMCQCX/NotifyClass-NotifyCreator GitHub}
 * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=129635 AHK Forum}
 * @license MIT license
 * @credits
 * - JSON by thqby, HotKeyIt. {@link https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk GitHub}
 * - GuiCtrlTips by just me. {@link https://github.com/AHK-just-me/AHKv2_GuiCtrlTips GitHub}
 * - LVGridColor by just me. {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=125259 AHK Forum}
 * - GuiButtonIcon by FanaticGuru. {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=115871 AHK Forum}
 * - YACS - Yet Another Color Selector by Komrad Toast. {@link https://github.com/tylerjcw/YACS GitHub}
 * - FontPicker by Maestrith, TheArkive (v2 conversion). {@link https://github.com/TheArkive/FontPicker_ahk2 GitHub}
 * - ColorPicker by Maestrith, TheArkive (v2 conversion). {@link https://github.com/TheArkive/ColorPicker_ahk2 GitHub}
 * - GetFontNames by teadrinker. {@link https://www.autohotkey.com/boards/viewtopic.php?t=66000 AHK Forum}
 * - DisplayCheck by the-Automator. {@link https://www.the-automator.com/downloads/maestrith-notify-class-v2 the-automator.com}
 * - MoveControls by Descolada. {@link https://github.com/Descolada/UIA-v2 GitHub}
 * - Control_GetFont by SKAN, swagfag.
 *   - {@link https://www.autohotkey.com/board/topic/66235-retrieving-the-fontname-and-fontsize-of-a-gui-control AHK Forum}
 *   - {@link https://www.autohotkey.com/boards/viewtopic.php?t=113540 AHK Forum}
********************************************************************************************/
Class NotifyCreator {

    static __New()
    {
        this.scriptName := 'Notify Creator'
        this.scriptVersion := 'v1.3.0'
        this.linkGitHubRepo := 'https://github.com/XMCQCX/NotifyClass-NotifyCreator'
        this.gMainTitle := this.scriptName ' - ' this.scriptVersion
        this.gRipTitle := 'ResIconsPicker - ' this.scriptName

        if !FileExist('Icons.dll')
            MsgBox('The application can`'t start because "Icons.dll" is missing.`n`nThe application will terminate.', 'Missing DLL file - ' this.scriptName, 'Iconx'), ExitApp()

        this.mDefaults := this.MapCI().Set(
            'title', 'My Title',
            'msg', 'The quick brown fox jumps over the lazy dog.',
            'theme', Notify.mDefaults['theme'],
            'savedColors', ['0xFFA500', '0xFFC0CB', '0xA52A2A', '0xFFD700', '0x40E0D0', '0xFF7F50', '0xE6E6FA', '0x4B0082'],
            'aSoundHistory', Array(),
            'aImageHistory', [
                'C:\Windows\System32\imageres.dll|icon84',
                'C:\Windows\System32\imageres.dll|icon234',
                'C:\Windows\System32\imageres.dll|icon244',
                'C:\Windows\System32\shell32.dll|icon4',
                'C:\Windows\System32\shell32.dll|icon259',
                'C:\Windows\System32\shell32.dll|icon261',
                'C:\Windows\System32\user32.dll|icon7'],
            'trayMenuIconSize', 24,
            'openMainOnStart', 0,
            'closeMainExitApp', 0,
            'soundOnSelection', 0,
        )

        this.debounceTimers := Map()
        this.arrStyle := ['Round', 'Edge']
        this.arrAli := ['Left', 'Right', 'Center']
        this.arrPos := ['TL', 'TC', 'TR', 'CTL', 'CT', 'CTR', 'BL', 'BC', 'BR', 'Mouse']
        this.arrBgImgPos := ['', 'Stretch', 'TL', 'TC', 'TR', 'CTL', 'CT', 'CTR', 'BL', 'BC', 'BR', 'ct Scale1.5', 'w50 hStretch', 'tr w20 h-1 ofstx-10 ofsty10']
        this.arrProg := ['', 1, 'h40 cGreen', 'w400']
        this.arrWstc := ['', 'bc=black wstc=black', 'bc=gray wstc=gray']
        this.arrDg := [0, 1, 2, 3, 4, 5]
        this.arrTrayMenuIconSize := [16, 20, 24, 28, 32]
        this.arrAhkColors := this.MapToArray(Notify.mAHKcolors)
        this.arrFontNames := this.MapToArray(this.GetFontNames())
        this.arrTheme := this.MapToArray(Notify.mThemes)
        this.arrImage := this.MapToArray(Notify.mImages), this.arrImage.InsertAt(1, 'None')
        this.arrSound := this.MapToArray(Notify.mSounds), this.arrSound.InsertAt(1, 'None')
        this.arrBdrColors := this.MapToArray(Notify.mAHKcolors), this.arrBdrColors.InsertAt(1, 'Default')
        this.arrAnimDur := this.CreateIncrementalArray(25, 25, Notify.arrAnimDurRange[2]), this.arrAnimDur.InsertAt(1, Notify.arrAnimDurRange[1])
        this.arrWstp := this.CreateIncrementalArray(1, 100, 255)
        this.arrAnimRoundShow := ['Fade']
        this.arrAnimRoundHide := ['None', 'Fade']
        this.arrAnimEdge := ['None', 'Fade','Expand','SlideEast','SlideWest','SlideNorth','SlideSouth', 'SlideNorthEast',
            'SlideNorthWest', 'SlideSouthEast', 'SlideSouthWest', 'RollEast', 'RollWest', 'RollNorth',
            'RollSouth', 'RollNorthEast', 'RollNorthWest', 'RollSouthEast', 'RollSouthWest']
        this.arrFontSizeRange := [1,250]
        this.arrDurationRange := [0,999]
        this.arrImageDimRange := [-1,999]
        this.arrGuiDimRange := [1,999]

        ;==============================================
        this.arrOptsBasic := ['tc', 'mc', 'bc', 'tf', 'mf', 'bdr']

        this.arrOpts := [
            ['Monitor', 'mon'],
            ['Position', 'pos'],
            ['Duration', 'dur'],
            ['Style', 'style'],
            ['Title size', 'ts'],
            ['Title color', 'tc'],
            ['Title font', 'tf'],
            ['Title font options', 'tfo'],
            ['Title alignment', 'tali'],
            ['Message size', 'ms'],
            ['Message color', 'mc'],
            ['Message font', 'mf'],
            ['Message font options', 'mfo'],
            ['Message alignment', 'mali'],
            ['Background color', 'bc'],
            ['Border', 'bdr'],
            ['Sound', 'sound'],
            ['Image', 'image'],
            ['Image width', 'iw'],
            ['Image height', 'ih'],
            ['Background image', 'bgImg'],
            ['Background image position', 'bgImgPos'],
            ['Padding/Margins', 'pad'],
            ['Maximum width', 'maxW'],
            ['Width' ,'width'],
            ['Minimum height' ,'minH'],
            ['Progress bar', 'prog'],
            ['Tag', 'tag'],
            ['Destroy GUI click', 'dgc'],
            ['Destroy GUIs', 'dg'],
            ['Destroy GUI block', 'dgb'],
            ['Destroy GUI animation', 'dga'],
        ]

        ;==============================================

        this.arrIcons := Array()
        this.arrIconPaths := [
            'C:\Windows\System32\imageres.dll',
            'C:\Windows\System32\shell32.dll',
            'C:\Windows\System32\user32.dll',
            'C:\Windows\System32\netshell.dll',
            'C:\Windows\System32\wmploc.dll',
            'C:\Windows\System32\ddores.dll',
            'C:\Windows\System32\mmcndmgr.dll',
            'C:\Windows\System32\moricons.dll',
            'C:\Windows\System32\ieframe.dll',
            'C:\Windows\System32\compstui.dll',
            'C:\Windows\System32\setupapi.dll',
            'C:\Windows\System32\inetcpl.cpl',
            'C:\Windows\System32\synccenter.dll',
            'C:\Windows\System32\pnidui.dll',
            'C:\Windows\System32\pifmgr.dll',
            'C:\Windows\System32\dsuiext.dll',
            'C:\Windows\System32\msihnd.dll',
            'C:\Windows\explorer.exe',
            'C:\Windows\System32\taskmgr.exe',
            'C:\Windows\System32\stobject.dll',
            'C:\Windows\System32\rasgcw.dll',
            'C:\Windows\System32\mshtml.dll',
            'C:\Windows\System32\msctf.dll',
            'C:\Windows\System32\msutb.dll',
            'C:\Windows\System32\cryptui.dll',
            'C:\Windows\System32\accessibilitycpl.dll',
            'C:\Windows\System32\SensorsCpl.dll',
            'C:\Windows\System32\wpdshext.dll',
            'C:\Windows\System32\wiashext.dll',
            'C:\Windows\System32\rasdlg.dll',
            'C:\Windows\System32\twinui.dll',
            'C:\Windows\System32\dmdskres.dll',
            'C:\Windows\System32\comres.dll',
            'C:\Windows\System32\ipsmsnap.dll',
            'C:\Windows\System32\mstsc.exe',
            'C:\Windows\System32\networkexplorer.dll',
            'C:\Windows\System32\comdlg32.dll',
            'C:\Windows\System32\portabledevicestatus.dll',
            'C:\Windows\System32\urlmon.dll',
            'C:\Windows\System32\mmres.dll',
            'C:\Windows\System32\localsec.dll',
            'C:\Windows\System32\certmgr.dll',
            'C:\Windows\System32\azroleui.dll',
            'C:\Windows\System32\main.cpl',
            'C:\Windows\System32\wiadefui.dll',
            'C:\Windows\System32\mssvp.dll',
            'C:\Windows\System32\mstscax.dll',
            'C:\Windows\System32\connect.dll',
            'C:\Windows\System32\prnfldr.dll',
            'C:\Windows\System32\netcenter.dll',
            'C:\Windows\System32\objsel.dll',
            'C:\Windows\System32\sndvolsso.dll',
            'C:\Windows\System32\dxptasksync.dll',
            'C:\Windows\System32\fontext.dll',
            'C:\Windows\System32\mmcbase.dll',
            'C:\Windows\System32\psr.exe',
            'C:\Windows\System32\quartz.dll',
            'C:\Windows\System32\wmp.dll',
            'C:\Windows\System32\colorui.dll',
            'C:\Windows\System32\fdprint.dll',
            'C:\Windows\System32\eudcedit.exe',
            'C:\Windows\System32\imagesp1.dll',
            'C:\Windows\System32\mmsys.cpl',
            'C:\Windows\System32\msdt.exe',
            'C:\Windows\System32\printui.dll',
            'C:\Windows\System32\hnetcfg.dll',
            'C:\Windows\System32\scrptadm.dll',
            'C:\Windows\System32\webcheck.dll',
            'C:\Windows\System32\wininetlui.dll',
            'C:\Windows\System32\wlangpui.dll',
            'C:\Windows\System32\wlanpref.dll',
            'C:\Windows\System32\ntshrui.dll',
            'C:\Windows\System32\actioncentercpl.dll',
            'C:\Windows\System32\devmgr.dll',
            'C:\Windows\System32\els.dll',
            'C:\Windows\System32\netplwiz.dll',
            'C:\Windows\System32\aclui.dll',
            'C:\Windows\System32\url.dll',
            'C:\Windows\System32\filemgmt.dll',
            'C:\Windows\System32\comctl32.dll',
            'C:\Windows\System32\ncpa.cpl',
            'C:\Windows\System32\autoplay.dll',
            'C:\Windows\System32\xwizards.dll'
        ]

        ;==============================================

        for value in ['mThemes', 'mOrig_mThemes'] {
            for theme, mtheme in Notify.%value% {
                if (value == 'mThemes') {
                    Notify.SetDefault_MiscValues(mTheme)

                    if !mTheme.Has('bdr') || RegExMatch(mTheme['bdr'], 'i)^(default|1|0)$')
                        mTheme['bdrC'] := 'default'

                    mTheme['bdrW'] := mTheme.Get('bdrW', Notify.bdrWdefaultEdge)
                }

                Notify.ParsePadOption(mTheme)
                Notify.NormAllColors(mTheme)

                for value in ['sound', 'image']
                    if mTheme.Has(value) && !this.HasVal(mTheme[value], this.arr%value%)
                        this.arr%value%.Push(mTheme[value])

                if mTheme.Has('bgImg') && !this.HasVal(mTheme['bgImg'], this.arrImage)
                    this.arrImage.Push(mTheme['bgImg'])

                if mTheme.Has('bgImgPos') && !this.HasVal(mTheme['bgImgPos'], this.arrBgImgPos)
                    this.arrBgImgPos.Push(mTheme['bgImgPos'])
            }
        }

        for value in ['sound', 'image'] {
            this.arr%value%Notify := Array()

            for item in this.arr%value%
                this.arr%value%Notify.Push(item)
        }

        this.strImageExtfilter := 'Image ('

        for value in Notify.arrImageExt
            this.strImageExtfilter .= '*.' value '; '

        this.strImageExtfilter := SubStr(this.strImageExtfilter, 1, -2) . ')'

        ;==============================================

        this.mAnimDefStyle := this.MapCI()

        for style in this.arrStyle {
            this.mAnimDefStyle[style] := this.MapCI()
            for pos in this.arrPos {
                Notify.SetAnimationDefault(this.mAnimDefStyle[style][pos] := this.MapCI().Set('style', style, 'pos', pos))
                mKeyRef := this.mAnimDefStyle[style][pos]
                this.ConvertAnimHextoName(mKeyRef)
                this.CreateAnimationString(mKeyRef)
            }
        }

        ;==============================================

        if (FileExist('Settings.json')) {
            fileObj := FileOpen('Settings.json', 'r', 'UTF-8')
            this.mUser := _JSON_thqby.parse(fileObj.Read(), false, true) ; this.mUser CaseSense is On.
            fileObj.Close()
        }
        else this.mUser := Map()

        for key, value in this.mDefaults
            if !this.mUser.Has(key)
                this.mUser[key] := value

        if !Notify.mThemes.Has(this.mUser['theme'])
            this.mUser['theme'] := this.mDefaults['theme']

        for value in ['Image', 'Sound']
            for item in this.mUser['a' value 'History']
                if !this.Hasval(item, this.%'arr' value%)
                    this.%'arr' value%.Push(item)

        for value in ['sound', 'image', 'theme']
            this.arr%value% := this.SortArray(this.arr%value%)

        this.mTools := Map(
            'autoHotkeyv2Help', Map('name', 'AutoHotkey v2 Help', 'path', A_ProgramFiles '\AutoHotkey\v2\AutoHotkey.chm'),
            'windowSpy', Map('name', 'WindowSpy', 'path', A_ProgramFiles '\AutoHotkey\WindowSpy.ahk')
        )

        this.mIcons := Map(
            'mainTray', 'HICON:*' LoadPicture('Icons.dll', 'Icon1 w32', &imageType),
            'mainAbout', 'HICON:*' LoadPicture('Icons.dll', 'Icon1 w64', &imageType),
            'colorPick', 'HICON:*' LoadPicture('Icons.dll', 'Icon31 w32', &imageType),
            'colorPicker', 'HICON:*' LoadPicture('Icons.dll', 'Icon32 w32', &imageType),
            'clipBoard', 'HICON:*' LoadPicture('Icons.dll', 'Icon24 w32', &imageType),
            'font', 'HICON:*' LoadPicture('Icons.dll', 'Icon33 w32', &imageType),
            'buymeacoffee', 'HICON:*' LoadPicture('Icons.dll', 'Icon48 w32', &imageType),
            'reset', 'HICON:*' LoadPicture('Icons.dll', 'Icon30 w32', &imageType),
            'musicNote', 'HICON:*' LoadPicture('Icons.dll', 'Icon34 w32', &imageType),
            'stopSound', 'HICON:*' LoadPicture('Icons.dll', 'Icon51 w32', &imageType),
            'destroy', 'HICON:*' LoadPicture('Icons.dll', 'Icon37 w64', &imageType),
            'test', 'HICON:*' LoadPicture('Icons.dll', 'Icon36 w64', &imageType),
            'delete', 'HICON:*' LoadPicture('Icons.dll', 'Icon19 w64', &imageType),
            'menuDelete', 'HICON:*' LoadPicture('Icons.dll', 'Icon19 w32', &imageType),
            'select', 'HICON:*' LoadPicture('Icons.dll', 'Icon11 w32', &imageType),
            'preview', 'HICON:*' LoadPicture('Icons.dll', 'Icon47 w32', &imageType),
            'transIcon', 'HICON:*' LoadPicture('Icons.dll', 'Icon38 w32', &imageType),
            'monInfo', 'HICON:*' LoadPicture('Icons.dll', 'Icon40 w32', &imageType),
            'gitHub', 'HICON:*' LoadPicture('Icons.dll', 'Icon28 w32', &imageType),
            'iSmall', 'HICON:*' LoadPicture('Icons.dll', 'Icon49 w24', &imageType),
            'removeList', 'HICON:*' LoadPicture('Icons.dll', 'Icon41 w32', &imageType),
            'unCheckAll', 'HICON:*' LoadPicture('Icons.dll', 'Icon13 w32', &imageType),
            'checkAll', 'HICON:*' LoadPicture('Icons.dll', 'Icon14 w32', &imageType),
            'selectAll', 'HICON:*' LoadPicture('Icons.dll', 'Icon43 w32', &imageType),
            'profile', 'HICON:*' LoadPicture('Icons.dll', 'Icon10 w32', &imageType),
            'btn_about', 'HICON:*' LoadPicture('Icons.dll', 'Icon5 w32', &imageType),
            'btn_settings', 'HICON:*' LoadPicture('Icons.dll', 'Icon6 w32', &imageType),
            'btn_gRip', 'HICON:*' LoadPicture('Icons.dll', 'Icon42 w32', &imageType),
            'notifgRip', 'HICON:*' LoadPicture('Icons.dll', 'Icon42 w64', &imageType),
            'add', 'HICON:*' LoadPicture('Icons.dll', 'Icon18 w32', &imageType),
            'btn_edit', 'HICON:*' LoadPicture('Icons.dll', 'Icon7 w32', &imageType),
            'floppy', 'HICON:*' LoadPicture('Icons.dll', 'Icon25 w32', &imageType),
            '!', 'HICON:*' LoadPicture('Icons.dll', 'Icon23 w32', &imageType),
            'info', 'HICON:*' LoadPicture('Icons.dll', 'Icon20 w32', &imageType),
            'resetTheme', 'HICON:*' LoadPicture('Icons.dll', 'Icon44 w32', &imageType),
            'checkTheme', 'HICON:*' LoadPicture('Icons.dll', 'Icon45 w32', &imageType),
            'checkBasic', 'HICON:*' LoadPicture('Icons.dll', 'Icon46 w32', &imageType),
            'clipBoard', 'HICON:*' LoadPicture('Icons.dll', 'Icon24 w64', &imageType),
            'resIconsPicker', 'HICON:*' LoadPicture('Icons.dll', 'Icon42 w' this.mUser['trayMenuIconSize'], &imageType),
            'tMenuTrans', 'HICON:*' LoadPicture('Icons.dll', 'Icon16 w' this.mUser['trayMenuIconSize'], &imageType),
            'dark-gradient', 'HICON:*' LoadPicture('Icons.dll', 'Icon50', &imageType),
        )

        for value in ['main', 'loading', 'exit', 'reload', 'about', 'settings', 'edit', 'folder', 'tools']
            this.mIcons[value] := 'HICON:*' LoadPicture('Icons.dll', 'Icon' A_Index ' w' this.mUser['trayMenuIconSize'], &imageType)

        ;==============================================

        this.strOpts := ''
        for key, value in Notify.mOrig_mDefaults
            if !RegExMatch(key, 'i)^(tc|mc|bc|bdr|image|maxw|bgImg)$')
                this.strOpts .= key '=' value ' '

        this.strOpts .= 'maxw=425 bgImg=' this.mIcons['dark-gradient'] ' '

        ;==============================================

        HotIfWinExist('NotifyGUI_0 ahk_class AutoHotkeyGUI')
        Hotkey('Esc', (*) => Notify.Destroy())
        HotIfWinExist()

        HotIf this.gList_lv_Active.Bind(this)
        Hotkey('Del', this.gList_lv_Remove.Bind(this, 'hotkey'))
        Hotkey('^a', this.gList_lv_SelectAll.Bind(this))
        HotIf

        ;==============================================

		this.Create_TrayMenu()
        this.SetIconTip()
        OnMessage(0x404, this.AHK_NOTIFYICON.Bind(this))
        OnExit(this.OnExit.Bind(this))

		if this.mUser['openMainOnStart']
            this.gMain_Show()
    }

    ;============================================================================================

    static OnExit(exitReason, exitCode) => this.SaveToJSON()

    ;============================================================================================

    static SaveToJSON()
    {
        for value in ['Image', 'Sound'] {
            this.mUser['a' value 'History'] := Array()

            for item in this.arr%value%
                if item != 'none' && !this.HasVal(item, this.arr%value%Notify)
                    this.mUser['a' value 'History'].Push(item)
        }

        str := _JSON_thqby.stringify(this.mUser, expandlevel := unset, space := "  ")
        objFile := FileOpen('Settings.json', 'w', 'UTF-8')
        objFile.Write(str)
        objFile.Close()
    }

    ;============================================================================================

    static Create_TrayMenu()
    {
        A_TrayMenu.Delete()
        A_TrayMenu.Add(this.scriptName, this.gMain_Show.Bind(this))
        A_TrayMenu.Add('ResIconsPicker', this.gRip_Show.Bind(this))
        A_TrayMenu.Add('Open Application Folder', (*) => Run(A_ScriptDir))
        A_TrayMenu.Add('Tools', this.trayMenuTools := Menu())
        A_TrayMenu.Add('Settings', this.gSettings_Show.Bind(this))
        A_TrayMenu.Add('About', this.gAbout_Show.Bind(this))
        A_TrayMenu.Add('Reload', (*) => Reload())
        A_TrayMenu.Add('Exit', (*) => ExitApp())

        for key, mTool in this.mTools.Clone()
            FileExist(mTool['path']) ? this.trayMenuTools.Add(mTool['name'], this.RunTool.Bind(this, mTool['path'])) : this.mTools.Delete(key)

        for value in ['exit', 'reload', 'about', 'settings', 'tools']
            A_TrayMenu.SetIcon(value, this.mIcons[value],, this.mUser['trayMenuIconSize'])

        A_TrayMenu.SetIcon(this.scriptName, this.mIcons['main'],, this.mUser['trayMenuIconSize'])
        A_TrayMenu.SetIcon('ResIconsPicker', this.mIcons['resIconsPicker'],, this.mUser['trayMenuIconSize'])
        A_TrayMenu.SetIcon('Open Application Folder', this.mIcons['folder'],, this.mUser['trayMenuIconSize'])

        for key, mTool in this.mTools {
            if mTool.Has('iconPath') && FileExist(mTool['iconPath'])
                this.trayMenuTools.SetIcon(mTool['name'], 'HICON:*' LoadPicture(mTool['iconPath'], 'w' this.mUser['trayMenuIconSize'], &imageType),, this.mUser['trayMenuIconSize'])
            else
                this.trayMenuTools.SetIcon(mTool['name'], this.mIcons['tMenuTrans'],, this.mUser['trayMenuIconSize'])
        }

        TraySetIcon(this.mIcons['mainTray'],, true)
    }

    ;============================================================================================

    static gMain_Show(*)
    {
        if this.GuiExist(['gMain', 'gSettings', 'gAbout'])
            return

        this.gMain := Gui(, this.gMainTitle)
        this.gMain.OnEvent('Close', this.gMain_Close.Bind(this))
        this.gMain.OnEvent('DropFiles', this.gMain_DropFiles.Bind(this))
        this.gMain.SetFont('s10')
        this.gMain.Tips := GuiCtrlTips(this.gMain)
        this.gMain.Tips.SetDelayTime('AUTOPOP', 30000)

        gbHeightText := 136
        gbWidthText := 495
        editWidth := 440
        btnSize := 30
        this.gMain.gb_text := this.gMain.Add('GroupBox',  'w' gbWidthText ' h' gbHeightText ' ym cBlack', 'Text')
        this.gMain.Add('Text', 'xp+8 yp+25 Section', 'Title:')
        this.gMain.edit_title := this.gMain.Add('Edit', 'w' editWidth ' xp+35 yp-2 r2 vtitle', this.mUser['title'])
        this.gMain.edit_title.OnEvent('Change',  this.DebounceCall.Bind(this, 125, 'gMain_edit_title_msg_Change', 'title',  't'))
        this.gMain.Add('Text', 'xs' , 'Msg:')
        this.gMain.edit_msg := this.gMain.Add('Edit', 'w' editWidth ' xp+35 yp-2 r3 vmsg', this.mUser['msg'])
        this.gMain.edit_msg.OnEvent('Change',  this.DebounceCall.Bind(this, 125, 'gMain_edit_title_msg_Change', 'msg', 'm'))
        this.gMain.btn_textReset := this.gMain.Add('Button', 'xs+' gbWidthText - 40 ' ys-28 w22 h22')
        this.gMain.btn_textReset.OnEvent('Click', this.gMain_btn_textReset_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_textReset, this.mIcons['reset'], 1, 's12')

        ;===== DISPLAY ===============================

        gbHeightDp := 117
        gbWitdhDp := 150
        this.gMain.gb_display := this.gMain.Add('GroupBox', 'xm ym+' gbHeightText + this.gMain.MarginY ' w' gbWitdhDp ' h' gbHeightDp ' cBlack', 'Display')
        this.gMain.txt_mon := this.gMain.Add('Text', 'xp+8 yp+28 Section +0x0100', 'Monitor:')
        this.gMain.ddl_mon := this.gMain.Add('DropDownList', 'xp+58 yp-2 w73 vmon')
        this.gMain.txt_pos := this.gMain.Add('Text', 'xs +0x0100', 'Position:')
        this.gMain.ddl_pos := this.gMain.Add('DropDownList', 'xp+58 yp-2 w73 vpos', this.arrPos)
        this.gMain.ddl_pos.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ddl_pos_Change'))
        this.gMain.txt_dur := this.gMain.Add('Text', 'xs +0x0100', 'Duration:')
        this.gMain.edit_dur := this.gMain.Add('Edit', 'xp+58 yp-2 w50 vdur Number Limit' StrLen(this.arrDurationRange[2]))
        this.gMain.edit_dur.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_edit_dur_Change'))
        this.gMain.Add('UpDown', 'Range' this.arrDurationRange[1] '-' this.arrDurationRange[2])
        this.gMain.pic_display := this.gMain.Add('Picture', 'xs+65 ys-27 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_displayReset := this.gMain.Add('Button', 'xs+' gbWitdhDp - 40 ' ys-30 w22 h22')
        this.gMain.btn_displayReset.OnEvent('Click', this.gMain_btn_displayReset_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_displayReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_displayLock := this.gMain.Add('CheckBox', 'xs+' gbWitdhDp - 60 ' ys-26 w15 h15')

        ;===== IMAGE ===============================

        gbHeightImage := 117
        gbWidthImage := gbWidthText - gbWitdhDp - this.gMain.MarginX
        this.gMain.gb_image := this.gMain.Add('GroupBox',  'xm+' gbWitdhDp + this.gMain.MarginX
        ' ym+' gbHeightText + this.gMain.MarginY ' w' gbWidthImage ' h' gbHeightImage ' cBlack', 'Image')
        this.gMain.ddl_image := this.gMain.Add('DropDownList', 'xp+8 yp+25 w314 vimage Section', this.arrImage)
        this.gMain.ddl_image.OnEvent('Change',  this.DebounceCall.Bind(this, 125, 'gMain_ddl_image_Change', 'image'))
        this.gMain.Add('Text', 'xs Section', 'Width:')
        this.gMain.edit_iw := this.gMain.Add('Edit', 'xp+50 yp-2 w50 viw Number Limit' StrLen(this.arrImageDimRange[2]))
        this.gMain.edit_iw.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_edit_ImageDim_Change', 'iw'))
        this.gMain.Add('UpDown', 'Range' this.arrImageDimRange[1] '-' this.arrImageDimRange[2])
        this.gMain.Add('Text', 'xs', 'Height:')
        this.gMain.edit_ih := this.gMain.Add('Edit', 'xp+50 yp-2 w50 vih Number Limit' StrLen(this.arrImageDimRange[2]))
        this.gMain.edit_ih.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_edit_ImageDim_Change', 'ih'))
        this.gMain.Add('UpDown', 'Range' this.arrImageDimRange[1] '-' this.arrImageDimRange[2])
        this.gMain.pic_image := this.gMain.Add('Picture', 'xs+116 ys w50 h50 +Border')
        this.gMain.btn_browseImage := this.gMain.Add('Button', 'xs+178 ys w' btnSize ' h' btnSize, '...')
        this.gMain.btn_browseImage.OnEvent('Click', this.gMain_btn_browse.Bind(this, 'image'))
        this.gMain.btn_gRip_Show := this.gMain.Add('Button', 'x+5 ys w' btnSize ' h' btnSize)
        this.gMain.btn_gRip_Show.OnEvent('Click', this.gRip_Show.Bind(this))
        GuiButtonIcon(this.gMain.btn_gRip_Show, this.mIcons['btn_gRip'], 1, 's20')
        this.gMain.btn_copyImage := this.gMain.Add('Button', 'x+5 ys w' btnSize ' h' btnSize)
        this.gMain.btn_copyImage.OnEvent('Click', this.CopyToClipboard.Bind(this, 'image'))
        GuiButtonIcon(this.gMain.btn_copyImage, this.mIcons['clipBoard'], 1, 's20')
        this.gMain.btn_removeImage := this.gMain.Add('Button', 'x+5 ys w' btnSize ' h' btnSize)
        this.gMain.btn_removeImage.OnEvent('Click', this.gList_Show.Bind(this, 'image'))
        GuiButtonIcon(this.gMain.btn_removeImage, this.mIcons['removeList'], 1, 's20')
        this.gMain.pic_imageInfo := this.gMain.Add('Picture', 'xs+55 ys-54 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_imageReset := this.gMain.Add('Button', 'xs+' gbWidthImage - 40 ' ys-58 w22 h22')
        this.gMain.btn_imageReset.OnEvent('Click', this.gMain_btn_imageReset_Click.Bind(this, 'image'))
        GuiButtonIcon(this.gMain.btn_imageReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_imageLock := this.gMain.Add('CheckBox', 'xs+' gbWidthImage - 60 ' ys-54 w15 h15')

        ;===== BACKGROUND IMAGE ====================

        gbWitdhBgImg := 495
        gbHeightBgImg := 88
        this.gMain.gb_bgImg := this.gMain.Add('GroupBox', 'xm ym+' gbHeightText + gbHeightDp + this.gMain.MarginY*2
        ' w' gbWitdhBgImg ' h' gbHeightBgImg ' cBlack', 'Background Image')
        this.gMain.ddl_bgImg := this.gMain.Add('DropDownList', 'xp+8 yp+25 w337 Section vbgImg', this.arrImage)
        this.gMain.ddl_bgImg.OnEvent('Change',  this.DebounceCall.Bind(this, 125, 'gMain_ddl_image_Change', 'bgImg'))
        this.gMain.txt_bgImgPos := this.gMain.Add('Text', 'xs +0x0100', 'Position:')
        this.gMain.cbb_bgImgPos := this.gMain.Add('ComboBox', 'xs+55 yp-1 w173 vbgImgPos', this.arrBgImgPos)
        this.gMain.btn_browseBgImg := this.gMain.Add('Button', 'xs+342 ys-3 w' btnSize ' h' btnSize, '...')
        this.gMain.btn_browseBgImg.OnEvent('Click', this.gMain_btn_browse.Bind(this, 'bgImg'))
        this.gMain.btn_copyBgImg := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_copyBgImg.OnEvent('Click', this.CopyToClipboard.Bind(this, 'bgImg'))
        GuiButtonIcon(this.gMain.btn_copyBgImg, this.mIcons['clipBoard'], 1, 's20')
        this.gMain.pic_bgImg := this.gMain.Add('Picture', 'x+m yp+2 w50 h50 +Border')
        this.gMain.pic_bgImgInfo := this.gMain.Add('Picture', 'xs+140 ys-23 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_bgImgReset := this.gMain.Add('Button', 'xs+' gbWitdhBgImg - 40 ' ys-27 w22 h22')
        this.gMain.btn_bgImgReset.OnEvent('Click', this.gMain_btn_imageReset_Click.Bind(this, 'bgImg'))
        GuiButtonIcon(this.gMain.btn_bgImgReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_bgImgLock := this.gMain.Add('CheckBox', 'xs+' gbWitdhBgImg - 60 ' ys-23 w15 h15')

        ;===== SOUND ===============================

        gbHeightSound := 61
        gbWitdhSound := 495
        this.gMain.gb_sound := this.gMain.Add('GroupBox', 'xm ym+' gbHeightText + gbHeightDp + gbHeightBgImg + this.gMain.MarginY*3
        ' w' gbWitdhSound ' h' gbHeightSound ' cBlack', 'Sound')
        this.gMain.ddl_sound := this.gMain.Add('DropDownList', 'xp+8 yp+25 w337 Section vsound', this.arrSound)
        this.gMain.ddl_sound.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ddl_sound_Change'))
        this.gMain.btn_browseSound := this.gMain.Add('Button', 'x+5 yp-3 w' btnSize ' h' btnSize, '...')
        this.gMain.btn_browseSound.OnEvent('Click', this.gMain_btn_browse.Bind(this, 'sound'))
        this.gMain.btn_playsound := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_playsound.OnEvent('Click', this.gMain_PlaySound.Bind(this))
        GuiButtonIcon(this.gMain.btn_playsound, this.mIcons['musicNote'], 1, 's20')
        this.gMain.btn_copySound := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_copySound.OnEvent('Click', this.CopyToClipboard.Bind(this, 'sound'))
        GuiButtonIcon(this.gMain.btn_copySound, this.mIcons['clipBoard'], 1, 's20')
        this.gMain.btn_removeSound := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_removeSound.OnEvent('Click', this.gList_Show.Bind(this, 'sound'))
        GuiButtonIcon(this.gMain.btn_removeSound, this.mIcons['removeList'], 1, 's20')
        this.gMain.btn_soundReset := this.gMain.Add('Button', 'xs+' gbWitdhSound - 40 ' ys-27 w22 h22')
        this.gMain.btn_soundReset.OnEvent('Click', this.gMain_btn_soundReset_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_soundReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_soundLock := this.gMain.Add('CheckBox', 'xs+' gbWitdhSound - 60 ' ys-23 w15 h15')

        ;===== ANIMATION =============================

        gbHeightAnim := 89
        gbwitdhAnim := 240
        this.gMain.gb_animation := this.gMain.Add('GroupBox', 'xm ym+' gbHeightText + gbHeightDp + gbHeightBgImg + gbHeightSound + this.gMain.MarginY*4
        ' w' gbwitdhAnim ' h' gbHeightAnim ' cBlack', 'Animation')
        this.gMain.Add('Text', 'xp+10 yp+30 Section', 'Show:')
        this.gMain.ddl_show := this.gMain.Add('DropDownList', 'xp+40 yp-2 w120 vshowName', this.arrAnimEdge)
        this.gMain.ddl_show.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ddl_anim', 'show'))
        this.gMain.ddl_showDur := this.gMain.Add('DropDownList', 'x+5 w55 vshowDur', this.arrAnimDur)
        this.gMain.Add('Text', 'xs', 'Hide:')
        this.gMain.ddl_hide := this.gMain.Add('DropDownList', 'xp+40 yp-2 w120 vhideName', this.arrAnimEdge)
        this.gMain.ddl_hide.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ddl_anim', 'hide'))
        this.gMain.ddl_hideDur := this.gMain.Add('DropDownList', 'x+5 w55 vhideDur', this.arrAnimDur)
        this.gMain.pic_animInfo := this.gMain.Add('Picture', 'xs+80 ys-29 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_animReset := this.gMain.Add('Button', 'xs+' gbwitdhAnim - 42 ' ys-33 w22 h22')
        this.gMain.btn_animReset.OnEvent('Click', this.gMain_btn_animReset.Bind(this))
        GuiButtonIcon(this.gMain.btn_animReset, this.mIcons['reset'], 1, 's12')

        ;===== EDGE STYLE ONLY =======================

        gbHeighteso := 89
        gbWidtheso := gbWidthText - gbwitdhAnim - this.gMain.MarginX
        this.gMain.gb_eso := this.gMain.Add('GroupBox',  'xm+' gbwitdhAnim + this.gMain.MarginX
        ' ym+' gbHeightText + gbHeightDp + gbHeightBgImg + gbHeightSound + this.gMain.MarginY*4 ' w' gbWidtheso ' h' gbHeighteso ' cBlack', 'Edge style only')
        this.gMain.cb_txtWstc := this.gMain.Add('Text', 'xp+8 yp+30 Section +0x0100', 'WSTC:')
        this.gMain.cbb_wstc := this.gMain.Add('ComboBox', 'xs+50 yp-2 w173 vwstc', this.arrWstc)
        this.gMain.cb_wstp := this.gMain.Add('CheckBox', 'xs', ' WinSetTransparent:')
        this.gMain.cb_wstp.OnEvent('Click', this.gMain_cb_wstp_Click.Bind(this))
        this.gMain.ddl_wstp := this.gMain.Add('DropDownList', 'xs+149 yp-2 w50 vwstp', this.arrWstp)
        this.gMain.btn_esoReset := this.gMain.Add('Button', 'xs+' gbWidtheso - 40 ' ys-33 w22 h22')
        this.gMain.btn_esoReset.OnEvent('Click', this.gMain_btn_esoReset_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_esoReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_esoLock := this.gMain.Add('CheckBox', 'xs+' gbWidtheso - 60 ' ys-29 w15 h15')

        ;===== THEME - STYLE - RESET ALL =============

        gbHeighTS := 55
        gbWidthTS := 510
        this.gMain.gb_theme := this.gMain.Add('GroupBox',  'xm+' gbWidthText + this.gMain.MarginX ' ym w' gbWidthTS ' h' gbHeighTS ' cBlack', 'Theme')
        this.gMain.ddl_theme := this.gMain.Add('DropDownList', 'xp+8 yp+21 w175 Section vtheme', this.arrTheme)
        this.gMain.ddl_theme.OnEvent('Change', this.DebounceCall.Bind(this, 175, 'gMain_ShowTheme', 'theme'))
        this.gMain.cb_styleLock := this.gMain.Add('CheckBox', 'x+14 yp+3', ' Style:')
        this.gMain.ddl_style := this.gMain.Add('DropDownList', 'x+1 yp-4 w65 vstyle', this.arrStyle)
        this.gMain.ddl_style.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_ddl_style_Change', 'style'))
        this.gMain.btn_copyTheme := this.gMain.Add('Button', 'x+8 yp-3 w' btnSize ' h' btnSize)
        this.gMain.btn_copyTheme.OnEvent('Click', this.CopyToClipboard.Bind(this, 'theme'))
        GuiButtonIcon(this.gMain.btn_copyTheme, this.mIcons['clipBoard'], 1, 's20')
        this.gMain.btn_editTheme := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_editTheme.OnEvent('Click', this.gTheme_Show.Bind(this, 'edit'))
        GuiButtonIcon(this.gMain.btn_editTheme, this.mIcons['btn_edit'], 1, 's20')
        this.gMain.btn_AddTheme := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_AddTheme.OnEvent('Click', this.gTheme_Show.Bind(this, 'add'))
        GuiButtonIcon(this.gMain.btn_AddTheme, this.mIcons['add'], 1, 's20')
        this.gMain.btn_removeTheme := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_removeTheme.OnEvent('Click', this.gList_Show.Bind(this, 'theme'))
        GuiButtonIcon(this.gMain.btn_removeTheme, this.mIcons['removeList'], 1, 's20')
        this.gMain.btn_themeReset := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_themeReset.OnEvent('Click', this.gMain_SetAllValues.Bind(this, 'btn_themeReset'))
        GuiButtonIcon(this.gMain.btn_themeReset, this.mIcons['resetTheme'], 1, 's20')
        this.gMain.btn_defaultAll := this.gMain.Add('Button', 'xm+' gbWidthText + gbWidthTS + 20 ' yp w' btnSize ' h' btnSize)
        this.gMain.btn_defaultAll.OnEvent('Click', this.gMain_SetAllValues.Bind(this, 'btn_default_reset'))
        GuiButtonIcon(this.gMain.btn_defaultAll, this.mIcons['reset'], 1, 's20')
        this.gMain.btn_settings := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_settings.OnEvent('Click', this.gSettings_Show.Bind(this))
        GuiButtonIcon(this.gMain.btn_settings, this.mIcons['btn_settings'], 1, 's20')
        this.gMain.btn_about := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_about.OnEvent('Click', this.gAbout_Show.Bind(this))
        GuiButtonIcon(this.gMain.btn_about, this.mIcons['btn_about'], 1, 's20')

        ;===== TITLE =================================

        gbWidthTM := 302
        gbHeightTM := 273
        this.gMain.gb_title := this.gMain.Add('GroupBox',  'xm+' gbWidthText + this.gMain.MarginX
        ' ym+' gbHeighTS + this.gMain.MarginY ' w' gbWidthTM ' h' gbHeightTM ' cBlack', 'Title')
        this.gMain.txt_tc := this.gMain.Add('Text', 'xp+10 yp+25 w280 h120 Section Border -Wrap')
        this.gMain.Add('Text', 'xs', 'Font:')
        this.gMain.ddl_tf := this.gMain.Add('DropDownList', 'xs+40 yp-2 w240 vtf', this.arrFontNames)
        this.gMain.ddl_tf.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 't'))
        ; this.gMain.ddl_tf.OnEvent('Change', this.gMain_SetFont_Edit.Bind(this, ['t']))
        this.gMain.Add('Text', 'xs yp+35', 'Color:')
        this.gMain.cbb_tc := this.gMain.Add('ComboBox', 'xs+40 yp-2 w95 vtc', this.arrAhkColors)
        this.gMain.cbb_tc.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_cbb_color_Change', 'tc'))
        ; this.gMain.cbb_tc.OnEvent('Change', this.gMain_cbb_color_Change.Bind(this, ['tc']))
        this.gMain.btn_tcSelect := this.gMain.Add('Button', 'x+5 yp-4 w' btnSize ' h' btnSize)
        this.gMain.btn_tcSelect.OnEvent('Click', this.gMain_btn_colorSelect_Click.Bind(this, 't'))
        GuiButtonIcon(this.gMain.btn_tcSelect, this.mIcons['colorPick'], 1, 's20')
        this.gMain.btn_tcPicker := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_tcPicker.OnEvent('Click', this.gMain_btn_colorPicker_Click.Bind(this, 't'))
        GuiButtonIcon(this.gMain.btn_tcPicker, this.mIcons['colorPicker'], 1, 's20')
        this.gMain.btn_copyTfont := this.gMain.Add('Button', 'x+9 yp w' btnSize ' h' btnSize)
        this.gMain.btn_copyTfont.OnEvent('Click', this.CopyToClipboard.Bind(this, 'tf'))
        GuiButtonIcon(this.gMain.btn_copyTfont, this.mIcons['clipBoard'], 1, 's20')
        this.gMain.btn_tFontSelect := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_tFontSelect.OnEvent('Click', this.gMain_btn_font_Click.Bind(this, 't'))
        GuiButtonIcon(this.gMain.btn_tFontSelect, this.mIcons['font'], 1, 's20')
        this.gMain.Add('Text', 'xs', 'Size:')
        this.gMain.edit_ts := this.gMain.Add('Edit', 'x+8 yp-2 w50 vts Number Limit' StrLen(this.arrFontSizeRange[2]))
        this.gMain.Add('UpDown', 'Range' this.arrFontSizeRange[1] '-' this.arrFontSizeRange[2])
        this.gMain.edit_ts.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 't'))
        ; this.gMain.edit_ts.OnEvent('Change', this.gMain_SetFont_Edit.Bind(this, ['t']))
        this.gMain.Add('Text', 'x+14 yp+2', 'Align:')
        this.gMain.ddl_tali := this.gMain.Add('DropDownList', 'x+5 yp-2 w70 vtali', ['Left', 'Right', 'Center'])
        this.gMain.cb_tBold := this.gMain.Add('CheckBox', 'xs ys+224', 'Bold')
        this.gMain.cb_tBold.OnEvent('Click', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 't'))
        this.gMain.cb_tItalic := this.gMain.Add('CheckBox', 'x+10', 'Italic')
        this.gMain.cb_tItalic.OnEvent('Click', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 't'))
        this.gMain.cb_tStrike := this.gMain.Add('CheckBox', 'x+10', 'Strike')
        this.gMain.cb_tStrike.OnEvent('Click', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 't'))
        this.gMain.cb_tUnderline := this.gMain.Add('CheckBox', 'x+10', 'Underline')
        this.gMain.cb_tUnderline.OnEvent('Click', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 't'))
        this.gMain.btn_titleReset := this.gMain.Add('Button', 'xs+' gbWidthTM - 43 ' ys-27 w22 h22')
        this.gMain.btn_titleReset.OnEvent('Click', this.gMain_btn_titleMessageReset_Click.Bind(this, 't'))
        GuiButtonIcon(this.gMain.btn_titleReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_tLock := this.gMain.Add('CheckBox', 'xs+' gbWidthTM - 63 ' ys-23 w15 h15')

        ;===== MESSAGE ===============================

        this.gMain.gb_msg := this.gMain.Add('GroupBox',  'xm+' gbWidthText + gbWidthTM + this.gMain.Marginx*2
        ' ym+' gbHeighTS + this.gMain.MarginY ' w' gbWidthTM ' h' gbHeightTM ' cBlack', 'Message')
        this.gMain.txt_mc := this.gMain.Add('Text', 'xp+10 yp+25 w280 h120 Section Border -Wrap')
        this.gMain.Add('Text', 'xs', 'Font:')
        this.gMain.ddl_mf := this.gMain.Add('DropDownList', 'xs+40 yp-2 w240 vmf', this.arrFontNames)
        this.gMain.ddl_mf.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 'm'))
        ; this.gMain.ddl_mf.OnEvent('Change', this.gMain_SetFont_Edit.Bind(this, ['m']))
        this.gMain.Add('Text', 'xs yp+35', 'Color:')
        this.gMain.cbb_mc := this.gMain.Add('ComboBox', 'xs+40 yp-2 w95 vmc', this.arrAhkColors)
        this.gMain.cbb_mc.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_cbb_color_Change', 'mc'))
        ; this.gMain.cbb_mc.OnEvent('Change', this.gMain_cbb_color_Change.Bind(this, ['mc']))
        this.gMain.btn_mcSelect := this.gMain.Add('Button', 'x+5 yp-4 w' btnSize ' h' btnSize)
        this.gMain.btn_mcSelect.OnEvent('Click', this.gMain_btn_colorSelect_Click.Bind(this, 'm'))
        GuiButtonIcon(this.gMain.btn_mcSelect, this.mIcons['colorPick'], 1, 's20')
        this.gMain.btn_mcPicker := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_mcPicker.OnEvent('Click', this.gMain_btn_colorPicker_Click.Bind(this, 'm'))
        GuiButtonIcon(this.gMain.btn_mcPicker, this.mIcons['colorPicker'], 1, 's20')
        this.gMain.btn_copyMfont := this.gMain.Add('Button', 'x+9 yp w' btnSize ' h' btnSize)
        this.gMain.btn_copyMfont.OnEvent('Click', this.CopyToClipboard.Bind(this, 'mf'))
        GuiButtonIcon(this.gMain.btn_copyMfont, this.mIcons['clipBoard'], 1, 's20')
        this.gMain.btn_mFontSelect := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_mFontSelect.OnEvent('Click', this.gMain_btn_font_Click.Bind(this, 'm'))
        GuiButtonIcon(this.gMain.btn_mFontSelect, this.mIcons['font'], 1, 's20')
        this.gMain.Add('Text', 'xs', 'Size:')
        this.gMain.edit_ms := this.gMain.Add('Edit', 'x+8 yp-2 w50 vms Number Limit' StrLen(this.arrFontSizeRange[2]))
        this.gMain.Add('UpDown', 'Range' this.arrFontSizeRange[1] '-' this.arrFontSizeRange[2])
        this.gMain.edit_ms.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 'm'))
        ; this.gMain.edit_ms.OnEvent('Change', this.gMain_SetFont_Edit.Bind(this, ['m']))
        this.gMain.Add('Text', 'x+14 yp+2', 'Align:')
        this.gMain.ddl_mali := this.gMain.Add('DropDownList', 'x+5 yp-2 w70 vmali', this.arrAli)
        this.gMain.cb_mBold := this.gMain.Add('CheckBox', 'xs ys+224', 'Bold')
        this.gMain.cb_mBold.OnEvent('Click', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 'm'))
        this.gMain.cb_mItalic := this.gMain.Add('CheckBox', 'x+10', 'Italic')
        this.gMain.cb_mItalic.OnEvent('Click', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 'm'))
        this.gMain.cb_mStrike := this.gMain.Add('CheckBox', 'x+10', 'Strike')
        this.gMain.cb_mStrike.OnEvent('Click', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 'm'))
        this.gMain.cb_mUnderline := this.gMain.Add('CheckBox', 'x+10', 'Underline')
        this.gMain.cb_mUnderline.OnEvent('Click', this.DebounceCall.Bind(this, 125, 'gMain_SetFont_Edit', 'm'))
        this.gMain.btn_msgReset := this.gMain.Add('Button', 'xs+' gbWidthTM - 43 ' ys-27 w22 h22')
        this.gMain.btn_msgReset.OnEvent('Click', this.gMain_btn_titleMessageReset_Click.Bind(this, 'm'))
        GuiButtonIcon(this.gMain.btn_msgReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_mLock := this.gMain.Add('CheckBox', 'xs+' gbWidthTM - 63 ' w15 h15 ys-23')

        ;===== BACKGROUND ============================

        gbHeightBg := 65
        gbWidthBg := 202
        this.gMain.gb_bg := this.gMain.Add('GroupBox',  'xm+' gbWidthText + this.gMain.Marginx
        ' ym+' gbHeighTS + gbHeightTM + this.gMain.MarginY*2 ' w' gbWidthBg ' h' gbHeightBg ' cBlack', 'Background')
        this.gMain.cbb_bc := this.gMain.Add('ComboBox', 'xp+28 yp+28 w95 vbc Section', this.arrAhkColors)
        this.gMain.cbb_bc.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_cbb_color_Change', 'bc'))
        this.gMain.btn_bcSelect := this.gMain.Add('Button', 'x+5 yp-4 w' btnSize ' h' btnSize)
        this.gMain.btn_bcSelect.OnEvent('Click', this.gMain_btn_colorSelect_Click.Bind(this, 'b'))
        GuiButtonIcon(this.gMain.btn_bcSelect, this.mIcons['colorPick'], 1, 's20')
        this.gMain.btn_bcPicker := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_bcPicker.OnEvent('Click', this.gMain_btn_colorPicker_Click.Bind(this, 'b'))
        GuiButtonIcon(this.gMain.btn_bcPicker, this.mIcons['colorPicker'], 1, 's20')
        this.gMain.btn_bgReset := this.gMain.Add('Button', 'xs+143 ys-31 w22 h22')
        this.gMain.btn_bgReset.OnEvent('Click', this.gMain_btn_bgReset_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_bgReset, this.mIcons['reset'], 1, 's12')

        ;===== BORDER ================================

        gbHeightBdr := 95
        gbWidthBdr := 202
        this.gMain.gb_bdr := this.gMain.Add('GroupBox',  'xm+' gbWidthText + this.gMain.Marginx
        ' ym+' gbHeighTS + gbHeightTM + gbHeightBg + this.gMain.MarginY*3 ' w' gbWidthBdr ' h' gbHeightBdr ' cBlack', 'Border')
        this.gMain.cb_bdr := this.gMain.Add('CheckBox', 'xp+8 yp+32 w15 h15 Section')
        this.gMain.cb_bdr.OnEvent('Click', this.gMain_cb_bdr_Click.Bind(this))
        this.gMain.cbb_bdrC := this.gMain.Add('ComboBox', 'xs+20 vbdrC yp-5 w95', this.arrBdrColors)
        this.gMain.cbb_bdrC.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_cbb_color_Change', 'bdrC'))
        this.gMain.btn_bdrCselect := this.gMain.Add('Button', 'x+5 yp-2 w' btnSize ' h' btnSize)
        this.gMain.btn_bdrCselect.OnEvent('Click', this.gMain_btn_colorSelect_Click.Bind(this, 'bdr'))
        GuiButtonIcon(this.gMain.btn_bdrCselect, this.mIcons['colorPick'], 1, 's20')
        this.gMain.btn_bdrCpicker := this.gMain.Add('Button', 'x+5 yp w' btnSize ' h' btnSize)
        this.gMain.btn_bdrCpicker.OnEvent('Click', this.gMain_btn_colorPicker_Click.Bind(this, 'bdr'))
        GuiButtonIcon(this.gMain.btn_bdrCpicker, this.mIcons['colorPicker'], 1, 's20')
        this.gMain.Add('Text', 'xs+20', 'Width:')
        this.gMain.edit_bdrW := this.gMain.Add('Edit', 'xp+50 yp-2 w45 vbdrW Number Limit' StrLen(Notify.arrBdrWrange[2]))
        this.gMain.edit_bdrW.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_edit_bdrW_Change'))
        this.gMain.Add('UpDown', 'Range' Notify.arrBdrWrange[1] '-' Notify.arrBdrWrange[2])
        this.gMain.pic_bdrC := this.gMain.Add('Picture', 'x+8 h5 w60 +Border')
        this.gMain.pic_bdrInfo := this.gMain.Add('Picture', 'xs+60 ys-31 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_bdrCreset := this.gMain.Add('Button', 'xs+' gbWidthBg - 39 ' ys-34 w22 h22')
        this.gMain.btn_bdrCreset.OnEvent('Click', this.gMain_btn_bdrCreset_Click.Bind(this))
        GuiButtonIcon(this.gMain.btn_bdrCreset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_bdrLock := this.gMain.Add('CheckBox', 'xs+' gbWidthBdr - 59 ' ys-30 w15 h15')

        ;===== PADDING ===============================

        gbHeightPad := 150
        gbWidthPad := 205
        this.gMain.gb_padding := this.gMain.Add('GroupBox',  'xm+' gbWidthText + gbWidthBg + this.gMain.MarginX*2
        ' ym+' gbHeighTS + gbHeightTM + this.gMain.MarginY*2 ' w' gbWidthPad ' h' gbHeightPad ' cBlack', 'Padding/Margins')
        this.gMain.txt_padX := this.gMain.Add('Text', 'xp+8 yp+28 Section +0x0100', 'PadX:')
        this.gMain.edit_padX := this.gMain.Add('Edit', 'xp+40 yp-2 w50 vpadX Number Limit' StrLen(Notify.arrPadXYrange[2]))
        this.gMain.Add('UpDown', 'Range' Notify.arrPadXYrange[1] '-' Notify.arrPadXYrange[2])
        this.gMain.txt_gmT := this.gMain.Add('Text', 'xs +0x0100', 'GmT:')
        this.gMain.edit_gmT := this.gMain.Add('Edit', 'xp+40 yp-2 w50 vgmT Number Limit' StrLen(Notify.arrPadRange[2]))
        this.gMain.Add('UpDown', 'Range' Notify.arrPadRange[1] '-' Notify.arrPadRange[2])
        this.gMain.txt_gmL := this.gMain.Add('Text', 'xs +0x0100', 'GmL:')
        this.gMain.edit_gmL := this.gMain.Add('Edit', 'xp+40 yp-2 w50 vgmL Number Limit' StrLen(Notify.arrPadRange[2]))
        this.gMain.Add('UpDown', 'Range' Notify.arrPadRange[1] '-' Notify.arrPadRange[2])
        this.gMain.txt_spX := this.gMain.Add('Text', 'xs +0x0100', 'SpX:')
        this.gMain.edit_spX := this.gMain.Add('Edit', 'xp+40 yp-2 w50 vspX Number Limit' StrLen(Notify.arrPadRange[2]))
        this.gMain.Add('UpDown', 'Range' Notify.arrPadRange[1] '-' Notify.arrPadRange[2])
        this.gMain.txt_padY := this.gMain.Add('Text', 'xs+95 ys Section +0x0100', 'PadY:')
        this.gMain.edit_padY := this.gMain.Add('Edit', 'xp+40 yp-2 w50 vpadY Number Limit' StrLen(Notify.arrPadXYrange[2]))
        this.gMain.Add('UpDown', 'Range' Notify.arrPadXYrange[1] '-' Notify.arrPadXYrange[2])
        this.gMain.txt_gmB := this.gMain.Add('Text', 'xs +0x0100', 'GmB:')
        this.gMain.edit_gmB := this.gMain.Add('Edit', 'xp+40 yp-2 w50 vgmB Number Limit' StrLen(Notify.arrPadRange[2]))
        this.gMain.Add('UpDown', 'Range' Notify.arrPadRange[1] '-' Notify.arrPadRange[2])
        this.gMain.txt_gmR := this.gMain.Add('Text', 'xs +0x0100', 'GmR:')
        this.gMain.edit_gmR := this.gMain.Add('Edit', 'xp+40 yp-2 w50 vgmR Number Limit' StrLen(Notify.arrPadRange[2]))
        this.gMain.Add('UpDown', 'Range' Notify.arrPadRange[1] '-' Notify.arrPadRange[2])
        this.gMain.txt_spY := this.gMain.Add('Text', 'xs +0x0100', 'SpY:')
        this.gMain.edit_spY := this.gMain.Add('Edit', 'xp+40 yp-2 w50 vspY Number Limit' StrLen(Notify.arrPadRange[2]))
        this.gMain.Add('UpDown', 'Range' Notify.arrPadRange[1] '-' Notify.arrPadRange[2])

        for value in ['padX', 'padY', 'gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY']
            this.gMain.edit_%value%.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_edit_pad_Change', value))

        this.gMain.pic_padInfo := this.gMain.Add('Picture', 'xs+26 ys-26 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_paddingReset := this.gMain.Add('Button', 'xs+70 ys-30 w22 h22')
        this.gMain.btn_paddingReset.OnEvent('Click', this.gMain_btn_paddingReset_Click.Bind(this, Notify.mDefaults['theme']))
        GuiButtonIcon(this.gMain.btn_paddingReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_paddingLock := this.gMain.Add('CheckBox', 'xs+50 w15 h15 ys-26')

        ;===== MISC ==================================

        gbHeighMisc := 230
        gbWidthMisc := 185
        this.gMain.gb_misc := this.gMain.Add('GroupBox',  'xm+' gbWidthText + gbWidthBg + gbWidthPad + this.gMain.MarginX*3
        ' ym+' gbHeighTS + gbHeightTM + this.gMain.MarginY*2 ' w' gbWidthMisc ' h' gbHeighMisc ' cBlack', 'Misc.')
        this.gMain.cb_maxW := this.gMain.Add('CheckBox', 'xp+8 yp+28 Section', ' Max. Width:')
        this.gMain.cb_maxW.OnEvent('Click', this.gMain_cb_maxW_Click.Bind(this, 'maxW'))
        this.gMain.edit_maxW := this.gMain.Add('Edit', 'xs+95 yp-2 w50 vmaxW Number Limit' StrLen(this.arrGuiDimRange[2]))
        this.gMain.edit_maxW.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_edit_GuiDim_Change', 'maxW'))
        this.gMain.Add('UpDown', 'Range' this.arrGuiDimRange[1] '-' this.arrGuiDimRange[2])
        this.gMain.cb_width := this.gMain.Add('CheckBox', 'xs', ' Width:')
        this.gMain.cb_width.OnEvent('Click', this.gMain_cb_maxW_Click.Bind(this, 'width'))
        this.gMain.edit_width := this.gMain.Add('Edit', 'xs+95 yp-2 w50 vwidth Number Limit' StrLen(this.arrGuiDimRange[2]))
        this.gMain.edit_width.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_edit_GuiDim_Change', 'width'))
        this.gMain.Add('UpDown', 'Range' this.arrGuiDimRange[1] '-' this.arrGuiDimRange[2])
        this.gMain.cb_minH := this.gMain.Add('CheckBox', 'xs', ' Min. Height:')
        this.gMain.cb_minH.OnEvent('Click', this.gMain_cb_maxW_Click.Bind(this, 'minH'))
        this.gMain.edit_minH := this.gMain.Add('Edit', 'xs+95 yp-2 w50 vminH Number Limit' StrLen(this.arrGuiDimRange[2]))
        this.gMain.edit_minH.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gMain_edit_GuiDim_Change', 'minH'))
        this.gMain.Add('UpDown', 'Range' this.arrGuiDimRange[1] '-' this.arrGuiDimRange[2])
        this.gMain.cb_dgc := this.gMain.Add('CheckBox', 'xs vdgc', ' DGC')
        this.gMain.txt_dg := this.gMain.Add('Text', 'x+10 +0x0100', 'DG:')
        this.gMain.ddl_dg := this.gMain.Add('DropDownList', 'xp+38 yp-2 w40 vdg', this.arrDg)
        this.gMain.cb_dgb := this.gMain.Add('CheckBox', 'xs vdgb', ' DGB')
        this.gMain.cb_dga := this.gMain.Add('CheckBox', 'xp+80 yp vdga', ' DGA')
        this.gMain.txt_prog := this.gMain.Add('Text', 'xs +0x0100', 'Prog:')
        this.gMain.cbb_prog := this.gMain.Add('ComboBox', 'xs+40 yp-2 w125 vprog', this.arrProg)
        this.gMain.txt_tag := this.gMain.Add('Text', 'xs +0x0100', 'Tag:')
        this.gMain.edit_tag := this.gMain.Add('Edit', 'xs+40 yp-2 w125 vtag')
        this.gMain.pic_miscInfo := this.gMain.Add('Picture', 'xs+50 ys-26 w15 h15 +0x0100', this.mIcons['iSmall'])
        this.gMain.btn_miscReset := this.gMain.Add('Button', 'xs+' gbWidthMisc - 40 ' ys-30 w22 h22')
        this.gMain.btn_miscReset.OnEvent('Click', this.gMain_btn_miscReset.Bind(this))
        GuiButtonIcon(this.gMain.btn_miscReset, this.mIcons['reset'], 1, 's12')
        this.gMain.cb_miscLock := this.gMain.Add('CheckBox', 'xs+' gbWidthMisc - 60 ' ys-26 w15 h15')

        ;===== RESULT ================================

        gbWidthResult := 708
        gbHeightResult := 106
        this.gMain.gb_result := this.gMain.Add('GroupBox', 'xm ym+' gbHeightText + gbHeightDp + gbHeightBgImg + gbHeightSound + gbHeightAnim + this.gMain.MarginY*5
        ' w' gbWidthResult ' h' gbHeightResult ' cBlack Section', 'Result')
        this.gMain.btn_copyResult := this.gMain.Add('Button', 'xp+8 yp+21 w58 h75', 'Copy')
        this.gMain.btn_copyResult.OnEvent('Click', this.CopyToClipboard.Bind(this, 'result'))
        this.gMain.btn_copyResult.SetFont('bold s9')
        GuiButtonIcon(this.gMain.btn_copyResult, this.mIcons['clipBoard'], 1, 's35 a2 t15 l2')
        this.gMain.edit_result := this.gMain.Add('Edit', 'x+7 yp+1 w625 r4 vresult ReadOnly BackgroundWhite')
        this.gMain.btn_test := this.gMain.Add('Button', 'xs+' gbWidthResult + this.gMain.MarginX ' ys+9 w97 h97 Section', 'Test')
        this.gMain.btn_test.SetFont('bold')
        this.gMain.btn_test.OnEvent('Click', this.gMain_btn_test.Bind(this))
        GuiButtonIcon(this.gMain.btn_test, this.mIcons['test'], 1, 's45 a2 t18 l2')
        this.gMain.btn_destroyAll := this.gMain.Add('Button', 'x+m w97 h97', 'Destroy All')
        this.gMain.btn_destroyAll.SetFont('bold')
        this.gMain.btn_destroyAll.OnEvent('Click', (*) => Notify.DestroyAll(1))
        GuiButtonIcon(this.gMain.btn_destroyAll, this.mIcons['destroy'], 1, 's45 a2 t18 l2')
        btnWidth := 90
        btnHeight := 35
        this.gMain.btn_monInfo := this.gMain.Add('Button', 'x+m ys+40 w' btnSize ' h' btnSize ' Section')
        this.gMain.btn_monInfo.OnEvent('Click', this.MonitorGetInfo.Bind(this))
        GuiButtonIcon(this.gMain.btn_monInfo, this.mIcons['monInfo'], 1, 's20')
        this.gMain.btn_gitHub := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_gitHub.OnEvent('Click', (*) => Run(this.linkGitHubRepo))
        GuiButtonIcon(this.gMain.btn_gitHub, this.mIcons['gitHub'], 1, 's20')
        this.gMain.btn_donate := this.gMain.Add('Button', 'x+5 w' btnSize ' h' btnSize)
        this.gMain.btn_donate.OnEvent('Click', (*) => Run('https://buymeacoffee.com/xmcqcx'))
        GuiButtonIcon(this.gMain.btn_donate, this.mIcons['buymeacoffee'], 1, 's20')

        this.gMain.sb := this.gMain.Add('StatusBar')
        this.gMain.sb.SetParts(155, 155,)

        ;==============================================

        for value in ['text', 'sound', 'image', 'bgImg', 'display', 'animation', 'title', 'msg', 'bg', 'padding', 'eso', 'misc', 'bdr', 'result', 'theme']
            this.gMain.gb_%value%.SetFont('bold')

        for value in ['mon', 'showDur', 'hideDur', 'mali', 'tali', 'wstp', 'wstc', 'prog', 'dg', 'tag', 'bgImgPos']
            this.gMain[value].OnEvent('Change', this.DebounceCall.Bind(this, 125, 'UpdateResultString'))

        for value in ['dgc', 'dgb', 'dga']
            this.gMain[value].OnEvent('Click', this.DebounceCall.Bind(this, 125, 'UpdateResultString'))

        ;==============================================

        this.mGuiCtrlTips := this.MapCI().Set(
            'mon', '
            (
                ➤ MON - Monitor
                    • NUMBER - A specific monitor number.
                    • ACTIVE - The monitor on which the active window is displayed.
                    • MOUSE - The monitor on which the mouse is currently positioned.
                    • PRIMARY - The primary monitor.
            )',
            'pos', '
            (
                ➤ POS - Position
                    • TL - Top left
                    • TC - Top center
                    • TR - Top right
                    • CTL - Center left
                    • CT - Center
                    • CTR - Center right
                    • BL - Bottom left
                    • BC - Bottom center
                    • BR - Bottom right
                    • MOUSE -  Near the cursor.
            )',
            'dur', '
            (
                ➤ DUR - Display duration (in seconds). Set to 0 to keep it on the screen until
                left-clicking on the GUI or programmatically destroying it.
            )',
            'bgImg', '
            (
                ➤ BGIMG - Background image.
            )',
            'bgImgPos', '
            (
                ➤ BGIMGPOS - Background image position. Parameters for positioning and sizing the background image.
                    -- Positions --
                        • TL - Top left
                        • TC - Top center
                        • TR - Top right
                        • CTL - Center left
                        • CT - Center
                        • CTR - Center right
                        • BL - Bottom left
                        • BC - Bottom center
                        • BR - Bottom right
                        • X - Custom horizontal position.
                        • Y - Custom vertical position.
                        • OFSTX - Horizontal pixel offset.
                        • OFSTY - Vertical pixel offset.

                    -- Display Modes --
                        • STRETCH - Stretches both the width and height of the image to fill the entire GUI.
                        • SCALE - Resizes the image proportionally.

                    -- Image Dimensions (width and height) --
                        • STRETCH - Adjusts either the width or height of the image to match the GUI dimension.
                        • To resize the image while preserving its aspect ratio, specify -1 for one dimension and a positive number for the other.
                        • Specify 0 to retain the image's original width or height (DPI scaling does not apply).
                        • Omit the W or H options to retain the image's original width or height (DPI scaling applies).
            )',
            'gMain.pic_imageInfo', '
            (
                -- Image Dimensions (width and height) --
                    • To resize the image while preserving its aspect ratio, specify -1 for one dimension and a positive number for the other.
                    • Specify 0 to retain the image's original width or height (DPI scaling does not apply).
            )',
            'pad', '
            (
                ➤ PAD - Padding, margins, and spacing.
                    • PADX - Padding between the GUI's left or right edge and the screen's edge.
                    • PADY - Padding between the GUI's top or bottom edge and the screen's edge or taskbar.
                    • GMT - Top margin of the GUI.
                    • GMB - Bottom margin of the GUI.
                    • GML - Left margin of the GUI.
                    • GMR - Right margin of the GUI.
                    • SPX - Horizontal spacing between the right side of the image and other controls.
                    • SPY - Vertical spacing between the title, message, and progress bar.

                • PadX and PadY can range from 0 to 25. The others can range from 0 to 999.
                • PadX and PadY cannot be included in themes.
            )',
            'gMain.cbLock', '
            (
                Check - Lock settings to prevent them from changing when switching themes.
                Uncheck - Resets to the theme`'s settings when switching themes.
            )',
            'gMain.cb_styleLock', '
            (
                Check - Lock style to prevent it from changing when switching themes,`nalso locking the animation settings.
                Uncheck - Resets to the theme`'s style when switching themes.
            )',
            'gMain.cb_tmLock', '
            (
                Check - Lock settings (except color) to prevent them from changing when switching themes.
                Uncheck - Resets to the theme`'s settings when switching themes.
            )',
            'gMain.btn_paddingReset', 'Reset to the theme`'s settings, or to the style`'s default padding setting`nif no specific settings have been set for the theme.',
            'gMain.btn_animReset', 'Reset to the default animation and duration settings for the selected style and position.',
            'gMain.btnReset', 'Reset to the theme`'s settings, or to default settings`nif no specific settings have been set for the theme.',
            'gMain.btn_colorSelect', 'Open the color selector.',
            'gMain.btn_colorPicker', 'Pick color from screen.',
            'gMain.btn_fontSelect', 'Open the font selector.',
            'gMain.pic_animInfo', 'The round style is limited to the fade animation or none.`nTo unlock all animations, choose the edge style.',
            'gMain.pic_bdrInfo', 'The round style`'s maximum border width is limited to 1 pixel,`nwhile the edge style allows up to 10 pixels.',
            'maxW', '➤ MAXW - Maximum width of the GUI (excluding image width and margins).',
            'width', '➤ WIDTH - Fixed width of the GUI (excluding image width and margins).',
            'minH', '➤ MINH - Minimum height of the GUI.',
            'prog', '➤ PROG - Progress Bar',
            'tag', '➤ TAG - Marker to identify a GUI. The Destroy method accepts a tag,`nit destroys every GUI containing this tag across all scripts.',
            'dgc', '
            (
                ➤ DGC - Destroy GUI click. Allow or prevent the GUI from being destroyed when clicked.
                    • 0 - Clicking on the GUI does not destroy it.
                    • 1 - Clicking on the GUI destroys it.
            )',
            'dg', '
            (
                ➤ DG - Destroy GUIs before showing the new GUI.
                    • 0 - Do not destroy GUIs.
                    • 1 - Destroy all GUIs on the monitor option at the position option.
                    • 2 - Destroy all GUIs on all monitors at the position option.
                    • 3 - Destroy all GUIs on the monitor option.
                    • 4 - Destroy all GUIs.
                    • 5 - Destroy all GUIs containing the tag.
            )',
            'dgb', '
            (
                ➤ DGB - Destroy GUI block. Prevents the GUI from being destroyed unless the force parameter of the destroy methods is set to true.
                It does not prevent GUI destruction after the duration expires or when the GUI is clicked. In most cases, you’ll likely want to set
                both the Duration (DUR) and Destroy GUI Click (DGC) to 0. For example: 'dgb=1 dur=0 dgc=0'
                -------------------
                    • 0 - The GUI can be destroyed without setting the force parameter to true.
                    • 1 - The GUI cannot be destroyed unless the force parameter is set to true.
            )',
            'dga', '
            (
                ➤ DGA - Destroy GUI animation. Enables or disables the hide animation
                when destroying the GUI using the destroy methods.
                -------------------
                    • 0 - No animation.
                    • 1 - Animation enabled.
            )'
        )

        for value in ['padX', 'padY', 'gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY']
            this.gMain.Tips.SetTip(this.gMain.txt_%value%, this.mGuiCtrlTips['pad'])

        for value in ['display', 'image', 'bgImg', 'sound', 'misc', 'eso', 'padding', 'bdr']
            this.gMain.Tips.SetTip(this.gMain.cb_%value%Lock, this.mGuiCtrlTips['gMain.cbLock'])

        for value in ['display', 'image', 'bgImg', 'sound', 'misc', 'eso', 'bg', 'title', 'msg', 'bdrC']
            this.gMain.Tips.SetTip(this.gMain.btn_%value%Reset, this.mGuiCtrlTips['gMain.btnReset'])

        for value in ['mc', 'tc', 'bc', 'bdrC']
            for val in ['select', 'picker']
                this.gMain.Tips.SetTip(this.gMain.btn_%value%%val%, this.mGuiCtrlTips['gMain.btn_color' val])

        for value in ['image', 'sound', 'result']
            this.gMain.Tips.SetTip(this.gMain.btn_copy%value%, 'Copy ' value ' to clipboard.')

        for value in ['show', 'hide']
            this.gMain.Tips.SetTip(this.gMain.ddl_%value%Dur, 'Duration (in milliseconds)')

        this.gMain.Tips.SetTip(this.gMain.pic_miscInfo, (this.mGuiCtrlTips['maxW'] '`n' this.mGuiCtrlTips['width'] '`n' this.mGuiCtrlTips['minH'] '`n' this.mGuiCtrlTips['dgc'] '`n`n'
            this.mGuiCtrlTips['dg'] '`n`n' this.mGuiCtrlTips['dgb'] '`n`n' this.mGuiCtrlTips['dga'] '`n`n' this.mGuiCtrlTips['prog'] '`n`n' this.mGuiCtrlTips['tag']
        ))

        this.gMain.Tips.SetTip(this.gMain.cb_maxW, this.mGuiCtrlTips['maxW'])
        this.gMain.Tips.SetTip(this.gMain.cb_width, this.mGuiCtrlTips['width'])
        this.gMain.Tips.SetTip(this.gMain.cb_minH, this.mGuiCtrlTips['minH'])
        this.gMain.Tips.SetTip(this.gMain.txt_prog, this.mGuiCtrlTips['prog'])
        this.gMain.Tips.SetTip(this.gMain.txt_tag, this.mGuiCtrlTips['tag'])
        this.gMain.Tips.SetTip(this.gMain.cb_dgc, this.mGuiCtrlTips['dgc'])
        this.gMain.Tips.SetTip(this.gMain.cb_dgb, this.mGuiCtrlTips['dgb'])
        this.gMain.Tips.SetTip(this.gMain.cb_dga, this.mGuiCtrlTips['dga'])
        this.gMain.Tips.SetTip(this.gMain.txt_dg, this.mGuiCtrlTips['dg'])
        this.gMain.Tips.SetTip(this.gMain.pic_bgImgInfo, (this.mGuiCtrlTips['bgImg'] '`n' this.mGuiCtrlTips['bgImgPos']))
        this.gMain.Tips.SetTip(this.gMain.txt_bgImgPos, this.mGuiCtrlTips['bgImgPos'])
        this.gMain.Tips.SetTip(this.gMain.pic_display, this.mGuiCtrlTips['mon'] '`n`n' this.mGuiCtrlTips['pos'] '`n`n' this.mGuiCtrlTips['dur'])
        this.gMain.Tips.SetTip(this.gMain.txt_mon, this.mGuiCtrlTips['mon'])
        this.gMain.Tips.SetTip(this.gMain.txt_pos, this.mGuiCtrlTips['pos'])
        this.gMain.Tips.SetTip(this.gMain.txt_dur, this.mGuiCtrlTips['dur'])
        this.gMain.Tips.SetTip(this.gMain.pic_padInfo, this.mGuiCtrlTips['pad'])
        this.gMain.Tips.SetTip(this.gMain.pic_imageInfo, this.mGuiCtrlTips['gMain.pic_imageInfo'])
        this.gMain.Tips.SetTip(this.gMain.cb_styleLock, this.mGuiCtrlTips['gMain.cb_styleLock'])
        this.gMain.Tips.SetTip(this.gMain.cb_tLock, this.mGuiCtrlTips['gMain.cb_tmLock'])
        this.gMain.Tips.SetTip(this.gMain.cb_mLock, this.mGuiCtrlTips['gMain.cb_tmLock'])
        this.gMain.Tips.SetTip(this.gMain.btn_tFontSelect, this.mGuiCtrlTips['gMain.btn_fontSelect'])
        this.gMain.Tips.SetTip(this.gMain.btn_mFontSelect, this.mGuiCtrlTips['gMain.btn_fontSelect'])
        this.gMain.Tips.SetTip(this.gMain.btn_animReset, this.mGuiCtrlTips['gMain.btn_animReset'])
        this.gMain.Tips.SetTip(this.gMain.btn_paddingReset, this.mGuiCtrlTips['gMain.btn_paddingReset'])
        this.gMain.Tips.SetTip(this.gMain.pic_animInfo, this.mGuiCtrlTips['gMain.pic_animInfo'])
        this.gMain.Tips.SetTip(this.gMain.pic_bdrInfo, this.mGuiCtrlTips['gMain.pic_bdrInfo'])
        this.gMain.Tips.SetTip(this.gMain.btn_copyBgImg, 'Copy background image to clipboard.')
        this.gMain.Tips.SetTip(this.gMain.btn_copyTheme, 'Copy theme name to clipboard.')
        this.gMain.Tips.SetTip(this.gMain.btn_copyTfont, 'Copy title font name to clipboard.')
        this.gMain.Tips.SetTip(this.gMain.btn_copyMfont, 'Copy message font name to clipboard.')
        this.gMain.Tips.SetTip(this.gMain.btn_textReset, 'Reset to default.')
        this.gMain.Tips.SetTip(this.gMain.btn_defaultAll, 'Reset user interface to default.')
        this.gMain.Tips.SetTip(this.gMain.btn_playsound, 'Play sound')
        this.gMain.Tips.SetTip(this.gMain.btn_browseImage, 'Browse image')
        this.gMain.Tips.SetTip(this.gMain.btn_browseBgImg, 'Browse background Image.')
        this.gMain.Tips.SetTip(this.gMain.btn_browseSound, 'Browse sound')
        this.gMain.Tips.SetTip(this.gMain.btn_removeImage, 'Remove images from the images history.')
        this.gMain.Tips.SetTip(this.gMain.btn_removeSound, 'Remove sounds from the sounds history.')
        this.gMain.Tips.SetTip(this.gMain.cb_txtWstc, 'WinSetTransColor')
        this.gMain.Tips.SetTip(this.gMain.btn_about, 'About')
        this.gMain.Tips.SetTip(this.gMain.btn_settings, 'Settings')
        this.gMain.Tips.SetTip(this.gMain.btn_gRip_Show, 'Choose an icon from system resource files (ResIconsPicker)')
        this.gMain.Tips.SetTip(this.gMain.btn_AddTheme, 'Add theme')
        this.gMain.Tips.SetTip(this.gMain.btn_editTheme, 'Edit theme')
        this.gMain.Tips.SetTip(this.gMain.btn_removeTheme, 'Delete user-created themes.')
        this.gMain.Tips.SetTip(this.gMain.btn_destroyAll, 'Destroy all GUIs (force).')
        this.gMain.Tips.SetTip(this.gMain.btn_gitHub, 'GitHub repository')
        this.gMain.Tips.SetTip(this.gMain.btn_donate, 'If you find my AHK code useful and would like to show your appreciation,`na donation would be greatly appreciated. Thank you!')
        this.gMain.Tips.SetTip(this.gMain.btn_monInfo, 'Displays information about the monitors connected to the system.')

        ;==============================================

        this.RemoveNonExistentFiles(['image', 'sound'])
        this.gMain_SetAllValues(this.mUser['theme'])
        this.gMain_SetStatusBar()
        try ControlFocus(this.gMain.btn_test.hwnd, this.gMain.hwnd)
        this.gMain.Show()
    }

	;============================================================================================

    static gMain_Close(*) => (this.mUser['closeMainExitApp'] ? ExitApp() : this.gMain.Destroy())

    ;============================================================================================

    static gMain_SetStatusBar(*)
    {
        if Notify.arrFonts.Length >= 175
            this.gMain.sb.SetIcon(this.mIcons['!'],, 1), setIcon := true

        this.gMain.sb.SetText((IsSet(setIcon) ? 'Font limit: ' : '   Font limit: ') Notify.arrFonts.Length '/190', 1)
        this.gMain.sb.SetText('   Themes count: ' Notify.mThemes.Count, 2)
        this.gMain.sb.SetText('   Default theme: ' Notify.mDefaults['theme'], 3)
    }

    ;============================================================================================

    static gMain_SetAllValues(param, *)
    {
        switch {
            case Notify.mThemes.Has(param): theme := param
            case param == 'btn_themeReset': theme := this.gMain.ddl_theme.Text
            case param == 'btn_default_reset':
            {
                theme := Notify.mDefaults['theme']

                for value in ['style', 'display', 'image', 'bgImg', 'sound', 'misc', 'padding', 'eso', 'bdr', 't', 'm']
                    this.gMain.cb_%value%Lock.Value := 0
            }
        }

        mTheme := Notify.mThemes[theme]
        this.gMain_SetTheme(theme)
        this.gMain_SetStyle(theme)
        this.gMain_SetText(param)
        this.gMain_SetDisplay(theme)
        this.gMain_SetAnimation(theme, 'setDefault')
        this.gMain_SetImage(theme)
        this.gMain_SetBgImg(theme)
        this.gMain_SetSound(theme)
        this.gMain_SetMisc(theme)
        this.gMain_SetPadding(theme)
        this.gMain_SetESO(theme)

        for value in ['t', 'm']
            this.gMain_SetTextValues(mTheme, value, 'setDefault')

        this.gMain_SetColor(mTheme['bc'], 'b')
        this.gMain_SetColor(mTheme['bdrC'], 'bdr')
        this.gMain_SetBorder(mTheme)
        this.Enabled_Disabled_Border(theme)
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_ShowTheme(arrParams, *)
    {
        theme := this.mUser[arrParams[1]] := this.gMain[arrParams[1]].Text
        mTheme := Notify.mThemes[theme]

        for value in ['style', 'display', 'image', 'bgImg', 'sound', 'misc', 'padding']
            if this.gMain.cb_%value%Lock.Value = 0
                this.gMain_Set%value%(theme)

        for value in ['t', 'm']
            this.gMain_SetTextValues(mTheme, value)

        if (this.gMain.cb_bdrLock.Value = 0) {
            this.gMain_SetColor(mTheme['bdrC'], 'bdr')
            this.gMain_SetBorder(mTheme)
        }

        this.gMain_SetColor(mTheme['bc'], 'b')
        this.gMain_SetESO(theme)
        this.gMain_SetAnimation(theme, 'showTheme')
        this.Enabled_Disabled_Border(theme)
        this.gMain_SetTip_btn_editTheme(theme)
        this.gMain_SetTip_btn_themeReset(theme)
        m := this.UpdateResultString()
        this.ShowNotify(m['title'], m['msg'], m['image'], m['sound'], m['options'] ' dg=5 tag=showTheme')
    }

    ;============================================================================================

    static gMain_SetTheme(theme)
    {
        this.DDLchoose(this.mUser['theme'] := theme, this.arrTheme, this.gMain.ddl_theme)
        this.gMain_SetTip_btn_editTheme(theme)
        this.gMain_SetTip_btn_themeReset(theme)
    }

    ;============================================================================================

    static gMain_SetTip_btn_editTheme(theme) => this.gMain.Tips.SetTip(this.gMain.btn_editTheme, theme = 'default' ? 'Edit default settings.' : 'Edit theme')

    ;============================================================================================

    static gMain_SetTip_btn_themeReset(theme) => this.gMain.Tips.SetTip(this.gMain.btn_themeReset, 'Reset all to the current ' (theme = 'default' ? 'default' : 'theme') ' settings.')

    ;============================================================================================

    static gMain_SetStyle(theme) => this.DDLchoose(Notify.mThemes[theme]['style'], this.arrStyle, this.gMain.ddl_style)

    ;============================================================================================

    static gMain_SetText(defaultOrUser)
    {
        for value in ['t', 'm'] {
            val := (value = 't' ? 'title' : 'msg')
            txt := this.mUser[val] := (defaultOrUser = 'btn_default_reset' ? this.mDefaults[val] : this.gMain[val].Text)
            this.gMain.edit_%val%.Text := txt
            txt := this.UnescapeCharacters(txt)
            this.gMain.txt_%value 'c'%.Text := txt
        }
    }

    ;============================================================================================

    static gMain_edit_title_msg_Change(arrParams, *)
    {
        txt := this.mUser[arrParams[1]] := this.gMain[arrParams[1]].Value
        txt := this.UnescapeCharacters(txt)
        this.gMain.txt_%arrParams[2] 'c'%.Text := txt
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetDisplay(theme)
    {
        mTheme := Notify.mThemes[theme]
        this.DDLchoose(mTheme['pos'], this.arrPos, this.gMain.ddl_pos)
        this.gMain.edit_dur.Text := mTheme['dur']
        arrMon := this.CreateIncrementalArray(1, 1, MonitorGetCount())
        arrMon.Push('Active')
        arrMon.Push('Mouse')
        arrMon.Push('Primary')
        this.DDLArrayChange_Choose(mTheme['mon'], arrMon, this.gMain.ddl_mon)
    }

    ;============================================================================================

    static gMain_btn_displayReset_Click(*)
    {
        theme := this.gMain.ddl_theme.Text
        this.gMain_SetDisplay(theme)
        this.gMain_SetAnimation(theme, 'displayReset')
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetAnimation(theme, fromMethod:='')
    {
        style := this.gMain.ddl_style.Text
        pos := this.gMain.ddl_pos.Text
        md := this.mAnimDefStyle[style][pos]

        if (fromMethod == 'showTheme') {
            if this.gMain.cb_styleLock.Value = 0
                SetAnimation()
        } else
            SetAnimation()

        SetAnimation() {
            this.DDLArrayChange_Choose(md['showName'], this.arr%'anim' (md['style'] = 'edge' ? md['style'] : 'RoundShow')%, this.gMain.ddl_show)
            this.DDLArrayChange_Choose(md['hideName'], this.arr%'anim' (md['style'] = 'edge' ? md['style'] : 'RoundHide')%, this.gMain.ddl_hide)
            this.DDLchoose(md['showDur'], this.arrAnimDur, this.gMain.ddl_showDur)
            this.DDLchoose(md['hideDur'], this.arrAnimDur, this.gMain.ddl_hideDur)
            this.gMain_ddl_Duration_EnableDisable('show')
            this.gMain_ddl_Duration_EnableDisable('hide')
        }
    }

    ;============================================================================================

    static gMain_ddl_anim(arrParams, *)
    {
        this.gMain_ddl_Duration_EnableDisable(arrParams[1])
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_ddl_Duration_EnableDisable(param) => this.gMain.ddl_%param 'Dur'%.Enabled := (this.gMain.ddl_%param%.Text = 'none' ? false : true)

    ;============================================================================================

    static gMain_btn_animReset(*)
    {
        this.gMain_SetAnimation(this.gMain.ddl_theme.Text, 'animationReset')
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_btn_textReset_Click(*)
    {
        this.gMain_SetText('btn_default_reset')
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_btn_browse(param, *) => this.ProcessFileInput(, param,, 'btn_browse')

    ;============================================================================================

    static gMain_DropFiles(guiObj, objCtrl, arrFile, x, y) => this.ProcessFileInput(guiObj, objCtrl, arrFile, 'dropFiles')

    ;============================================================================================

    static ProcessFileInput(guiObj:='', param:='', arrFile := Array(), fromMethod:='')
    {
        if !(RegExMatch((a := Type(param) == 'String' ? param : (IsObject(param) ? param.Name : '')), '^(image|bgImg|sound)$'))
            return

        switch fromMethod {
            case 'btn_browse':
            {
                this.gMain.Opt('+OwnDialogs')
                fileFilter := param = 'sound' ? 'Sound (*.wav)' : this.strImageExtfilter
                arrFile := FileSelect('M3',, 'Select ' (param == 'sound' ? 'Sound' : 'Image') ' - ' this.scriptName, fileFilter)
            }
            case 'dropFiles': param := param.Name
        }

        if (arrFile.Length) {
            for index, fPath in arrFile.Clone() {
                RegExMatch(fPath, 'i)^.+\.(dll|exe|cpl)\|icon\d+$', &matchExt) ? ext := matchExt[1] : SplitPath(fPath,,, &ext)

                if (param == 'sound' && ext != 'wav') || (RegExMatch(param, '^(image|bgImg)$') && !RegExMatch(ext, 'i)^(' Notify.strImageExt ')$'))
                    index := this.HasVal(fPath, arrFile), arrFile.RemoveAt(index)
            }

            strArr := (param == 'sound' ? 'sound' : 'image')

            for index, fPath in arrFile
                if !this.Hasval(fPath, this.arr%strArr%)
                    this.arr%strArr%.Push(fPath), lastPath := fPath

            this.arr%strArr% := this.SortArray(this.arr%strArr%)

            if (RegExMatch(param, '^(image|bgImg)$')) {
                otherCtrlName := (param == 'image' ? 'bgImg' : 'image')
                txtOtherCtrl := this.gMain.ddl_%otherCtrlName%.Text
                this.DDLArrayChange_Choose(txtOtherCtrl, this.arrImage, this.gMain.ddl_%otherCtrlName%), SetImage_SetSound(txtOtherCtrl, otherCtrlName)
            }

            switch {
                case IsSet(lastPath):
                    this.DDLArrayChange_Choose(lastPath, this.arr%strArr%, this.gMain.ddl_%param%), SetImage_SetSound(lastPath, param)

                case arrFile.Length && !IsSet(lastPath):
                    this.DDLchoose(arrFile[1], this.arr%strArr%, this.gMain.ddl_%param%), SetImage_SetSound(arrFile[1], param)
            }
        }

        if arrFile.Length
            this.UpdateResultString()

        SetImage_SetSound(file, param) {
            switch param {
                case 'image', 'bgImg': this.gMain_SetImagePreview(file, param)
                case 'sound': this.gMain_SetTip_ddl_sound(file)
            }
        }
    }

    ;============================================================================================

    static gMain_SetImage(theme, fromMethod:='')
    {
        mTheme := Notify.mThemes[theme]
        image := mTheme['image']

        for value in ['iw', 'ih']
            this.gMain.edit_%value%.Text := mTheme[value]

        this.DDLchoose(image, this.arrImage, this.gMain.ddl_image)
        this.gMain_SetImagePreview(image, 'image')
    }

    ;============================================================================================

    static gMain_SetBgImg(theme, fromMethod:='')
    {
        mTheme := Notify.mThemes[theme]
        image := mTheme['bgImg']
        this.gMain.cbb_bgImgPos.Text := mTheme['bgImgPos']
        this.DDLchoose(image, this.arrImage, this.gMain.ddl_bgImg)
        this.gMain_SetImagePreview(image, 'bgImg')
    }

    ;============================================================================================

    static gMain_ddl_image_Change(arrParams, *)
    {
        this.gMain_SetImagePreview(this.gMain[arrParams[1]].Text, arrParams[1])
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetImagePreview(image, param)
    {
        this.gMain.ddl_%param%.GetPos(,, &ctrlWidth)
        txtTip := (this.ControlGetTextWidth(this.gMain.ddl_%param%.hwnd, image)) > (ctrlWidth - 25) ? image : 'Drag and drop images here.'
        this.gMain.Tips.SetTip(this.gMain.ddl_%param%, txtTip)

        try {
            switch {
                case Notify.isInternalString(image):
                    this.gMain.pic_%param%.Value := '*icon' Notify.mImages[image] ' ' A_WinDir '\system32\user32.dll', set := true

                case Notify.isInternalImage(image):
                    this.gMain.pic_%param%.Value := Notify.mImages[image], set := true

                case arrRegExMatch := Notify.isIconResourceFile(image):
                    this.gMain.pic_%param%.Value := '*Icon' arrRegExMatch[2] ' ' arrRegExMatch[1], set := true

                case FileExist(image): this.gMain.pic_%param%.Value := image, set := true
                case !FileExist(image): this.gMain.pic_%param%.Value := this.mIcons['transIcon'], set := false
            }
        } catch
            this.gMain.pic_%param%.Value := this.mIcons['transIcon'], set := false

        this.gMain.pic_%param%.Enabled := (set ? true : false)
    }

    ;============================================================================================

    static gMain_btn_imageReset_Click(param, *)
    {
        this.gMain_Set%param%(this.gMain.ddl_theme.Text)
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetSound(theme)
    {
        sound := Notify.mThemes[theme]['sound']
        this.DDLchoose(sound, this.arrSound, this.gMain.ddl_sound)
        this.gMain_SetTip_ddl_sound(sound)
    }

    ;============================================================================================

    static gMain_ddl_sound_Change(*)
    {
        txtSound := this.gMain.ddl_sound.Text
        this.gMain_SetTip_ddl_sound(txtSound)

        if this.mUser['soundOnSelection']
            this.gMain_PlaySound(txtSound)

        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetTip_ddl_sound(txtSound)
    {
        this.gMain.ddl_sound.GetPos(,, &ctrlWidth)
        txtTip := (this.ControlGetTextWidth(this.gMain.ddl_sound.hwnd, txtSound)) > (ctrlWidth - 25) ? txtSound : 'Drag and drop wav files here.'
        this.gMain.Tips.SetTip(this.gMain.ddl_sound, txtTip)
    }

    ;============================================================================================

    static gMain_PlaySound(*) => SetTimer( Notify.Sound.Bind(Notify, this.gMain.ddl_sound.Text), -1)

    ;============================================================================================

    static gMain_btn_soundReset_Click(*)
    {
        theme := this.gMain.ddl_theme.Text
        this.gMain_SetSound(theme)
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_cbb_color_Change(arrParams, *)
    {
        param := arrParams[1]
        color := this.gMain.cbb_%arrParams[1]%.Text

        if !Notify.isValidColor(color)
            color := 'White'

        try {
            switch param {
                case 'tc', 'mc': this.gMain.txt_%param%.SetFont('c' color)
                case 'bdrC':
                    this.gMain.pic_bdrC.Opt('+Redraw +Background' color)
                    this.Enabled_Disabled_edit_bdrW()
                case 'bc':
                    this.gMain.txt_tc.Opt('Redraw +Background' color)
                    this.gMain.txt_mc.Opt('Redraw +Background' color)
            }
            this.UpdateResultString()
        }
    }

    ;============================================================================================

    static gMain_btn_colorPicker_Click(param, *)
    {
        color := ColorPicker.Run(False)

        if (color) {
            hex := color.ToHex("{R}{G}{B}")
            this.gMain_SetColor(Notify.NormAHKColor('0x' hex.Full), param)

            if param ='bdr'
                this.Enabled_Disabled_edit_bdrW()
        }
    }

    ;============================================================================================

    static gMain_SetTextValues(obj, param, fromMethod:='')
    {
        if this.gMain.cb_%param%Lock.Value = 0
        || RegExMatch(fromMethod, '^(setDefault|titleMessageReset|btn_font)$') {
            this.gMain.edit_%param 's'%.Text := obj[param 's']

            if !Notify.SetFont(this.gMain.txt_%param 'c'%, obj[param 's'], obj[param 'c'], obj[param 'fo'], obj[param 'f'])
                this.MsgBox_WarningTooManyFonts()

            this.gMain_SetStatusBar()
            this.gMain_DDLchooseColor(obj[param 'c'], param)
            this.gMain_SetFontOption(obj[param 'fo'], param)
            this.DDLchoose(obj[param 'f'], this.arrFontNames, this.gMain.ddl_%param 'f'%)
            this.DDLchoose(obj[param 'ali'], this.arrAli, this.gMain.ddl_%param 'ali'%)
        } else
            this.gMain_SetColor(obj[param 'c'], param)
    }

    ;============================================================================================

    static gMain_SetColor(color, param)
    {
        switch param {
            case 't', 'm': this.gMain.txt_%param 'c'%.SetFont('c' color)
            case 'bdr': this.gMain.pic_bdrC.Opt('Redraw +Background' color)
            case 'b':
                this.gMain.txt_tc.Opt('Redraw +Background' color)
                this.gMain.txt_mc.Opt('Redraw +Background' color)
        }

        this.gMain_DDLchooseColor(color, param)
    }

    ;============================================================================================

    static gMain_DDLchooseColor(color, param)
    {
        switch param {
            case 't', 'm': ctrl := 'cbb_' param 'c', arr := 'ahkColors'
            case 'b':      ctrl := 'cbb_bc', arr := 'ahkColors'
            case 'bdr':    ctrl := 'cbb_bdrC', arr := 'bdrColors'
        }

        if !this.DDLchoose(color, this.arr%arr%, this.gMain.%ctrl%)
            this.gMain.%ctrl%.Text := color
    }

    ;============================================================================================

    static gMain_btn_titleMessageReset_Click(param, *)
    {
        theme := this.gMain.ddl_theme.Text
        mTheme := Notify.mThemes[theme]
        this.gMain_SetTextValues(mTheme, param, 'titleMessageReset')
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_btn_bdrCreset_Click(*)
    {
        theme := this.gMain.ddl_theme.Text
        mTheme := Notify.mThemes[theme]
        this.gMain_SetColor(mTheme['bdrC'], 'bdr')
        this.gMain_SetBorder(mTheme)
        this.Enabled_Disabled_Border(theme)
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetBorder(mTheme)
    {
        style := this.gMain.ddl_style.Text
        this.gMain.edit_bdrW.Value := mTheme['bdrW']

        if style = 'edge'
            this.gMain.cb_bdr.Value := (mTheme['bdr'] && mTheme['bdrC']) ? 1 : 0
    }

    ;============================================================================================

    static gMain_btn_bgReset_Click(*)
    {
        theme := this.gMain.ddl_theme.Text
        this.gMain_SetColor(Notify.mThemes[theme]['bc'], 'b')
        this.UpdateResultString()
    }

    ;============================================================================================

    static Enabled_Disabled_Border(theme)
    {
        mTheme := Notify.mThemes[theme]
        style := this.gMain.ddl_style.Text

        switch style, false {
            case 'round':
                this.gMain.cb_bdr.Value := 1
                this.gMain.cb_bdr.Enabled := false
                this.gMain.cbb_bdrC.Enabled := true
            case 'edge':
                this.gMain.cb_bdr.Value := mTheme['bdr'] ? 1 : 0
                this.gMain.cb_bdr.Enabled := true
                this.gMain.cbb_bdrC.Enabled := (this.gMain.cb_bdr.Value = 1 ? true : false)
        }

        this.Enabled_Disabled_edit_bdrW()
    }

    ;============================================================================================

    static Enabled_Disabled_edit_bdrW()
    {
        switch this.gMain.ddl_style.Text, false {
            case 'edge': this.gMain.edit_bdrW.Enabled := (this.gMain.cbb_bdrC.Text = 'default' ? false : true)
            case 'round': this.gMain.edit_bdrW.Enabled := false
        }
    }

    ;============================================================================================

    static gMain_SetMisc(theme)
    {
        mTheme := Notify.mThemes[theme]
        this.gMain.edit_tag.Text := mTheme['tag']
        this.gMain.cbb_prog.Text := mTheme['prog']
        this.gMain.cb_dgc.Value := mTheme['dgc']
        this.gMain.cb_dgb.Value := mTheme['dgb']
        this.gMain.cb_dga.Value := mTheme['dga']
        this.DDLchoose(mTheme['dg'], this.arrDg, this.gMain.ddl_dg)

        for value in ['width', 'minH', 'maxW'] {
            if mTheme[value]
                this.gMain.edit_%value%.Value := mTheme[value], this.gMain.cb_%value%.Value := 1, this.gMain.edit_%value%.Enabled := true
            else
                this.gMain.edit_%value%.Value := (value ~= '^(width|maxW)$' ? 400 : 200), this.gMain.cb_%value%.Value := 0, this.gMain.edit_%value%.Enabled := false
        }
    }

    ;============================================================================================

    static gMain_btn_miscReset(*)
    {
        this.gMain_SetMisc(this.gMain.ddl_theme.Text)
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetPadding(theme)
    {
        style := this.gMain.ddl_style.Text
        mTheme := Notify.mThemes[theme]
        defaultPadXY := (style = 'edge' ? Notify.padXYdefaultEdge : Notify.padXYdefaultRound)

        for value in ['padX', 'padY']
            this.gMain.edit_%value%.Text := defaultPadXY

        for value in ['gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY']
            this.gMain.edit_%value%.Text := mTheme[value]
    }

    ;============================================================================================

    static gMain_btn_paddingReset_Click(*)
    {
        this.gMain_SetPadding(this.gMain.ddl_theme.Text)
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetESO(theme)
    {
        style := this.gMain.ddl_style.Text
        this.gMain_WinSetTransparent(theme, style)
        this.gMain_WinSetTransColor(theme, style)
        this.Enabled_Disabled_ESO(theme, style)
    }

    ;============================================================================================

    static gMain_btn_esoReset_Click(*)
    {
        this.gMain_SetESO(this.gMain.ddl_theme.Text)
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_WinSetTransparent(theme, style)
    {
        if (this.gMain.cb_esoLock.Value = 0) {
            if !this.DDLchoose(Notify.mThemes[theme]['wstp'], this.arrWstp, this.gMain.ddl_wstp)
                this.DDLchoose(220, this.arrWstp, this.gMain.ddl_wstp)

            this.gMain.cb_wstp.Value := Notify.mThemes[theme]['wstp'] ? 1 : 0
        }
    }

    ;============================================================================================

    static gMain_WinSetTransColor(theme, style)
    {
        if this.gMain.cb_esoLock.Value = 0
            if !this.DDLchoose(Notify.mThemes[theme]['wstc'], this.arrWstc, this.gMain.cbb_wstc)
                this.gMain.cbb_wstc.Text := Notify.mThemes[theme]['wstc']
    }

    ;============================================================================================

    static Enabled_Disabled_ESO(theme, style)
    {
        this.gMain.cb_wstp.Enabled := this.gMain.cbb_wstc.Enabled := (style = 'edge' ? true : false)
        this.gMain.ddl_wstp.Enabled := (this.gMain.cb_wstp.Value = 1 && style = 'edge') ? true : false
    }

    ;============================================================================================

    static gMain_cb_wstp_Click(objCtrl, *)
    {
        (this.gMain.cb_wstp.Value = 1) ? this.gMain.ddl_wstp.Enabled := true : this.gMain.ddl_wstp.Enabled := false
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_cb_bdr_Click(objCtrl, *)
    {
        switch this.gMain.cb_bdr.Value {
            case 0 : this.gMain.cbb_bdrC.Enabled := this.gMain.edit_bdrW.Enabled := false
            case 1: this.gMain.cbb_bdrC.Enabled := this.gMain.edit_bdrW.Enabled := true
        }

        if this.gMain.cbb_bdrC.Text = 'default'
            this.gMain.edit_bdrW.Enabled := false

        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_cb_maxW_Click(param, *)
    {
        (this.gMain.cb_%param%.Value = 1) ? this.gMain.edit_%param%.Enabled := true : this.gMain.edit_%param%.Enabled := false
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_ddl_style_Change(arrParams, *)
    {
        style := this.gMain[arrParams[1]].Text
        theme := this.gMain.ddl_theme.Text
        this.gMain_SetAnimation(theme, 'ddl_style')

        if (this.gMain.cb_paddingLock.Value = 0) {
            defaultPadXY := (style = 'edge' ? Notify.padXYdefaultEdge : Notify.padXYdefaultRound)

            for value in ['padX', 'padY']
                this.gMain.edit_%value%.Text := defaultPadXY
        }

        this.Enabled_Disabled_ESO(theme, style)
        this.Enabled_Disabled_Border(theme)
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_ddl_pos_Change(arrParams, *)
    {
        this.gMain_SetAnimation(this.gMain.ddl_theme.Text, 'ddl_pos')
        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_edit_ImageDim_Change(arrParams, *)
    {
        if (dim := this.gMain.edit_%arrParams[1]%.Text) = ''
            return

        if dim > this.arrImageDimRange[2]
            this.gMain.edit_%arrParams[1]%.Text := this.arrImageDimRange[2]

        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_edit_bdrW_Change(*)
    {
        if (width := this.gMain.edit_bdrW.Text) = ''
            return

        switch {
            case (width < Notify.arrBdrWrange[1] || width = 0): this.gMain.edit_bdrW.Text := Notify.arrBdrWrange[1]
            case width > Notify.arrBdrWrange[2]: this.gMain.edit_bdrW.Text := Notify.arrBdrWrange[2]
        }

        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_edit_GuiDim_Change(arrParams, *)
    {
        if (width := this.gMain.edit_%arrParams[1]%.Text) = ''
            return

        switch {
            case (width < this.arrGuiDimRange[1] || width = 0): this.gMain.edit_%arrParams[1]%.Text := this.arrGuiDimRange[1]
            case width > this.arrGuiDimRange[2]: this.gMain.edit_%arrParams[1]%.Text := this.arrGuiDimRange[2]
        }

        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_edit_pad_Change(arrParams, *)
    {
        if (pad := this.gMain.edit_%arrParams[1]%.Text) = ''
            return

        strPad := RegExMatch(arrParams[1], '^(padX|padY)$') ? 'arrPadXYrange' : 'arrPadRange'

        if pad > Notify.%strPad%[2]
            this.gMain.edit_%arrParams[1]%.Text := Notify.%strPad%[2]

        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_edit_dur_Change(*)
    {
        if (dur := this.gMain.edit_dur.Text) = ''
            return

        if dur > this.arrDurationRange[2]
            this.gMain.edit_dur.Text := this.arrDurationRange[2]

        this.UpdateResultString()
    }

    ;============================================================================================

    static gMain_SetFont_Edit(arrParams, *)
    {
        param := arrParams[1]

        if (size := this.gMain.edit_%param 's'%.Text) = ''
            return

        switch {
            case (size < this.arrFontSizeRange[1] || size = 0): size := this.gMain.edit_%param 's'%.Text := this.arrFontSizeRange[1]
            case size > this.arrFontSizeRange[2]: size := this.gMain.edit_%param 's'%.Text := this.arrFontSizeRange[2]
        }

        strFontOptions := this.BuildFontOptionsString(param)
        font := this.gMain.ddl_%param 'f'%.Text

        if !Notify.isValidColor(color := this.gMain.cbb_%param 'c'%.Text)
            color := '0xFFFFFF'

        if !Notify.SetFont(this.gMain.txt_%param 'c'%, size, color, strFontOptions, font)
            this.MsgBox_WarningTooManyFonts()

        this.gMain_SetStatusBar()
        this.UpdateResultString()
    }

    ;============================================================================================

    static UpdateResultString(*)
    {
        m := this.Submit_ObjectToMap(this.gMain.Submit(0))
        mTheme := Notify.mThemes[m['theme']]

        if m['theme'] != Notify.mDefaults['theme']
            options .= 'theme=' m['theme'] ' '

        for value in ['mon', 'pos', 'dur', 'style']
            if m[value] != mTheme[value]
                options .= value '=' m[value] ' '

        ;==============================================

        for value in ['title', 'msg'] {
            if !m[value]
                continue

            m[value] := this.EscapeCharacters(m[value])
            str := (value = 'title' ? 't' : 'm')

            for val in [str 's', str 'c', str 'f', str 'ali']
                if m[val] != mTheme[val]
                    options .= val '=' m[val] ' '

            arrFo := this.BuildFontOptionsArray(str)

            if !this.IsArrayContainsSameValues(arrFo, mTheme['arr' str 'fo'])
                options .= str 'fo=' this.BuildFontOptionsString(str) ' '
        }

        if m['bc'] != mTheme['bc']
            options .= 'bc=' m['bc'] ' '

        ;==============================================

        switch m['style'], false {
            case 'round':
            {
                if this.gMain.cbb_bdrC.Enabled
                    (m['bdrC'] != mTheme['bdrC']) && options .= 'bdr=' m['bdrC'] ' '
            }
            case 'edge':
            {
                if (this.gMain.cbb_bdrC.Enabled) {
                    switch {
                        case mTheme['bdr'] = 0: options .= 'bdr=' (m['bdrC'] = 'default' ? m['bdrC'] ' ' : m['bdrC'] ','  m['bdrW'] ' ')
                        case m['bdrC'] = 'default' && mTheme['bdrC'] != 'default': options .= 'bdr=' m['bdrC'] ' '
                        case m['bdrC'] = 'default' && mTheme['bdrC'] = 'default': options .= ''
                        default:
                        {
                            for value in ['bdrC', 'bdrW']
                                strBdr .= m[value] != mTheme[value] ? m[value] ',' : ','

                            if strBdr != ',,'
                                options .= 'bdr=' RTrim(RegExReplace(strBdr, 'i)Default,\d+', 'Default'), ',') ' '
                        }
                    }
                } else if mTheme['bdr']
                    options .= 'bdr=0 '
            }
        }

        ;==============================================

        for value in ['sound', 'image']
            if m[value] = mTheme[value]
                m[value] := ''

        if (this.gMain.pic_image.Enabled) && (m['iw'] != mTheme['iw'] || m['ih'] != mTheme['ih'])
            for value in ['iw', 'ih']
                if m[value] != -1
                    options .= value '=' m[value] ' '

        if m['bgImg'] != mTheme['bgImg']
                options .= 'bgImg=' m['bgImg'] ' '

        if m['bgImgPos']
            (m['bgImgPos'] != mTheme['bgImgPos']) && options .= 'bgImgPos=' m['bgImgPos'] ' '
        else
            mTheme['bgImgPos'] && options .= 'bgImgPos= '

        ;==============================================

        this.CreateAnimationString(m)

        if m['strAnim'] != this.mAnimDefStyle[m['style']][m['pos']]['strAnim']
            options .= m['strAnim'] ' '

        for value in ['width', 'minH', 'maxW'] {
            if this.gMain.edit_%value%.Enabled
                (m[value] != mTheme[value]) && options .= value '=' m[value] ' '
            else
                mTheme[value] && options .= value '= '
        }

        ;==============================================

        defaultPadXY := (m['style'] = 'edge' ? Notify.padXYdefaultEdge : Notify.padXYdefaultRound)

        for value in ['padX', 'padY']
            strPad .= (m[value] != defaultPadXY ? m[value] : '') ','

        for value in ['gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY']
            strPad .= (m[value] != mTheme[value] ? m[value] : '') ','

        if strPad != ',,,,,,,,'
            options .= 'pad=' RTrim(strPad, ',') ' '

        ;==============================================

        if (m['style'] = 'edge') {
            if this.gMain.ddl_wstp.Enabled
                (m['wstp'] != mTheme['wstp']) && options .= 'wstp=' m['wstp'] ' '
            else
                mTheme['wstp'] && options .= 'wstp= '

            if (this.gMain.cbb_wstc.Enabled) {
                if m['wstc'] != mTheme['wstc']
                    (m['wstc'] && Instr(m['wstc'], 'wstc=')) ? options .= m['wstc'] ' ' : options .= 'wstc=' m['wstc'] ' '
            } else
                mTheme['wstc'] && options .= 'wstc= '
        }

        for value in ['prog', 'tag'] {
            if m[value]
                (m[value] != mTheme[value]) && options .= value '=' m[value] ' '
            else
                mTheme[value] && options .= value '= '
        }

        for value in ['dgc', 'dg', 'dgb', 'dga']
            (m[value] != mTheme[value]) && options .= value '=' m[value] ' '

        ;==============================================

        options := RTrim(options ?? '')
        strResult := 'Notify.Show('
        . (m['title'] ? "'" m['title'] "'" : '') (m['msg'] ? ', ' : ',')
        . (m['msg'] ? "'" m['msg'] "'" : '') (m['image'] ? ', ' : ',')
        . (m['image'] ? "'" m['image'] "'" : '')  (m['sound'] ? ', ' : ',')
        . (m['sound'] ? "'" m['sound'] "'" : '') (options ? ',, ' : ',,')
        . (options ? "'" options "'" : '') ')'
        strResult := RegExReplace(strResult, ',+\)$', ')')
        this.gMain.edit_result.Value := strResult
        m['options'] := options
        return m
    }

    ;============================================================================================

    static gMain_btn_test(*)
    {
        m := this.UpdateResultString()

        for value in ['tc', 'mc'] {
            if (!Notify.isValidColor(m[value])) {
                Notify.Show('Error', 'Gui.Prototype.SetFont`nInvalid option.',,,, this.strOpts 'theme=xdark dg=5 tag=errorMsg')
                return
            }
        }

        this.ShowNotify(m['title'], m['msg'], m['image'], m['sound'], m['options'])
    }

    ;============================================================================================

    static ShowNotify(title:='', msg:='', image:='', sound:='', options:='')
    {
        m := Map('title', title, 'msg', msg)

        for value in ['title', 'msg']
            m[value] := this.UnescapeCharacters(m[value])

        try Notify.Show(m['title'], m['msg'], image, sound,, options)
        catch as e
            Notify.Show('Error', e.what '`n' e.Message,,,, this.strOpts 'theme=xdark dg=5 tag=errorMsg')
    }

    ;============================================================================================

    static BuildFontOptionsString(value)
    {
        strFontOptions := 'norm'

        for option in ['Bold', 'Italic', 'Strike', 'Underline']
            if this.gMain.cb_%value option%.Value = 1
                strFontOptions .= ' ' option

        return RTrim(strFontOptions)
    }

    ;============================================================================================

    static BuildFontOptionsArray(value)
    {
        arrFo := Array()

        for option in ['bold', 'italic', 'strike', 'underline']
            if this.gMain.cb_%value option%.Value = 1
                arrFo.Push(option)

        return arrFo
    }

    ;============================================================================================

    static gMain_SetFontOption(str, value, *)
    {
        for option in ['bold', 'italic', 'strike', 'underline']
            this.gMain.cb_%value option%.Value := InStr(str, option) ? 1 : 0
    }

    ;============================================================================================

    static gMain_btn_colorSelect_Click(param, *)
    {
        color := this.ColorSelect(this.gMain.cbb_%param 'c'%.Text , this.gMain.hwnd, 1)
        if color = -1
            return

        this.gMain_SetColor(Notify.NormAHKColor(color), param)
        this.Enabled_Disabled_edit_bdrW()
        this.UpdateResultString()
    }

    /********************************************************************************************
     * Win32 Color Picker for AHK v2.
     * @credits Maestrith, TheArkive (v2 conversion), XMCQCX (minor modifications).
     * @see {@link https://www.autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs Font and Color Dialogs - AHK Forum}
     * @see {@link https://github.com/TheArkive/ColorPicker_ahk2 ColorPicker_ahk2 - GitHub}
     * @param {number} Color - Start color (0 = black) - Format = 0xRRGGBB
     * @param {number} hwnd - Parent window
     * @param {number} disp - 1=full / 0=basic ... full displays custom colors panel, basic does not.
     */
    static ColorSelect(color := 0, hwnd := 0, disp:=false)
    {
        Static p := A_PtrSize
        disp := disp ? 0x3 : 0x1 ; init disp / 0x3 = full panel / 0x1 = basic panel
        color := Notify.NormHexClrCode(color)

        If (this.mUser['savedColors'].Length > 16)
            throw Error("Too many custom colors.  The maximum allowed values is 16.")

        Loop (16 - this.mUser['savedColors'].Length)
            this.mUser['savedColors'].Push(0) ; fill out this.mUser['savedColors'] to 16 values

        CUSTOM := Buffer(16 * 4, 0) ; init custom colors obj
        CHOOSECOLOR := Buffer((p=4)?36:72,0) ; init dialog

        If (IsObject(this.mUser['savedColors'])) {
            Loop 16 {
                custColor := RGB_BGR(this.mUser['savedColors'][A_Index])
                NumPut "UInt", custColor, CUSTOM, (A_Index-1) * 4
            }
        }

        NumPut "UInt", CHOOSECOLOR.size, CHOOSECOLOR, 0             ; lStructSize
        NumPut "UPtr", hwnd,             CHOOSECOLOR, p             ; hwndOwner
        NumPut "UInt", RGB_BGR(color),   CHOOSECOLOR, 3 * p         ; rgbResult
        NumPut "UPtr", CUSTOM.ptr,       CHOOSECOLOR, 4 * p         ; lpCustColors
        NumPut "UInt", disp,             CHOOSECOLOR, 5 * p         ; Flags

        if !DllCall("comdlg32\ChooseColor", "UPtr", CHOOSECOLOR.ptr, "UInt")
            return -1

        this.mUser['savedColors'] := Array()
        Loop 16 {
            newCustCol := NumGet(CUSTOM, (A_Index-1) * 4, "UInt")
            this.mUser['savedColors'].InsertAt(A_Index, Format("0x{:06X}", RGB_BGR(newCustCol)))
        }

        color := NumGet(CHOOSECOLOR, 3 * A_PtrSize, "UInt")
        return Format("0x{:06X}",RGB_BGR(color))

        RGB_BGR(c) => ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)
    }

    ;============================================================================================

    static gMain_btn_font_Click(param, *)
    {
        m := this.MapCI().Set(
            param 'f', this.gMain.ddl_%param 'f'%.Text,
            param 's', this.gMain.edit_%param 's'%.Text,
            param 'c', this.gMain.cbb_%param 'c'%.Text,
            param 'ali', this.gMain.ddl_%param 'ali'%.Text,
            'strike', this.gMain.cb_%param 'strike'%.Value,
            'underline', this.gMain.cb_%param 'underline'%.Value,
            'italic', this.gMain.cb_%param 'italic'%.Value,
            'bold', this.gMain.cb_%param 'bold'%.Value,
        )

        if !m := this.FontSelect(m, this.gMain.hwnd,, param)
            return

        m[param 'c'] := Notify.NormAHKColor(m[param 'c'])
        this.gMain_SetTextValues(m, param, 'btn_font')
        this.UpdateResultString()
    }

    /********************************************************************************************
     * Displays a font selection dialog and returns the selected font properties.
     * @credits Maestrith, TheArkive (v2 conversion), XMCQCX (modifications).
     * @see {@link https://www.autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs AHK Forum}
     * @see {@link https://github.com/TheArkive/FontPicker_ahk2 GitHub}
     * @param {Object} [m=""] - An object containing font properties.
     * @param {number} [hwnd=0] - Handle to the parent window.
     * @param {boolean} [Effects=true] - Specifies if font effects are enabled.
     * @param {string} [param=""] - A string parameter used for font properties.
     * @returns {Object|boolean} - Returns the modified font properties object or false if the dialog is canceled.
     */
    static FontSelect(m:="", hwnd:=0, Effects:=true, param:="")
    {
        Static p := A_PtrSize, u := StrLen(Chr(0xFFFF)) ; u = IsUnicode
        m[param 'c'] := Notify.NormHexClrCode(m[param 'c'])

        if (StrLen(m[param 'f']) > 31)
            throw Error("Font name length exceeds 31 characters.")

        LOGFONT := Buffer(!u ? 60 : 96,0) ; LOGFONT size based on IsUnicode, not A_PtrSize
        hDC := DllCall("GetDC","UPtr",0)
        LogPixels := DllCall("GetDeviceCaps","UPtr",hDC,"Int",90)
        Effects := 0x041 + (Effects ? 0x100 : 0)
        DllCall("ReleaseDC", "UPtr", 0, "UPtr", hDC)

        m['bold'] := m['bold'] ? 700 : 400
        m[param 's'] := Floor(m[param 's']*LogPixels/72)

        NumPut "uint", m[param 's'], LOGFONT
        NumPut "uint", m['bold'], "char", m['italic'], "char", m['underline'], "char", m['strike'], LOGFONT, 16
        StrPut(m[param 'f'],LOGFONT.ptr+28)

        CHOOSEFONT := Buffer((p=8)?104:60,0)
        NumPut "UInt", CHOOSEFONT.size,     CHOOSEFONT
        NumPut "UPtr", hwnd,                CHOOSEFONT, p
        NumPut "UPtr", LOGFONT.ptr,         CHOOSEFONT, (p*3)
        NumPut "UInt", effects,             CHOOSEFONT, (p*4)+4
        NumPut "UInt", RGB_BGR(m[param 'c']), CHOOSEFONT, (p*4)+8

        if !DllCall("comdlg32\ChooseFont","UPtr",CHOOSEFONT.ptr)
            return false

        m[param 'f'] := StrGet(LOGFONT.ptr+28)
        m['bold'] := ((b := NumGet(LOGFONT,16,"UInt")) <= 400) ? 0 : 1
        m['italic'] := !!NumGet(LOGFONT,20,"Char")
        m['underline'] := NumGet(LOGFONT,21,"Char")
        m['strike'] := NumGet(LOGFONT,22,"Char")
        m[param 's'] := Round(NumGet(CHOOSEFONT,p*4,"UInt") / 10)

        c := NumGet(CHOOSEFONT,(p=4)?6*p:5*p,"UInt") ; convert from BGR to RBG for output
        m[param 'c'] := Format("0x{:06X}",RGB_BGR(c))
        m['bc'] := this.gMain.cbb_bc.Text

        str := "norm"
        str .= m['bold']      ? " bold" : ""
        str .= m['italic']    ? " italic" : ""
        str .= m['strike']    ? " strike" : ""
        str .= m['underline'] ? " underline" : ""
        m[param 'fo'] := Trim(str)
        return m

        RGB_BGR(c) => ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)
    }

    /********************************************************************************************
     * @credits DisplayCheck by the-Automator
     * @see {@link https://www.the-automator.com/downloads/maestrith-notify-class-v2 the-automator.com}
     */
    static MonitorGetInfo(*)
    {
        if Notify.Exist('monitorInfo')
            return

        monCount := MonitorGetCount()
        monPrimary := MonitorGetPrimary()
        Notify.Show('Monitor Info', 'Monitor Count: ' monCount '`nPrimary Monitor: ' monPrimary '`nClick here to close all Monitor Info GUIs.',,,
        (*) => Notify.Destroy('monitorInfo'),
        this.strOpts 'dur=0 pos=tc mali=center tali=center tfo=underline theme=okdark style=edge tag=monitorInfo image=none')

        Loop monCount {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            MonitorGetWorkArea(A_Index, &monWALeft, &monWATop, &monWARight, &monWABottom)
            Notify.Show('Monitor #' A_Index,
                (
                'Left:`t' monLeft ' (WorkArea: ' monWALeft ')
                Top:`t' monTop ' (WorkArea: ' monWATop ')
                Right:`t' monRight ' (WorkArea: ' monWARight ')
                Bottom:`t' monBottom ' (WorkArea: ' monWABottom ')'
                ),,,, this.strOpts 'dur=0 mon=' A_Index ' pos=ct tali=center theme=okdark tag=monitorInfo image=none'
            )
        }
    }

    ;============================================================================================

    static gTheme_Show(addOrEdit:='', *)
    {
        theme := this.gMain.ddl_theme.Text

        switch {
            case addOrEdit == 'edit' && theme = 'default': strTitle := 'Edit Default Settings'
            case addOrEdit == 'edit': strTitle := 'Edit Theme'
            case addOrEdit == 'add': strTitle := 'Add Theme'
        }

        this.gTheme := Gui('-MinimizeBox', strTitle ' - ' this.scriptName)
        this.gTheme.Opt('+Resize +MinSize540x525')
        this.gTheme.OnEvent('Size', this.gTheme_Size.Bind(this))
        this.gTheme.SetFont('s10')
        this.gTheme.BackColor := 'White'
        this.gTheme.Tips := GuiCtrlTips(this.gTheme)
        this.gTheme.Tips.SetDelayTime('AUTOPOP', 30000)
        try this.gMain.Opt('+Disabled')
        try this.gTheme.Opt('+Owner' this.gMain.hwnd)

        lvWidth := 675
        this.gTheme.lvHeight := 500
        this.gTheme.gbHeight := 60
        btnSize := 30

        switch {
            case addOrEdit == 'edit' && theme = 'default': gbWidth := 510
            case addOrEdit == 'edit' && Notify.mOrig_mThemes.Has(theme): gbWidth := 400
            case addOrEdit == 'edit' && !Notify.mOrig_mThemes.Has(theme): gbWidth := 365
            case addOrEdit == 'add': gbWidth := 330
        }

        this.gTheme.gb_theme := this.gTheme.Add('GroupBox',  'w' gbWidth ' h' this.gTheme.gbHeight ' cBlack  Section', addOrEdit == 'edit' && theme = 'default' ? '' : '    Theme')
        addOrEdit == 'edit' && theme = 'default' ? (picPos := 'xp+8 yp+25', editPos := 'x+6 yp-2') : (picPos := 'xs+6 ys+1', editPos := 'xp+6 yp+22')
        this.gTheme.pic_addOrEdit := this.gTheme.Add('Picture', picPos ' w16 h16', this.mIcons[(addOrEdit == 'add' ? 'add' : 'btn_edit')])
        this.gTheme.edit_themeName := this.gTheme.Add('Edit', editPos ' w165 h23 -Wrap', addOrEdit == 'add' ? '' : theme)
        this.gTheme.edit_themeName.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gTheme_EnableDisable_Btns', theme))
        ; this.gTheme.edit_themeName.OnEvent('Change', this.gTheme_EnableDisable_Btns.Bind(this, theme, addOrEdit))

        ;==============================================

        if (addOrEdit == 'add' || (addOrEdit == 'edit' && theme != 'default'))
        {
            this.gTheme.btn_copyOptStr := this.gTheme.Add('Button', 'x+8 yp-3 w' btnSize ' h' btnSize)
            this.gTheme.btn_copyOptStr.OnEvent('Click', this.gTheme_btn_copyOptStr_Click.Bind(this))
            GuiButtonIcon(this.gTheme.btn_copyOptStr, this.mIcons['clipBoard'], 1, 's20')
            this.gTheme.btn_unCheckAll := this.gTheme.Add('Button', 'x+5 w' btnSize ' h' btnSize)
            this.gTheme.btn_unCheckAll.OnEvent('Click', this.gTheme_CheckAll_UncheckAll.Bind(this, theme, 'unCheckAll'))
    		GuiButtonIcon(this.gTheme.btn_unCheckAll, this.mIcons['unCheckAll'], 1, 's20')
            this.gTheme.btn_checkAll := this.gTheme.Add('Button', 'x+5 w' btnSize ' h' btnSize)
            this.gTheme.btn_checkAll.OnEvent('Click', this.gTheme_CheckAll_UncheckAll.Bind(this, theme, 'checkAll'))
            GuiButtonIcon(this.gTheme.btn_checkAll, this.mIcons['checkAll'], 1, 's20')
            this.gTheme.btn_checkBasic := this.gTheme.Add('Button', 'x+5 w' btnSize ' h' btnSize)
            this.gTheme.btn_checkBasic.OnEvent('Click', this.gTheme_Check_Basic_Theme.Bind(this, theme, 'basic'))
    		GuiButtonIcon(this.gTheme.btn_checkBasic, this.mIcons['checkBasic'], 1, 's20')
            this.gTheme.Tips.SetTip(this.gTheme.btn_copyOptStr, 'Copy the checked settings in string format to clipboard.`nFor example: "tc=White tf=Segoe UI"')
            this.gTheme.Tips.SetTip(this.gTheme.btn_checkAll, 'Check All')
            this.gTheme.Tips.SetTip(this.gTheme.btn_unCheckAll, 'Uncheck All')
            this.gTheme.Tips.SetTip(this.gTheme.btn_checkBasic, 'Check basic theme settings.')
        }

        ;==============================================

        if (addOrEdit == 'edit' && theme != 'default')
        {
            this.gTheme.btn_checkTheme := this.gTheme.Add('Button', 'x+5 w' btnSize ' h' btnSize)
            this.gTheme.btn_checkTheme.OnEvent('Click', this.gTheme_Check_Basic_Theme.Bind(this, theme, 'theme'))
    		GuiButtonIcon(this.gTheme.btn_checkTheme, this.mIcons['checkTheme'], 1, 's20')
            this.gTheme.Tips.SetTip(this.gTheme.btn_checkTheme, 'Check the current theme`'s settings.')
        }

        ;==============================================

        if (addOrEdit == 'edit' && theme = 'default')
        {
            this.gTheme.txt_defTheme := this.gTheme.Add('Text', 'x+15 yp+2', 'Default theme:')
            this.gTheme.ddl_defTheme := this.gTheme.Add('DropDownList', 'x+8 yp-2 vdefTheme', this.arrTheme)
            this.gTheme.ddl_defTheme.OnEvent('Change', this.DebounceCall.Bind(this, 125, 'gTheme_ddl_defTheme_Change'))
            this.DDLchoose(Notify.mDefaults['theme'], this.arrTheme, this.gTheme.ddl_defTheme)
        }

        ;==============================================

        if (addOrEdit == 'edit' && (theme = 'default' || Notify.mOrig_mThemes.Has(theme)))
        {
            this.gTheme.edit_themeName.Enabled := false
            this.gTheme.btn_resetThemeOrig := this.gTheme.Add('Button', (addOrEdit == 'edit' && theme = 'default' ? 'x+8 yp-3' : 'x+5') ' w' btnSize ' h' btnSize)
            this.gTheme.btn_resetThemeOrig.OnEvent('Click', this.gTheme_resetTheme.Bind(this, theme))
            this.gTheme.txt_resetThemeOrig := this.gTheme.AddText("xp yp wp hp BackGroundTrans +0x100")
    		GuiButtonIcon(this.gTheme.btn_resetThemeOrig, this.mIcons['resetTheme'], 1, 's20')

            for value in ['txt', 'btn']
                this.gTheme.Tips.SetTip(this.gTheme.%value%_resetThemeOrig, 'Reset the ' (theme = 'default' ? 'default' : 'theme') ' to its original settings.')
        }

        ;==============================================

        switch {
            case addOrEdit == 'edit' && theme = 'default':
                arrHeader := ['Setting', 'User', 'Current Default', 'Original Default']

            case addOrEdit == 'edit' && Notify.mOrig_mThemes.Has(theme):
                arrHeader := ['Setting', 'User', 'Current Theme', 'Original Theme', 'Current Default']

            case addOrEdit == 'edit' && !Notify.mOrig_mThemes.Has(theme):
                arrHeader := ['Setting', 'User', 'Current Theme', 'Current Default']

            case addOrEdit == 'add':
                arrHeader := ['Setting', 'User', 'Current Default']
        }

        this.gTheme.lv := this.gTheme.Add('ListView', 'xm w' lvWidth ' h' this.gTheme.lvHeight ' Grid ' (addOrEdit == 'edit' && theme = 'default' ? '' : 'Checked') ' NoSort +BackgroundEAF4FB', arrHeader)
        this.gTheme.lv.OnEvent('ItemCheck', this.gTheme_lv_ItemCheck.Bind(this, theme))

        ;==============================================

        this.gTheme.btnOCAwidth := 120
        this.gTheme.btnOCAheight := 35
        this.gTheme.cntbtns := (addOrEdit == 'add' ? 2 : 3)
        this.gTheme.btnsOCAwidth := this.gTheme.btnOCAwidth*this.gTheme.cntbtns + this.gTheme.MarginX*(this.gTheme.cntbtns-1)
        btnOCAPos := lvWidth - this.gTheme.btnsOCAwidth + this.gTheme.MarginX
        this.gTheme.btn_ok := this.gTheme.Add('Button', 'x' btnOCAPos ' y' this.gTheme.gbHeight + this.gTheme.lvHeight + this.gTheme.MarginY*4.5 ' w' this.gTheme.btnOCAwidth ' h' this.gTheme.btnOCAheight ' Default', 'OK')
        this.gTheme.btn_ok.OnEvent('Click', this.gTheme_btnOK_btnApply_Click.Bind(this, theme, addOrEdit))
        this.gTheme.btn_cancel := this.gTheme.Add('Button', 'x+m w' this.gTheme.btnOCAwidth ' h' this.gTheme.btnOCAheight, 'Cancel')
        this.gTheme.btn_cancel.OnEvent('Click', this.GUI_Close.Bind(this, 'gTheme'))
        this.gTheme.OnEvent('Close', this.GUI_Close.Bind(this, 'gTheme'))

        if (addOrEdit == 'edit') {
            this.gTheme.btn_apply := this.gTheme.Add('Button', 'x+m w' this.gTheme.btnOCAwidth ' h' this.gTheme.btnOCAheight, 'Apply')
            this.gTheme.btn_apply.OnEvent('Click', this.gTheme_btnOK_btnApply_Click.Bind(this, theme, addOrEdit))
        }

        this.gTheme.gb_theme.SetFont('bold')

        ;==============================================

        m := this.Submit_ObjectToMap(this.gMain.Submit(0))
        bdrC := this.gMain.cbb_bdrC.Text

        for value in ['t', 'm']
            m[value 'fo'] := this.BuildFontOptionsString(value)

        for value in this.arrOpts {
            switch value[2], false {
                case 'pad':
                {
                    for index, value in ['gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY']
                        strPadUser .= m[value] ','
                    user := ',,' RTrim(strPadUser, ',')
                }
                case 'bdr': user := this.gMain.cbb_bdrc.Enabled ? bdrC : 0
                case 'width': user := this.gMain.edit_width.Enabled ? m['width'] : ''
                case 'maxW': user := this.gMain.edit_maxW.Enabled ? m['maxW'] : ''
                case 'minH': user := this.gMain.edit_minH.Enabled ? m['minH'] : ''
                default: user := m[value[2]]
            }

            switch {
                case (addOrEdit == 'edit' && theme = 'default'):
                    col3 := Notify.mDefaults[value[2]]
                    col4 := Notify.mOrig_mDefaults[value[2]]

                case (addOrEdit == 'edit' && Notify.mOrig_mThemes.Has(theme)):
                    col3 := this.HasVal(value[2], Notify.mThemes[theme]['arrKeyDefined']) ? Notify.mThemes[theme][value[2]] : ''
                    col4 := Notify.mOrig_mThemes.Has(theme) && Notify.mOrig_mThemes[theme].Has(value[2]) ? Notify.mOrig_mThemes[theme][value[2]] : ''
                    col5 := Notify.mDefaults[value[2]]

                case (addOrEdit == 'edit' && !Notify.mOrig_mThemes.Has(theme)):
                    col3 := this.HasVal(value[2], Notify.mThemes[theme]['arrKeyDefined']) ? Notify.mThemes[theme][value[2]] : ''
                    col4 := Notify.mDefaults[value[2]]

                case addOrEdit == 'add':
                    col3 := Notify.mDefaults[value[2]]
            }
            this.gTheme.lv.Add('', value[1], user, col3, col4 ?? '', col5 ?? '')
        }

        Loop 5
            this.gTheme.lv.ModifyCol(A_Index, 'AutoHdr')

        ;==============================================

        this.mThemeCurrent := this.MapCI(), this.mThemeLV := this.MapCI()

        for value in this.arrOpts {
            key := value[2]
            rowTxt := this.gTheme.lv.GetText(A_Index, 2)

            if (addOrEdit == 'edit' && theme = 'default') {
                this.mThemeCurrent[key] := Notify.mDefaults[key]
                this.mThemeLV[key] := rowTxt

                if this.HasVal(key, this.arrOptsBasic)
                    this.gTheme.lv.Modify(A_Index, 'Check')
            }
            else {
                if (addOrEdit == 'edit' && this.HasVal(key, Notify.mThemes[theme]['arrKeyDefined']))
                    this.mThemeCurrent[key] := Notify.mThemes[theme][key]

                if this.HasVal(key, (addOrEdit == 'edit' ? Notify.mThemes[theme]['arrKeyDefined'] : this.arrOptsBasic))
                    this.mThemeLV[key] := rowTxt, this.gTheme.lv.Modify(A_Index, 'Check')
            }
        }

        if (addOrEdit == 'edit' && theme = 'default')
            this.mThemeCurrent['theme'] := this.mThemeLV['theme'] := Notify.mDefaults['theme']

        this.gTheme_EnableDisable_Btns([theme])
        LV_GridColor(this.gTheme.lv, '0xcbcbcb')
        try ControlFocus(this.gTheme.btn_ok.hwnd, this.gTheme.hwnd)
        this.ShowGUIRelativeToOwner(this.gMainTitle, 'gTheme')
    }

    ;============================================================================================

    static gTheme_ddl_defTheme_Change(*)
    {
        this.mThemeLV['theme'] := this.gTheme.ddl_defTheme.Text
        this.gTheme_EnableDisable_Btns(['Default'])
    }

    ;============================================================================================

    static gTheme_lv_ItemCheck(theme, objCtrl, item, checked, *)
    {
        key := this.arrOpts[item][2]
        rowTxt := this.gTheme.lv.GetText(item, 2)
        checked ? this.mThemeLV[key] := rowTxt : this.mThemeLV.Delete(key)
        this.gTheme_EnableDisable_Btns([theme])
    }

    ;============================================================================================

    static gTheme_btnOK_btnApply_Click(theme, addOrEdit, ctrlObj, *)
    {
        if (!editTheme := this.gTheme.edit_themeName.Text) || (editTheme != 'default' && !this.mThemeLV.Count)
            return

        if (addOrEdit == 'edit' && ctrlObj.Text == 'OK' && this.ControlExist('gTheme', 'btn_apply') && !this.gTheme.btn_apply.Enabled) {
            this.GUI_Close('gTheme')
            return
        }

        if (addOrEdit == 'add' && Notify.mThemes.Has(editTheme))
        || (addOrEdit == 'edit' && Notify.mThemes.Has(editTheme) && theme != editTheme) {
            Notify.Show('Duplicate Theme', 'A theme with this name already exists.', 'none',,, this.strOpts 'dg=5 tag=dupTheme theme=!Dark pos=bc tali=center mali=center')
            return
        }

        ;==============================================

        if (editTheme != 'default') {
            if (addOrEdit == 'edit') {
                if Notify.mThemes.Has(theme)
                    Notify.mThemes.Delete(theme)

                if index := this.HasVal(theme, this.arrTheme)
                    this.arrTheme.RemoveAt(index)
            }

            this.arrTheme.Push(editTheme)
            this.arrTheme := this.SortArray(this.arrTheme)
            this.DDLArrayChange_Choose(editTheme, this.arrTheme, this.gMain.ddl_theme)
        }

        ;==============================================

        Notify.mThemes[editTheme] := this.MapCI()
        mTheme := Notify.mThemes[editTheme]

        if (addOrEdit == 'edit' && theme = 'default') {
            for value in this.arrOpts {
                rowTxt := this.gTheme.lv.GetText(A_Index, 2)
                key := value[2]
                this.mThemeLV[key] := this.mThemeCurrent[key] := Notify.mDefaults[key] := rowTxt

                if (ctrlObj.Text == 'Apply')
                    this.gTheme.lv.Modify(A_Index, 'Col3', rowTxt)
            }
            this.mThemeCurrent['theme'] := Notify.mDefaults['theme'] := this.gTheme.ddl_defTheme.Text
        }
        else {
            mTheme['arrKeyDefined'] := Array()
            this.mThemeCurrent := this.MapCI()

            for key, value in this.mThemeLV {
                mTheme[key] := value
                mTheme['arrKeyDefined'].Push(key)
                this.mThemeCurrent[key] := value
            }

            for value in this.arrOpts {
                rowTxt := this.gTheme.lv.GetText(A_Index, 2)
                key := value[2]

                if (this.mThemeLV.Has(key)) {
                    if (ctrlObj.Text == 'Apply')
                        this.gTheme.lv.Modify(A_Index, 'Col3', rowTxt)
                } else {
                    if (ctrlObj.Text == 'Apply')
                        this.gTheme.lv.Modify(A_Index,,, Notify.mDefaults[key], '')
                }
            }
        }

        ;==============================================

        this.ResetValues(mTheme, editTheme, ctrlObj.Text)

        for value in ['sound', 'image']
            if !this.Hasval(mTheme[value], this.arr%value%Notify)
                this.arr%value%Notify.Push(mTheme[value])

        if !this.Hasval(mTheme['bgImg'], this.arrImageNotify)
            this.arrImageNotify.Push(mTheme['bgImg'])

        this.SaveToJSONpreferences()
        this.gMain_SetStatusBar()
        this.SetIconTip()

        if this.ControlExist('gTheme', 'btn_apply')
            this.gTheme.btn_apply.Enabled := false

        if ctrlObj.Text == 'OK'
            this.GUI_Close('gTheme')
    }

    ;============================================================================================

    static ResetValues(mTheme, editTheme, txtBtn)
    {
        if (editTheme = 'default') {
            for key, mTheme in Notify.mThemes {
                for k, v in mTheme.Clone()
                    if !this.HasVal(k, mTheme['arrKeyDefined']) && k != 'arrKeyDefined'
                        mTheme.Delete(k)
                SetVariousValues(mTheme)
            }
        } else SetVariousValues(mTheme)

        this.gMain_SetAllValues(editTheme)

        if txtBtn == 'Apply'
            Loop 4
                this.gTheme.lv.ModifyCol(A_Index, 'AutoHdr')

        ;==============================================

        SetVariousValues(mTheme) {
            Notify.SetDefault_MiscValues(mTheme)

            for index, key in ['padX', 'padY', 'gmT', 'gmB', 'gmL', 'gmR', 'spX', 'spY']
                if mTheme.Has(key)
                    mTheme.Delete(key)

            Notify.ParsePadOption(mTheme)
            Notify.SetPadDefault(mTheme)
            Notify.ParseBorderOption(mTheme)

            if RegExMatch(mTheme['bdr'], '^(1|0)$')
                mTheme['bdrC'] := 'default'

            mTheme['bdrW'] := mTheme.Get('bdrW', Notify.bdrWdefaultEdge)
            Notify.NormAllColors(mTheme)
        }
    }

    ;============================================================================================

    static gTheme_resetTheme(theme, *)
    {
        this.mThemeLV := this.MapCI()

        if (theme = 'default') {
            for value in this.arrOpts
                this.mThemeLV[value[2]] := Notify.mOrig_mDefaults[value[2]]

            this.mThemeLV['theme'] := Notify.mOrig_mDefaults['theme']
            this.DDLchoose(Notify.mOrig_mDefaults['theme'], this.arrTheme, this.gTheme.ddl_defTheme)
        }
        else {
            mThemeOrig := Notify.mOrig_mThemes[theme]

            for key in mThemeOrig['arrKeyDefined']
                this.mThemeLV[key] := mThemeOrig[key]
        }

       ;==============================================

        for value in this.arrOpts {
            key := value[2]

            if (theme != 'default')
                this.gTheme.lv.Modify(A_Index, 'Col3 -Check', '')

            if (theme = 'default') {
                this.gTheme.lv.Modify(A_Index, 'Col2', Notify.mOrig_mDefaults[key])
            }
            else {
                currentValue := (this.mThemeCurrent.Has(key) ? this.mThemeCurrent[key] : '')

                if mThemeOrig.Has(key)
                    this.gTheme.lv.Modify(A_Index, '+Check',, mThemeOrig[key], currentValue)
                else
                    this.gTheme.lv.Modify(A_Index,,, Notify.mDefaults[key], currentValue)
            }
        }

        this.gTheme.lv.ModifyCol(2, 'AutoHdr')
        this.gTheme.lv.ModifyCol(3, 'AutoHdr')
        this.gTheme_EnableDisable_Btns([theme])
        try ControlFocus(this.gTheme.btn_ok.hwnd, this.gTheme.hwnd)
    }

    ;============================================================================================

    static gTheme_CheckAll_UncheckAll(theme, check, *)
    {
        this.mThemeLV := this.MapCI()
        this.gTheme.lv.Modify(0, (check = 'checkAll') ? 'Check' : '-Check')

        if (check == 'checkAll') {
            for value in this.arrOpts {
                rowTxt := this.gTheme.lv.GetText(A_Index, 2)
                key := value[2]
                this.mThemeLV[key] := rowTxt
            }
        }

        this.gTheme_EnableDisable_Btns([theme])
    }

    ;============================================================================================

    static gTheme_Check_Basic_Theme(theme, param, *)
    {
        this.mThemeLV := this.MapCI()

        for value in this.arrOpts {
            key := value[2]
            rowTxt := this.gTheme.lv.GetText(A_Index, 2)

            if this.HasVal(key, param = 'theme' ? Notify.mThemes[theme]['arrKeyDefined'] : this.arrOptsBasic)
                this.mThemeLV[key] := rowTxt

            this.gTheme.lv.Modify(A_Index, this.HasVal(key, param = 'theme' ? Notify.mThemes[theme]['arrKeyDefined'] : this.arrOptsBasic) ? 'Check' : '-Check')
        }

        this.gTheme_EnableDisable_Btns([theme])
    }

    ;============================================================================================

    static gTheme_btn_copyOptStr_Click(*)
    {
        theme := this.gTheme.edit_themeName.Text

        Loop this.gTheme.lv.GetCount()
            if this.IsChecked(A_Index)
                strOpts .=  (text := this.gTheme.lv.GetText(A_Index, 2)) != '' ? this.arrOpts[A_Index][2] '=' text ' ' : ''

        if strOpts := RTrim(strOpts ?? '')
            this.CopyToClipboard('export', strOpts)
    }

    ;============================================================================================

    static gTheme_EnableDisable_Btns(arrParams, *)
    {
        this.gTheme_btn_resetThemeOrig_EnableDisable(arrParams[1])
        this.gTheme_btn_apply_EnableDisable(arrParams[1])
    }

    ;============================================================================================

    static gTheme_btn_resetThemeOrig_EnableDisable(theme, *)
    {
        if !this.ControlExist('gTheme', 'btn_resetThemeOrig')
            return

        mThemeOrig := this.MapCI()

        if (theme = 'default') {
            for value in this.arrOpts
                mThemeOrig[value[2]] := Notify.mOrig_mDefaults[value[2]]

            mThemeOrig['theme'] := Notify.mOrig_mDefaults['theme']
        }
        else
            for key in Notify.mOrig_mThemes[theme]['arrKeyDefined']
                mThemeOrig[key] := Notify.mOrig_mThemes[theme][key]

        if !this.isMapIdentical(this.mThemeLV, mThemeOrig)
            enabled := true

        this.gTheme.btn_resetThemeOrig.Enabled := enabled ?? false
    }

    ;============================================================================================

    static gTheme_btn_apply_EnableDisable(theme, *)
    {
        if !this.ControlExist('gTheme', 'btn_apply')
            return

        editTheme := this.gTheme.edit_themeName.Text

        if (editTheme !== theme || !Notify.mThemes.Has(editTheme)) {
            this.gTheme.btn_apply.Enabled := true
            return
        }

        if !this.isMapIdentical(this.mThemeLV, this.mThemeCurrent)
            enabled := true

        this.gTheme.btn_apply.Enabled := enabled ?? false
    }

    ;============================================================================================

    static SaveToJSONpreferences()
    {
        m := this.MapCI().Set('mThemes', this.MapCI(), 'mDefaults', this.MapCI())

        for theme, mTheme in Notify.mThemes {
            switch theme, false {
                case 'default':
                {
                    for value in this.arrOpts
                        m['mDefaults'][value[2]] := Notify.mDefaults[value[2]]

                    m['mDefaults']['theme'] := Notify.mDefaults['theme']
                }
                default:
                    if (Notify.mOrig_mThemes.Has(theme)) {
                        BuildThemeMapObject(mCurrentTheme := this.MapCI(), Notify.mThemes[theme])
                        BuildThemeMapObject(mOrigTheme := this.MapCI(), Notify.mOrig_mThemes[theme])

                        if (!this.isMapIdentical(mCurrentTheme, mOrigTheme))
                            BuildThemeMapObject(m['mThemes'][theme] := this.MapCI(), mTheme)
                    } else BuildThemeMapObject(m['mThemes'][theme] := this.MapCI(), mTheme)
            }
        }

        str := _JSON_thqby.stringify(m, expandlevel := unset, space := "  ")
        objFile := FileOpen('Preferences.json', 'w', 'UTF-8')
        objFile.Write(str)
        objFile.Close()

        BuildThemeMapObject(m, mTheme) {
            for v in mTheme['arrKeyDefined']
                m[v] := mTheme[v]
        }
    }

    ;============================================================================================

    static gTheme_Size(guiObj, minMax, width, height)
    {
        if minMax = -1
            return

        cntbtns := this.gTheme.cntbtns

        this.MoveControls(
            {Control:this.gTheme.lv, h:height - this.gTheme.gbHeight - this.gTheme.btnOCAheight - this.gTheme.MarginY*6, w:width - this.gTheme.MarginX*2},
            {Control:this.gTheme.btn_ok, x:width - this.gTheme.btnOCAwidth*cntbtns - this.gMain.MarginX*cntbtns, y:height - this.gTheme.btnOCAheight - this.gTheme.MarginY*2},
            {Control:this.gTheme.btn_cancel, x:width - this.gTheme.btnOCAwidth*(cntbtns-1) - this.gMain.MarginX*(cntbtns-1), y:height - this.gTheme.btnOCAheight - this.gTheme.MarginY*2},
        )

        if this.ControlExist('gTheme', 'btn_apply')
            this.MoveControls({Control:this.gTheme.btn_apply, x:width - this.gTheme.btnOCAwidth - this.gMain.MarginX, y:height - this.gTheme.btnOCAheight - this.gTheme.MarginY*2})

        DllCall('RedrawWindow', 'ptr', this.gTheme.hwnd, 'ptr', 0, 'ptr', 0, 'uint', 0x0081)
    }

    ;============================================================================================

    static gList_Show(param, *)
    {
        remOrDel := RegExMatch(param, '^(image|sound)$') ? 'Remove' : 'Delete'
        this.gList := Gui('+Resize +MinSize400x400 -MinimizeBox', remOrDel ' ' StrTitle(param)  ' - ' this.scriptName)
        this.gList.OnEvent('Size', this.gList_Size.Bind(this))
        this.gList.SetFont('s10')
        this.gList.Tips := GuiCtrlTips(this.gList)
        this.gList.Tips.SetDelayTime('AUTOPOP', 30000)
        try this.gMain.Opt('+Disabled')
        try this.gList.Opt('+Owner' this.gMain.hwnd)

        this.gList.lvWidth := 575
        this.gList.btnSize := 30
        this.gList.btn_delete := this.gList.Add('Button',  'w100 h' this.gList.btnSize, StrTitle(remOrDel))
        this.gList.btn_delete.OnEvent('Click', this.gList_lv_Remove.Bind(this, param, remOrDel))
        GuiButtonIcon(this.gList.btn_delete, this.mIcons['delete'], 1, 's18 a0 l12')
        this.gList.Tips.SetTip(this.gList.btn_delete, remOrDel ' selected ' param 's.')
        this.gList.btn_checkAll := this.gList.Add('Button', 'x+5 w' this.gList.btnSize ' h' this.gList.btnSize)
        this.gList.btn_checkAll.OnEvent('Click', (*) => this.gList.lv.Modify(0, '+Select'))
        GuiButtonIcon(this.gList.btn_checkAll, this.mIcons['selectAll'], 1, 's20')
        this.gList.Tips.SetTip(this.gList.btn_checkAll, 'Select All')
        this.gList.lv := this.gList.Add('ListView', 'xm w' this.gList.lvWidth ' h500 Grid Section Sort +BackgroundEAF4FB', [StrTitle(param)])
        this.gList.lv.OnEvent('ContextMenu', this.gList_ContextMenu.Bind(this, param, remOrDel))

        gListWidth := this.gList.lvWidth + this.gList.MarginX*2
        this.gList.btnHeight := 35
        this.gList.btnWidth := 120
        btnPosX := gListWidth/2 - this.gList.btnWidth/2
        this.gList.btn_close := this.gList.Add('Button', 'x' btnPosX ' w' this.gList.btnWidth ' h' this.gList.btnHeight ' Default', 'Close')
        this.gList.btn_close.OnEvent('Click', this.GUI_Close.Bind(this, 'gList'))
        this.gList.OnEvent('Close', this.GUI_Close.Bind(this, 'gList'))
        LV_GridColor(this.gList.lv, '0xcbcbcb')

        switch param {
            case 'image','sound':
            {
                this.RemoveNonExistentFiles([param], 'updateResultStr')

                if param == 'image'
                    imageList := IL_Create(), this.gList.lv.SetImageList(imageList)

                for item in this.arr%param% {
                    if (item != 'None' && !this.HasVal(item, this.arr%param%Notify)) {
                        switch param {
                            case 'image':
                                switch {
                                    case RegExMatch(item, 'i)^(.+?\.(?:dll|exe|cpl))\|icon(\d+)$', &matchIcon) && FileExist(matchIcon[1]):
                                        this.gList.lv.Add('Icon' IL_Add(imageList, matchIcon[1], matchIcon[2]), item)
                                    case FileExist(item):
                                        this.gList.lv.Add('Icon' IL_Add(imageList, item), item)
                                }
                            case 'sound': this.gList.lv.Add('', item)
                        }
                    }
                }
            }
            case 'theme':
                for theme in this.SortArray(this.MapToArray(Notify.mThemes))
                    if !Notify.mOrig_mThemes.Has(theme) && theme != 'default'
                        this.gList.lv.Add('', theme)
        }

        this.gList.lv.ModifyCol(1, 'AutoHdr')
        this.ShowGUIRelativeToOwner(this.gMainTitle, 'gList')
    }

    ;============================================================================================

    static gList_Size(guiObj, minMax, width, height)
    {
        if minMax = -1
            return

        this.MoveControls(
            {Control:this.gList.lv, h:height - this.gList.btnSize - this.gList.btnHeight - this.gList.MarginY*5, w:width - this.gList.MarginX*2},
            {Control:this.gList.btn_close, x:width - width/2 - this.gList.btnWidth/2, y:height - this.gList.btnHeight - this.gList.MarginY*1.5},
        )

        this.gList.lv.ModifyCol(1, width - this.gList.MarginX*2 - 5)
        DllCall('RedrawWindow', 'ptr', this.gList.hwnd, 'ptr', 0, 'ptr', 0, 'uint', 0x0081)
    }

    ;============================================================================================

    static gList_ContextMenu(param, remOrDel, objCtrl, item, isRightClick, x, y)
    {
        MouseGetPos(,,, &mouseOverClassNN)
        if item = 0 || InStr(mouseOverClassNN, 'SysHeader')
            return

        ctxMenu := Menu()
        ctxMenu.Add(remOrDel, this.gList_lv_Remove.Bind(this, param, remOrDel))
        ctxMenu.SetIcon(remOrDel, this.mIcons['menuDelete'])
        ctxMenu.Show(x, y)
    }

    ;============================================================================================

    static gList_lv_Active(*)
    {
        mDhwTmm := Notify.Set_DHWindows_TMMode(0, 2)

        if this.ControlExist('gList', 'lv') && WinActive('- ' this.scriptName ' ahk_class AutoHotkeyGUI')
            flag := true

        Notify.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
        return flag ?? false
    }

    ;============================================================================================

    static gList_lv_SelectAll(*) => this.gList.lv.Modify(0, '+Select')

    ;============================================================================================

    static gList_lv_Remove(param:='', remOrDel:='', *)
    {
        if !selectedContent := ListViewGetContent('Col1 Selected', this.gList.lv.hwnd)
            return

        if (param == 'hotkey') {
            try winTitle := WinGetTitle('A')
            catch
                return

            remOrDel := (RegExMatch(winTitle, 'i)^(image|sound)$') ? 'Remove' : 'Delete')
            switch {
                case InStr(winTitle, 'image'): param := 'image'
                case InStr(winTitle, 'sound'): param := 'sound'
                case InStr(winTitle, 'theme'): param := 'theme'
            }
        }

        if (StrSplit(selectedContent, '`n').Length > 1) {
			this.gList.Opt('+OwnDialogs')

            switch param {
                case 'image', 'sound': txtMsg := 'Are you sure you want to remove all selected ' param 's from the history?'
                case 'theme': txtMsg := 'Are you sure you want to delete all selected themes?'
            }

			try {
				if MsgBox(txtMsg, remOrDel ' Confirmation - ' this.scriptName, 'OKCancel Icon?') == 'OK'
                    this.DeleteEntry_ClickYes(selectedContent, param)
            } catch
				return
		}
        else
            this.DeleteEntry_ClickYes(selectedContent, param)
    }

    ;============================================================================================

    static DeleteEntry_ClickYes(selectedContent, param, *)
    {
        switch param {
            case 'image', 'bgImg': strArr := 'image'
            case 'sound': strArr := 'sound'
            case 'theme': strArr := 'theme'
        }

		Loop Parse, selectedContent, '`n' {
			if index := this.HasVal(A_LoopField, this.arr%strArr%)
                this.arr%strArr%.RemoveAt(index)

            if (param == 'theme') {
                Notify.mThemes.Delete(A_LoopField)

                if A_LoopField = Notify.mDefaults['theme']
                    Notify.mDefaults['theme'] := 'Default'
            }
        }

        if (param == 'theme') {
            this.SaveToJSONpreferences()
            this.gMain_SetStatusBar()
            this.SetIconTip()
        }

		Loop this.gList.lv.GetCount('Selected')
            this.gList.lv.Delete(this.gList.lv.GetNext(0))

        this.gList.lv.ModifyCol(1, 'AutoHdr')

        switch param {
            case 'image', 'bgImg': updateResultStr := this.UpdateDDL_SetImagePreview()
            case 'sound': updateResultStr := this.UpdateDDL_Sound()
            case 'theme':
            {
                strTheme := this.gMain.ddl_%param%.Text
                targetValue := (this.HasVal(strTheme, this.arr%strArr%) ? strTheme : 'default')
                this.DDLArrayChange_Choose(targetValue, this.arr%strArr%, this.gMain.ddl_%param%)

                if strTheme != 'default' && targetValue = 'default'
                    this.gMain_SetAllValues('default'), updateResultStr := true
            }
        }

        if IsSet(updateResultStr)
            this.UpdateResultString()
    }

    ;============================================================================================

    static RemoveNonExistentFiles(arr, param:='')
    {
        if (this.HasVal('image', arr)) {
            for image in this.arrImage.Clone() {
                if !this.HasVal(image, this.arrImageNotify)
                && ((RegExMatch(image, 'i)^(.+?\.(?:dll|exe|cpl))\|icon(\d+)$', &match) && !FileExist(match[1]))
                || (RegExMatch(image, 'i)^(.+?\.(?:' Notify.strImageExt '))$') && !FileExist(image)))
                    (index := this.HasVal(image, this.arrImage)) && this.arrImage.RemoveAt(index)
            }
            updateResultStr := this.UpdateDDL_SetImagePreview()
        }

        if (this.HasVal('sound', arr)) {
            for sound in this.arrSound.Clone()
                if !this.HasVal(sound, this.arrSoundNotify) && !FileExist(sound) && (index := this.HasVal(sound, this.arrSound))
                    this.arrSound.RemoveAt(index)

            updateResultStr := this.UpdateDDL_Sound()
        }

        if param == 'updateResultStr' && updateResultStr
            this.UpdateResultString()
    }

    ;============================================================================================

    static UpdateDDL_SetImagePreview()
    {
        for value in ['image', 'bgImg'] {
            strImage := this.gMain.ddl_%value%.Text
            targetValue := (this.HasVal(strImage, this.arrImage) ? strImage : 'none')
            this.DDLArrayChange_Choose(targetValue, this.arrImage, this.gMain.ddl_%value%)

            if strImage != 'none' && targetValue = 'none'
                this.gMain_SetImagePreview('none', value), updateResultStr := true
        }
        return updateResultStr ?? false
    }

    ;============================================================================================

    static UpdateDDL_Sound()
    {
        strSound := this.gMain.ddl_sound.Text
        targetValue := (this.HasVal(strSound, this.arrSound) ? strSound : 'none')
        this.DDLArrayChange_Choose(targetValue, this.arrSound, this.gMain.ddl_sound)
        return ((strSound != 'none' && targetValue = 'none') ? true : false)
    }

    ;============================================================================================

	static gRip_Show(*)
	{
        static boundFuncTimer := 0

        if this.GuiExist(['gRip'])
            return

        if boundFuncTimer
            SetTimer(boundFuncTimer, 0)

        mGUI := Notify.Show('Please wait, loading icons...',, this.mIcons['notifgRip'],,,
            this.strOpts 'theme=iDark prog=h8 c0x41A5EE pos=tc dur=0 tc=0x95C0DD dgc=0 dg=5 tag=ResIconsPicker')

        boundFuncTimer := Notify.Destroy.Bind(Notify, 'ResIconsPicker')

		this.gRip := Gui(, this.gRipTitle)
		this.gRip.OnEvent('Close', this.gRip_Close.Bind(this))
		this.gRip.lv := this.gRip.Add('ListView', 'h600 w1015 +Icon', ['name', 'path', 'index'])
        this.gRip.lv.OnEvent('ContextMenu', this.gRip_ContextMenu.Bind(this))
        this.gRip.lv.OnEvent('DoubleClick', this.gRip_DoubleClick.Bind(this))

		if (!this.arrIcons.Length) {
            cntPath := 0
            for index, path in this.arrIconPaths.Clone() {
                if (FileExist(path)) {
                    SplitPath(path,,,, &fileName), cntPath++
                    Loop {
                        if !hIcon := LoadPicture(path, 'Icon' A_Index, &ImageType)
                            break
                        this.arrIcons.Push(Map('fileName', fileName, 'path', path, 'index', A_Index, 'cntPath', cntPath))
                        DllCall('DestroyIcon', 'ptr', hIcon)
                    }
                } else this.arrIconPaths.RemoveAt(index)
            }
        }

        imageListID := IL_Create(this.arrIcons.Length,, true)

        for index, mIco in this.arrIcons
			IL_Add(imageListID, mIco['path'], mIco['index'])

		this.gRip.lv.SetImageList(imageListID)

		for index, mIco in this.arrIcons {
            this.gRip.lv.Add('Icon' index, mIco['fileName'] ' (' mIco['index'] ')', mIco['path'], mIco['index'])
            mGUI['prog'].Value := (mIco['cntPath'] / this.arrIconPaths.Length) * 100
        }

        try mGUI['title'].Text := 'Icons loading completed.'
        SetTimer(boundFuncTimer, -5000)
        this.gRip.Add('StatusBar',, ' ' this.arrIconPaths.Length ' system resource files. ' this.arrIcons.Length ' icons.').SetFont('s10')
		this.gRip.Show()
	}

    ;============================================================================================

    static gRip_Close(*)
    {
        this.gRip.Destroy()
        Notify.Destroy('ResIconsPicker')
        try this.gPreviewIcon.Destroy()
    }

    ;============================================================================================

    static gRip_ShowPreview(name, path, index, *)
    {
        try this.gPreviewIcon.Destroy()
        this.gPreviewIcon := Gui('+ToolWindow +AlwaysOnTop -MinimizeBox -MaximizeBox', name)
        this.gPreviewIcon.OnEvent('Escape', (*) => this.gPreviewIcon.Destroy())

        cmmPrev := A_CoordModeMouse
        CoordMode('Mouse', 'Screen')
        MouseGetPos(&posX, &posY)
        CoordMode('Mouse', cmmPrev)

        this.gPreviewIcon.Add('Picture', 'w225 h-1 Icon' index, path)
        this.gPreviewIcon.Show('x' posX ' y' posY)
    }

    ;============================================================================================

    static gRip_DoubleClick(objCtrl, item)
    {
        if !selectedContent := ListViewGetContent('Selected', this.gRip.lv.hwnd, this.gRipTitle ' ahk_class AutoHotkeyGUI')
        || !WinExist(this.gMainTitle ' ahk_class AutoHotkeyGUI')
            return

        name := objCtrl.GetText(item, 1)
        path := objCtrl.GetText(item, 2)
        index := objCtrl.GetText(item, 3)
        this.gRipIconSelected([path '|icon' index])
    }

    ;============================================================================================

    static gRip_ContextMenu(objCtrl, item, isRightClick, x, y)
    {
        if !selectedContent := ListViewGetContent('Selected', this.gRip.lv.hwnd, this.gRipTitle ' ahk_class AutoHotkeyGUI')
            return

        name := objCtrl.GetText(item, 1)
        path := objCtrl.GetText(item, 2)
        index := objCtrl.GetText(item, 3)
        ctxMenu := Menu()

        if (WinExist(this.gMainTitle ' ahk_class AutoHotkeyGUI')) {
            arr := Array()

            Loop Parse, selectedContent, '`n'
                arrItem := StrSplit(A_LoopField, A_Tab), arr.Push(arrItem[2] '|icon' arrItem[3])

            ctxMenu.Add('Select Icon', this.gRipIconSelected.Bind(this, arr))
            ctxMenu.SetIcon('Select Icon', this.mIcons['select'])
        }

        ctxMenu.Add('Preview Icon', this.gRip_ShowPreview.Bind(this, name, path, index))
        ctxMenu.SetIcon('Preview Icon', this.mIcons['preview'])
        ctxMenu.Add('Copy to Clipboard (Notify): ' path '|icon' index, this.CopyToClipIVA.Bind(this))
        ctxMenu.Add('Copy to Clipboard (v1): Menu, Tray, Icon, ' path ', ' index, this.CopyToClipIVA.Bind(this))
        ctxMenu.Add('Copy to Clipboard (v2): TraySetIcon(`'' path '`', ' index ')', this.CopyToClipIVA.Bind(this))
        ctxMenu.Add('Copy to Clipboard (v2): hIcon := LoadPicture(`'' path '`', `'Icon' index '`', &imgType)', this.CopyToClipIVA.Bind(this))

        Loop 4
            ctxMenu.SetIcon(A_Index + (this.MenuItemExist(ctxMenu, 'Select Icon') ? 2 : 1) '&', this.mIcons['clipBoard'])

        ctxMenu.Show()
    }

    ;============================================================================================

    static CopyToClipIVA(itemName, *) => (RegExMatch(itemName, ': (.+)', &match), this.CopyToClipBoard(match[1]))

    ;============================================================================================

    static gRipIconSelected(arr, *)
    {
        if !WinExist(this.gMainTitle ' ahk_class AutoHotkeyGUI')
            return

        this.gRip_Close()
        try this.gMain.Opt('+Disabled')
        arrMenuitems := ['exit', 'reload', 'about', 'settings', 'ResIconsPicker', this.scriptName]
        this.TrayMenu_Enable_Disable('disable', arrMenuitems)
        this.ProcessFileInput(, 'image', arr, 'gRipIconSelected')
        this.TrayMenu_Enable_Disable('enable', arrMenuitems)
        try this.gMain.Opt('-Disabled')
    }

    ;============================================================================================

    static gSettings_Show(*)
    {
        if this.GuiExist(['gSettings', 'gAbout']) || (this.GuiExist(['gMain']) && !DllCall('User32\IsWindowEnabled', 'Ptr', this.gMain.hwnd, 'Int'))
            return

        this.gSettings := Gui('-MinimizeBox' , 'Settings - ' this.scriptName)
        this.gSettings.SetFont('s10')
        try this.gMain.Opt('+Disabled')
        try this.gSettings.Opt('+Owner' this.gMain.hwnd)

        gbHeighMisc := 105
        gbWidthMisc := 325
        gSettingsWidth := gbWidthMisc + this.gSettings.Marginx*2
        this.gSettings.gb_misc := this.gSettings.Add('GroupBox',  'w' gbWidthMisc ' h' gbHeighMisc ' cBlack')
        this.gSettings.cb_openMainOnStart := this.gSettings.Add('CheckBox', 'xp+10 yp+25 Section', ' Open the main GUI when the application starts.')
        this.gSettings.cb_closeMainExitApp := this.gSettings.Add('CheckBox', 'xs', ' Exit application when closing the main GUI.')
        this.gSettings.cb_soundOnSelection := this.gSettings.Add('CheckBox', 'xs', ' Play the sound when a sound is selected.')
        gbStartupHeight := 145
		gbStartupWidth := 325
        this.gSettings.gb_startup := this.gSettings.Add('GroupBox', 'xm ym+' gbHeighMisc + this.gSettings.MarginY ' w' gbStartupWidth ' h' gbStartupHeight ' cBlack', 'Startup')
        this.gSettings.Add('Text', 'xp+10 yp+28 Section', 'To automatically run this application on startup,`nadd its shortcut to the startup folder.')
        this.gSettings.Add('Button', 'xs yp+38 w160', 'Open Application Folder').OnEvent('Click', (*) => Run(A_WorkingDir))
        this.gSettings.Add('Button', 'xs yp+35 w160', 'Open Startup Folder').OnEvent('Click', (*) => Run(A_Startup))
        gbCustomWidth := 165
        gbCustomgHeight := 110
        this.gSettings.gb_custom := this.gSettings.Add('GroupBox', 'xm ym+' gbStartupHeight + gbHeighMisc + this.gSettings.MarginY*2 ' w' gbCustomWidth ' h' gbCustomgHeight ' cBlack', 'Customization')
        this.gSettings.Add('Text', 'xp+10 yp+28 Section', 'Tray menu icons size*')
        this.gSettings.ddl_trayMenuIconSize := this.gSettings.Add('DropDownList', 'xs w65', this.arrTrayMenuIconSize)
        this.gSettings.Add('Text', 'xs', '* Required reload').SetFont('s9')
        btnWidth := 120, btnHeight := 35
        btnPosX := gSettingsWidth - btnWidth*2 - this.gSettings.Marginx*2
        this.gSettings.MarginY := 15
        this.gSettings.btn_OK := this.gSettings.Add('Button', 'x' btnPosX ' w' btnWidth ' h' btnHeight ' Default', 'OK')
        this.gSettings.btn_OK.OnEvent('Click', this.gSettings_btn_OK_Click.Bind(this))
        this.gSettings.btn_Cancel := this.gSettings.Add('Button', 'x+' this.gSettings.MarginX ' w' btnWidth ' h' btnHeight, 'Cancel')
        this.gSettings.btn_Cancel.OnEvent('Click', this.GUI_Close.Bind(this, 'gSettings'))
        this.gSettings.OnEvent('Close', this.GUI_Close.Bind(this, 'gSettings'))

		for value in ['openMainOnStart', 'closeMainExitApp', 'soundOnSelection']
            this.gSettings.cb_%value%.Value := this.mUser[value]

        for value in ['startup', 'custom']
            this.gSettings.gb_%value%.SetFont('bold')

        this.DDLchoose(this.mUser['trayMenuIconSize'], this.arrTrayMenuIconSize, this.gSettings.ddl_trayMenuIconSize)
        this.ShowGUIRelativeToOwner(this.gMainTitle, 'gSettings', 'w' gSettingsWidth)
	}

    ;============================================================================================

    static gSettings_btn_OK_Click(ctrlObj, *)
    {
        for value in ['openMainOnStart', 'closeMainExitApp', 'soundOnSelection']
            this.mUser[value] := this.gSettings.cb_%value%.Value

        if (this.mUser['trayMenuIconSize'] != (txt := this.gSettings.ddl_trayMenuIconSize.Text)) {
            this.mUser['trayMenuIconSize'] := txt
            Reload()
        }

        this.GUI_Close('gSettings')
    }

    ;============================================================================================

    static gAbout_Show(*)
    {
        if this.GuiExist(['gAbout', 'gSettings']) || (this.GuiExist(['gMain']) && !DllCall('User32\IsWindowEnabled', 'Ptr', this.gMain.hwnd, 'Int'))
            return

        this.gAbout := Gui('-MinimizeBox', 'About - ' this.scriptName)
        this.gAbout.SetFont('s10')
        this.gAbout.BackColor := 'White'
        try this.gMain.Opt('+Disabled')
        try this.gAbout.Opt('+Owner' this.gMain.hwnd)

        this.gAbout.Add('Picture', 'y15 w50 h50', this.mIcons['mainAbout'])
        this.gAbout.SetFont('s16')
        this.gAbout.Add('Text', 'x+m w350 h50 Section', this.scriptName).SetFont('bold')
        this.gAbout.SetFont('s10')
        this.gAbout.Add('Text', 'yp+40', 'Version: ' this.scriptVersion)
        this.gAbout.Add('Text', 'yp+25', 'Author:')
        this.gAbout.Add('Link', 'x+10', '<a href="https://github.com/XMCQCX">Martin Chartier (XMCQCX)</a>')
        this.gAbout.Add('Text', 'xs yp+25', 'MIT license' )
        this.gAbout.Add('Text', 'xs yp+35 w125', 'Credits').SetFont('s12 bold')
        this.gAbout.SetFont('s10')
        this.gAbout.Add('Text', 'xs yp+40', 'Steve Gray, Chris Mallett, portions of AutoIt Team and various others.')
        this.gAbout.Add('Link', 'yp+20', '<a href="https://www.autohotkey.com">https://www.autohotkey.com</a>')
        this.gAbout.Add('Text', 'xs yp+15', '_____________________________')
        this.gAbout.Add('Link', 'xs yp+25', '<a href="https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk">JSON</a>')
        this.gAbout.Add('Text', 'x+5', 'by thqby, HotKeyIt.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/AHK-just-me/AHKv2_GuiCtrlTips">GuiCtrlTips</a>')
        this.gAbout.Add('Text', 'x+5', 'by just me.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.autohotkey.com/boards/viewtopic.php?f=83&t=125259">LVGridColor</a>')
        this.gAbout.Add('Text', 'x+5', 'by just me.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.autohotkey.com/boards/viewtopic.php?f=83&t=115871">GuiButtonIcon</a>')
        this.gAbout.Add('Text', 'x+5', 'by FanaticGuru.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/tylerjcw/YACS">YACS - Yet Another Color Selector</a>')
        this.gAbout.Add('Text', 'x+5', 'by Komrad Toast.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/TheArkive/FontPicker_ahk2">FontPicker</a>')
        this.gAbout.Add('Text', 'x+5', ' by Maestrith, TheArkive (v2 conversion).')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/TheArkive/ColorPicker_ahk2">ColorPicker</a>')
        this.gAbout.Add('Text', 'x+5', 'by Maestrith, TheArkive (v2 conversion).')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.autohotkey.com/boards/viewtopic.php?t=66000">GetFontNames</a>')
        this.gAbout.Add('Text', 'x+5', 'by teadrinker.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.the-automator.com/downloads/maestrith-notify-class-v2">DisplayCheck</a>')
        this.gAbout.Add('Text', 'x+5', 'by the-Automator.')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://github.com/Descolada/UIA-v2">MoveControls</a>')
        this.gAbout.Add('Text', 'x+5', 'by Descolada. (from UIATreeInspector.ahk)')
        this.gAbout.Add('Link', 'xs yp+30', '<a href="https://www.autohotkey.com/board/topic/66235-retrieving-the-fontname-and-fontsize-of-a-gui-control">Control_GetFont</a>')
        this.gAbout.Add('Text', 'x+5', 'by SKAN, swagfag.')

        gAboutWidth := 550, btnWidth := 120, btnHeight := 35
        btnPosX := gAboutWidth/2 - btnWidth/2
        this.gAbout.btn_close := this.gAbout.Add('Button', 'x' btnPosX ' yp+30 w' btnWidth ' h' btnHeight ' Default', 'Close')
        this.gAbout.btn_close.OnEvent('Click', this.GUI_Close.Bind(this, 'gAbout'))
        this.gAbout.OnEvent('Close', this.GUI_Close.Bind(this, 'gAbout'))
        this.gAbout.MarginY := 15

        try ControlFocus(this.gAbout.btn_close.hwnd, this.gAbout.hwnd)
        this.ShowGUIRelativeToOwner(this.gMainTitle, 'gAbout', 'w550')
    }

    ;============================================================================================

    static GUI_Close(objGui, *)
    {
        try this.gMain.Opt('-Disabled')
        this.%objGui%.Destroy()
    }

    ;============================================================================================

    static ShowGUIRelativeToOwner(title, gName, width:='')
    {
        if (WinExist(this.gMainTitle ' ahk_class AutoHotkeyGUI')) {
            if (Notify.MonitorGetWindowIsIn(title ' ahk_class AutoHotkeyGUI') = 1) {
                this.%gName%.Show(width)
            } else {
                WinGetClientPos(&posMainX, &posMainY,,, title ' ahk_class AutoHotkeyGUI')
                this.%gName%.Show('x' posMainX ' y' posMainY ' ' width)
            }
        } else this.%gName%.Show(width)
    }

	;============================================================================================

    static GuiExist(arrGUIs)
    {
        for guiName in arrGUIs {
            try {
                hwnd := this.%guiName%.hwnd
                return true
            }
        }

        mDhwTmm := Notify.Set_DHWindows_TMMode(0, 'RegEx')

        if this.HasVal('fileDialog', arrGUIs) && WinExist('^Select (Image|Sound) - ' this.scriptName '$ ahk_class #32770')
            guiExist := true

        Notify.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
        return guiExist ?? false
    }

    ;============================================================================================

    static ControlExist(gName, ctrlName)
    {
        try
            return ControlGetHwnd(this.%gName%.%ctrlName%)
        catch
            return false
    }

    ;============================================================================================

    static MenuItemExist(menu, text)
    {
        static MF_BYPOSITION := 0x00000400
        hMenu := menu.Handle
        menuText := Buffer(512)

        Loop DllCall("GetMenuItemCount", "Ptr", hMenu) {
            DllCall("GetMenuString", "Ptr", hMenu, "UInt", A_Index - 1, "Ptr", menuText.Ptr, "Int", 256, "UInt", MF_BYPOSITION)
            if (text = StrGet(menuText))
                return true
        }
        return false
    }

    ;============================================================================================

    static DebounceCall(arrParams*)
    {
        delay := arrParams[1]
        funcName := arrParams[2]
        arrParams.RemoveAt(1)
        arrParams.RemoveAt(1)

        if this.debounceTimers.Has(funcName)
            SetTimer(this.debounceTimers[funcName], 0)

        boundFunc := this.%funcName%.Bind(this, arrParams)
        this.debounceTimers[funcName] := boundFunc
        SetTimer(boundFunc, -delay)
    }

    ;============================================================================================

    static CopyToClipboard(param, strOpts:='', *)
    {
        strClip := ' copied to clipboard.'

        switch param {
            case 'theme': title := 'Theme name' strClip, msg := this.gMain.ddl_theme.Text
            case 'result' : title := 'Result' strClip, msg := this.gMain.edit_result.Text
            case 'tf', 'mf': title := (param == 'tf' ? 'Title' : 'Message') ' font name' strClip, msg := this.gMain.ddl_%param%.Text
            case 'export': title := 'Settings string' strClip, msg := strOpts, dur := 12
            case 'sound', 'image', 'bgImg':
            {
                title := (param == 'bgImg' ? 'Background Image' : StrTitle(param)) strClip

                if (msg := this.gMain.ddl_%param%.Text) = 'none'
                    return
            }
            default: title := 'Content' strClip, msg := param
        }

        A_Clipboard := '', A_Clipboard := msg

        if ClipWait(1)
            Notify.Show(title, msg,,,,
                this.strOpts 'dg=5 tag=copyToClip theme=OKDark dur=' (dur ?? Notify.mOrig_mDefaults['dur']) ' pos=bc mali=center tali=center')
        else
            Notify.Show('Error', 'Copy to clipboard failed.',,,, this.strOpts 'dg=5 tag=copyToClip theme=xDark pos=bc mali=center tali=center')
    }

    ;============================================================================================

    static MsgBox_WarningTooManyFonts()
    {
        this.TrayMenu_Enable_Disable('disable', ['about', 'settings', 'tools', 'open application folder', 'ResIconsPicker', this.scriptName])
        this.gMain.Opt('+OwnDialogs')
        try
            MsgBox('The font limit has been reached. A restart of the application is required.', 'Warning ! Too Many Fonts', 'Icon!'), Reload()
        catch
            Reload()
    }

    /********************************************************************************************
     * @credits Descolada
     * @see {@link https://github.com/Descolada/UIA-v2 GitHub}
     */
    static MoveControls(ctrls*)
    {
        for ctrl in ctrls
            ctrl.Control.Move(ctrl.HasOwnProp('x') ? ctrl.x : unset, ctrl.HasOwnProp('y') ? ctrl.y : unset, ctrl.HasOwnProp('w') ? ctrl.w : unset, ctrl.HasOwnProp('h') ? ctrl.h : unset)
    }

    ;============================================================================================

    static TrayMenu_Enable_Disable(state, arr)
    {
        for value in arr
            A_TrayMenu.%state%(value)
    }

    ;============================================================================================

    static ConvertAnimHextoName(m)
    {
        for value in ['show', 'hide'] {
            for k, v in Notify.mAW {
                if m.Has(value 'Hex') && m[value 'Hex'] = v {
                    m[value 'Name'] := k
                    break
                }
            }
        }
    }

    ;============================================================================================

    static CreateAnimationString(m)
    {
        strShow := m.Has('showName') ? 'show=' m['showName'] (m.Has('showDur') && m['showName'] != 'none' ? '@' m['showDur'] : '') : ''
        strHide := m.Has('hideName') ? 'hide=' m['hideName'] (m.Has('hideDur') && m['hideName'] != 'none' ? '@' m['hideDur'] : '') : ''
        m['strAnim'] := strShow (strShow && strHide ? ' ' : '') strHide
    }

    ;============================================================================================

    static RunTool(filePath, *)
    {
        FileExist(filePath) ? Run(filePath) : Notify.Show('Error', 'The system cannot find the file specified.`n"' filePath '"',,,, this.strOpts 'theme=xDark dg=5 tag=errorMsg')
    }

    ;============================================================================================

    static AHK_NOTIFYICON(wParam, lParam, msg, hwnd)
	{
		if lParam = 0x201 && KeyWait('LButton', 'D T0.25') ; double-click
            SetTimer(this.DebounceCall.Bind(this, 125, 'gMain_Show'), -1, -1)
	}

    ;============================================================================================

    static EscapeCharacters(str)
    {
        str := StrReplace(str, "'", "``" "'")
        str := StrReplace(str, "`n", "``n")
        str := StrReplace(str, "`t", "``t")
        return str
    }

    ;============================================================================================

    static UnescapeCharacters(str)
    {
        str := StrReplace(str, "``'", "`'")
        str := StrReplace(str, "``n", "`n")
        str := StrReplace(str, "``t", "`t")
        return str
    }

    ;============================================================================================

    static MapCI() => (m := Map(), m.CaseSense := false, m)

    ;============================================================================================

    static IsChecked(index) => ( SendMessage( 0x102C, index - 1, 0xF000, this.gTheme.lv ) >> 12 ) - 1

    ;============================================================================================

    static SetIconTip(*) => A_IconTip := this.scriptName ' ' this.scriptVersion '`nDefault theme:  ' Notify.mDefaults['theme']

    ;============================================================================================

    static ControlGetTextWidth(hwnd, txt)
    {
        mon := Notify.MonitorGetWindowIsIn('A')
        MonitorGetWorkArea(mon, &monWALeft, &monWATop, &monWARight, &monWABottom)
        mFI := this.ControlGetFontInfo(hwnd)
        return Notify.GetTextWidth(txt, mFI['fontName'], mFI['fontSize'],, monWALeft, monWATop)
    }

    /********************************************************************************************
     * Retrieves the font name and font size of a GUI control.
     * @credits SKAN, swagfag
     * @see {@link https://www.autohotkey.com/board/topic/66235-retrieving-the-fontname-and-fontsize-of-a-gui-control/ AHK Forum}
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?t=113540 AHK Forum}
     */
    static ControlGetFontInfo(hwnd)
    {
        hFont := SendMessage(0x31, 0, 0, hwnd) ; WM_GETFONT
        LOGFONTW := Buffer(92) ; sizeof LOGFONTW

        if !DllCall("GetObject", 'Ptr', hFont, 'Int', LOGFONTW.Size, 'Ptr', LOGFONTW)
            throw OSError('GetObject LOGFONTW failed')

        hDC := DllCall("GetDC", 'Ptr', hwnd, 'Ptr')
        DPI := DllCall("GetDeviceCaps", 'Ptr', hDC, 'Int', 90) ; LOGPIXELSY
        DllCall("ReleaseDC", 'Ptr', hwnd, 'Ptr', hDC)
        lfHeight := NumGet(LOGFONTW, 0, "Int")
        fontSize := Round((-lfHeight * 72) / DPI)
        fontName := StrGet(LOGFONTW.Ptr + 28, 32, "UTF-16")
        return Map('fontName', fontName, 'fontSize', fontSize)
    }

    /********************************************************************************************
     * Get the names of all fonts currently installed on the system.
     * @credits teadrinker, XMCQCX (v2 conversion).
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?t=66000 AHK Forum}
     */
    static GetFontNames()
    {
        hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
        LOGFONT := Buffer(92, 0)
        NumPut("UChar", 1, LOGFONT, 23) ; DEFAULT_CHARSET := 1

        DllCall("EnumFontFamiliesEx"
            , "Ptr", hDC
            , "Ptr", LOGFONT
            , "Ptr", EnumFontFamExProc := CallbackCreate(EnumFontFamExProcFunc, "F", 4)
            , "Ptr", ObjPtr(oFonts := Map())
            , "UInt", 0)

        CallbackFree(EnumFontFamExProc)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
        return oFonts

        EnumFontFamExProcFunc(lpelfe, lpntme, FontType, lParam) {
            font := StrGet(lpelfe + 28, "UTF-16")
            ObjFromPtrAddRef(lParam)[font] := ""
            return true
        }
    }

    ;============================================================================================

    static Submit_ObjectToMap(obj)
    {
        m := this.MapCI()

        for key, value in obj.OwnProps()
            m[key] := value

        return m
    }

    ;============================================================================================

    static MapToArray(mapObj)
    {
        arr := Array()

        for key, value in mapObj
            arr.Push(key)

        return arr
    }

    ;============================================================================================

    static isMapIdentical(m1, m2)
    {
        if m1.Count != m2.Count
            return false

        for key, value in m1
            if (!m2.Has(key) || m2[key] != value)
                return false

        return true
    }

    ;============================================================================================

    static IsArrayContainsSameValues(a1, a2)
    {
        if a1.Length != a2.Length
            return false

        cntValueMatch := 0

        for value in a1
            if this.HasVal(value, a2)
                cntValueMatch++

        if a1.Length = cntValueMatch
            return true

        return false
    }

    ;=============================================================================================

    static HasVal(needle, haystack, caseSensitive := false)
    {
        for index, value in haystack
            if (caseSensitive && value == needle) || (!caseSensitive && value = needle)
                return index

        return false
    }

    ;============================================================================================

    static CreateIncrementalArray(interval, minimum, maximum)
    {
        arr := Array()

        Loop ((maximum - minimum) // interval) + 1
            arr.Push(minimum + (A_Index - 1) * interval)

        return arr
    }

    ;============================================================================================

    static SortArray(arr)
    {
        if !arr.Length
            return arr

        sortedArray := Array()
        delimiter := Chr(31)

        for value in arr
            listValues .= value delimiter

        sortedListValues := Sort(RTrim(listValues, delimiter), 'D' delimiter)

        for value in StrSplit(sortedListValues, delimiter)
            sortedArray.Push(value)

        for value in ['None', 'Default']
            if index := this.HasVal(value, sortedArray)
                sortedArray.RemoveAt(index), sortedArray.InsertAt(1, value)

        return sortedArray
    }

    ;============================================================================================

    static DDLchoose(choice, arr, objCtrl, caseSensitive := false)
    {
        for index, value in arr {
            if (caseSensitive && value == choice) || (!caseSensitive && value = choice) {
                objCtrl.Choose(index)
                valueFound := true
                break
            }
        }
        return valueFound ?? false
    }

    ;============================================================================================

    static DDLArrayChange_Choose(choice, arr, objCtrl, caseSensitive := false)
    {
        objCtrl.Delete()
        objCtrl.Add(arr)
        this.DDLchoose(choice, arr, objCtrl, caseSensitive)
    }
}
