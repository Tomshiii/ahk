/********************************************************************************************
 * Notify - Simplifies the creation and display of notification GUIs.
 * @author Martin Chartier (XMCQCX)
 * @date 2025/01/02
 * @version 1.8.0
 * @see {@link https://github.com/XMCQCX/NotifyClass-NotifyCreator GitHub}
 * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=129635 AHK Forum}
 * @license MIT license
 * @credits
 * - JSON by thqby, HotKeyIt. {@link https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk GitHub}
 * - FrameShadow by Klark92. {@link https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117&hilit=FrameShadow AHK Forum}
 * - DrawBorder by ericreeves. {@link https://gist.github.com/ericreeves/fd426cc0457a5a47058e1ad1a29d9bd6 GitHub}
 * - CalculatePopupWindowPosition by lexikos. {@link https://www.autohotkey.com/boards/viewtopic.php?t=103459 AHK Forum}
 * - PlayWavConcurrent by Faddix. {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=130425 AHK Forum}
 * - Notify by gwarble. {@link https://www.autohotkey.com/board/topic/44870-notify-multiple-easy-tray-area-notifications-v04991/ AHK Forum}
 * - Notify by the-Automator. {@link https://www.the-automator.com/downloads/maestrith-notify-class-v2/ the-automator.com}
 * - WiseGui by SKAN. {@link https://www.autohotkey.com/boards/viewtopic.php?t=94044 AHK Forum}
 * @features
 * - Customize various parameters such as text, font, color, image, sound, animation, and more.
 * - Choose from built-in themes or create your own custom themes with Notify Creator.
 * - Rounded or edged corners.
 * - Position at different locations on the screen.
 * - Call a function when clicking on it.
 * - GUI stacking and repositioning.
 * - Multi-Monitor support.
 * - Multi-Script support.
 * @methods
 * - Show(title, msg, image, sound, callback, options) - Builds and displays a notification GUI.
 * - Destroy(param) - Destroys GUIs.
 *   - Window handle (hwnd) - Destroys the GUI with the specified window handle.
 *   - tag - Destroys every GUI containing this tag across all scripts.
 *   - 'oldest' or no param - Destroys the oldest GUI.
 *   - 'latest' - Destroys the most recent GUI.
 * - DestroyAllOnMonitorAtPosition(monitorNumber, position) - Destroys all GUIs on a specific monitor at a given position.
 * - DestroyAllOnAllMonitorAtPosition(position) - Destroys all GUIs on all monitors at a specific position.
 * - DestroyAllOnMonitor(monitorNumber) - Destroys all GUIs on a specific monitor.
 * - DestroyAll() - Destroys all GUIs.
 * - Exist(tag) - Checks if a GUI with the specified tag exists and returns the unique ID (HWND) of the first matching GUI.
 * - SetDefaultTheme(theme) - Set a different theme as the default.
 ********************************************************************************************/
Class Notify {

/********************************************************************************************
 * @method Show(title, msg, image, sound, callback, options)
 * @description Builds and displays a notification GUI.
 * @param title Title
 * @param msg Message
 * @param image
 * - File path of an image. Supported file types: `.ico, .dll, .exe, .cpl, .png, .jpeg, .jpg, .gif, .bmp, .tif`
 * - String: `'icon!'`, `'icon?'`, `'iconx'`, `'iconi'`
 * - Icon from dll. For example: `'C:\Windows\System32\imageres.dll|icon19'`
 * - Image Handle. For example: `'HICON:' hwnd`
 * - Filename of an image located in "Pictures\Notify".
 * @param sound
 * - File path of a WAV file.
 * - String: `'soundx'`, `'soundi'`
 * - Filename of a WAV file located in "C:\Windows\Media" or "Music\Sounds". For example: `'Ding'`, `'tada'`, `'Windows Error'` etc.
 * - Use Notify Creator to view and play all available notification sounds.
 * @param callback Function object to call when left-clicking on the GUI.
 * @param options For example: `'POS=TL DUR=6 IW=70 TF=Impact TS=42 TC=GREEN MC=blue BC=Silver STYLE=edge SHOW=Fade Hide=Fade@250'`
 * - The string is case-insensitive.
 * - The asterisk (*) indicates the default option.
 * - `THEME` - Built-in themes and user-created themes.
 *   - Use Notify Creator to view all themes and their visual appearance.
 * - `POS` - Position
 *   - `BR` - Bottom right*
 *   - `BC` - Bottom center
 *   - `BL` - Bottom left
 *   - `TL` - Top left
 *   - `TC` - Top center
 *   - `TR` - Top right
 *   - `CT` - Center
 *   - `CTL` - Center left
 *   - `CTR` - Center right
 *   - `Mouse` - Near the cursor.
 * - `DUR` - Display duration (in seconds). Set to 0 to keep it on the screen until left-clicking on the GUI or programmatically destroying it. `*8`
 * - `MON` - Monitor number to display the GUI. AutoHotkey monitor numbers differ from those in Windows Display settings or NVIDIA Control Panel.
 *   - `Primary`* - The primary monitor.
 *   - `Active` - The monitor on which the active window is displayed.
 *   - `Mouse` - The monitor on which the mouse is currently positioned.
 * - `IW` - Image width - `*32` If only one dimension is specified, the other dimension will automatically adjust to preserve the aspect ratio.
 * - `IH` - Image height `*-1`
 *   - `iw=0` or `ih=0` - Uses the actual dimensions of the image.
 * - `TF` - Title font `*Segoe UI`
 * - `TFO` - Title font options. `*Bold` For example: `tfo=underline italic strike`
 * - `TS` - Title size `*15`
 * - `TC` - Title color `*White`
 * - `TALI` - Title alignment
 *   - `Left`*
 *   - `Right`
 *   - `Center`
 * - `MF` - Message font `*Segoe UI`
 * - `MFO` - Message font options. For example: `mfo=underline italic strike`
 * - `MS` - Message size `*12`
 * - `MC` - Message color `*0xEAEAEA`
 * - `MALI` - Message alignment
 *   - `Left`*
 *   - `Right`
 *   - `Center`
 * - `PROG` - Progress bar. For example: `prog=1`, `prog=h40 cGreen`, `prog=w400`, {@link https://www.autohotkey.com/docs/v2/lib/GuiControls.htm#Progress Progress Options}
 * - `BC` - Background color `*0x1F1F1F`
 * - `STYLE` - Notification Appearance
 *   - `Round` - Rounded corners*
 *   - `Edge` - Edged corners
 * - `BDR` - Border. For example: `bdr=Aqua`,`bdr=Red,4`
 *   - The round style's maximum border width is limited to 1 pixel, while the edge style allows up to 5 pixels.
 *   - If the theme includes a border and the style is set to edge, you can specify only the border width like this: `bdr=,3`
 *   - `0` - No border
 *   - `1` - Border
 *   - `Default`
 *   - `Color`
 *   - `Color,border width` - Specify color and width, separated by a comma.
 * - `PAD` - Comma-separated values. Can range from 0 to 25. For example: `pad=0,0,15,15,5,10`, `pad=,10`
 *   - If values aren’t specified, the default padding settings for the style will be set.
 *   - PadX - Padding between the left or right edge of the GUI and the screen's edge.
 *   - PadY - Padding between the top or bottom edge of the GUI and the screen's edge.
 *   - GMX - Left/right margins of the GUI.
 *   - GMY - Top/bottom margins of the GUI.
 *   - SpX - Horizontal spacing between the right side of the image and other controls.
 *   - SpY - Vertical spacing between the title, message, and progress bar.
 * - `WIDTH` - Fixed width of the GUI (excluding the image width and margins).
 * - `MAXW` - Maximum width of the GUI (excluding image width and margins).
 * - `WSTC` - WinSetTransColor. Not compatible with the round style, fade animation. For example: `style=edge bdr=0 bc=black WSTC=black` {@link https://www.autohotkey.com/docs/v2/lib/WinSetTransColor.htm WinSetTransColor}
 * - `WSTP` - WinSetTransparent. Not compatible with the round style, fade animation. For example: `style=edge wstp=120` {@link https://www.autohotkey.com/docs/v2/lib/WinSetTransparent.htm WinSetTransparent}
 * - `SHOW` and `HIDE` - Animation when showing and destroying the GUI. The duration, which is optional, can range from 1 to 2500 milliseconds. For example: `STYLE=EDGE SHOW=SlideNorth HIDE=SlideSouth@250`
 *   - The round style is not compatible with most animations. It renders only the fade-in (Show=fade) animation correctly. If the round style and fade-out (Hide=fade) are used, the corners become edged during the animation.
 *   - If animations aren’t specified, the default animations for the style and position will be set.
 *   - `None`
 *   - `Fade`
 *   - `Expand`
 *   - `SlideEast`
 *   - `SlideWest`
 *   - `SlideNorth`
 *   - `SlideSouth`
 *   - `SlideNorthEast`
 *   - `SlideNorthWest`
 *   - `SlideSouthEast`
 *   - `SlideSouthWest`
 *   - `RollEast`
 *   - `RollWest`
 *   - `RollNorth`
 *   - `RollSouth`
 *   - `RollNorthEast`
 *   - `RollNorthWest`
 *   - `RollSouthEast`
 *   - `RollSouthWest`
 * - `TAG` - Marker to identify a GUI. The Destroy method accepts a handle or a tag, it destroys every GUI containing this tag across all scripts.
 * - `DGC` - Destroy GUI click. Allow or prevent the GUI from being destroyed when clicked.
 *   - `0` - Clicking on the GUI does not destroy it.
 *   - `1` - Clicking on the GUI destroys it.*
 * - `DG` - Destroy GUIs before creating the new GUI.
 *   - `0` - Do not destroy GUIs.*
 *   - `1` - Destroy all GUIs on the monitor option at the position option.
 *   - `2` - Destroy all GUIs on all monitors at the position option.
 *   - `3` - Destroy all GUIs on the monitor option.
 *   - `4` - Destroy all GUIs.
 *   - `5` - Destroy all GUIs containing the tag. For example: `dg=5 tag=myTAG`
 * - `OPT` - Sets various options and styles for the appearance and behavior of the window. `*+Owner -Caption +AlwaysOnTop` {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Opt GUI Opt}
 * @returns Map object
********************************************************************************************/
    static Show(title:='', msg:='', image:='', sound:='', callback:='', options:='') => this._Show(title, msg, image, sound, callback, options)

    static __New()
    {
        this.mNotifyGUIs := this.MapCI()
        this.mThemesStrings := this.MapCI().Set(
            'Light', 'tc=Black mc=Black bc=White',
            'Dark', 'tc=White mc=0xEAEAEA bc=0x1F1F1F',
            'Matrix', 'tc=Lime mc=0x00FF7F bc=Black bdr=0x00FF7F tf=Consolas mf=Lucida Console',
            'Cyberpunk', 'tc=0xFF005F mc=Aqua bc=0x0D0D0D bdr=Aqua tf=Consolas mf=Lucida Console',
            'Cybernetic', 'tc=Aqua mc=0xFF005F bc=0x1A1A1A bdr=0xFF005F tf=Lucida Console mf=Consolas',
            'Synthwave', 'tc=Fuchsia mc=Aqua bc=0x1A0E2F bdr=Aqua tf=Consolas mf=Arial',
            'Dracula', 'tc=0xFF79C6 mc=0x8BE9FD bc=0x282A36 bdr=0x8BE9FD tf=Consolas mf=Arial',
            'Monokai', 'tc=0xF8F8F2 mc=0xA6E22E bc=0x272822 bdr=0xE8F7C8 tf=Lucida Console mf=Tahoma',
            'Solarized Dark', 'tc=0xB58900 mc=0x839496 bc=0x002B36 bdr=0x839496 tf=Consolas mf=Calibri',
            'Atomic', 'tc=0xE49013 mc=0xDFCA9B bc=0x1F1F1F bdr=0xDFCA9B tf=Consolas mf=Lucida Console',
            'PCB', 'tc=0xCCAA00 mc=0x00CC00 bc=0x002200 bdr=0x00CC00 tf=Consolas mf=Arial',
            'Deep Sea', 'tc=0x00CED1 mc=0x5F9EA0 bc=0x002B36 bdr=0x4682B4 tf=Arial mf=Verdana',
            'Firewatch', 'tc=0xFF4500 mc=0xFF8C00 bc=0x2C1B18 bdr=0xFFA500 tf=Verdana mf=Georgia',
            'Nord', 'tc=0xD8DEE9 mc=0xECEFF4 bc=0x2E3440 bdr=0x88C0D0 tf=Calibri mf=Lucida Console',
            'Ivory', 'tc=0x333333 mc=0x666666 bc=0xFFFFF0 bdr=0xCCCCCC tf=Georgia mf=Tahoma',
            'Neon', 'tc=Yellow mc=Fuchsia bc=Black bdr=Fuchsia tf=Consolas mf=Lucida Console',
            'Frost', 'tc=Aqua mc=0xE0FFFF bc=0x002233 bdr=Aqua tf=Calibri mf=Arial',
            'Charcoal', 'tc=0xD3D3D3 mc=0xA9A9A9 bc=0x2F2F2F bdr=0xA9A9A9 tf=Tahoma mf=Consolas',
            'Zenburn', 'tc=0xDECEA3 mc=0xD3D3C4 bc=0x3F3F3F bdr=0x839496 tf=Consolas mf=Calibri',
            'Matcha', 'tc=0xD5D1B5 mc=0x87A9A2 bc=0x273136 bdr=0xD5D1B5',
            'Monaspace', 'tc=0x79C1FD mc=0xD1A7FE bc=0x0D1116 bdr=0xD1A7FE',
            'Milky Way', 'tc=0x9370DB mc=0xC0CAD7 bc=0x0D1B2A bdr=0x9370DB tf=Trebuchet MS mf=Calibri',
            'Reptilian', 'tc=Yellow mc=0xF0FFF0 bc=0x004D00 bdr=Yellow',
            'Aurora', 'tc=0x47F0AC mc=0xEAEAEA bc=0x0C1631 bdr=0x47F0AC',
            'Venom', 'tc=0xF9EA2C mc=0xFAF2A4 bc=0x317140 tf=Segoe UI mf=Segoe UI bdr=0x86EE99',
            'Forum', 'tc=0x3F5770 mc=0x272727 bc=0xDFDFDF bdr=0x686868',
            'Cappuccino', 'tc=0x6F4E37 mc=0x886434 bc=0xFFF8DC bdr=0x886434 tf=Trebuchet MS mf=Times New Roman',
            'Earthy', 'tc=0xF5FFFA mc=0x4DCA22 bc=0x3E2723 bdr=0x41A91D tf=Lucida Console mf=Arial',
            'Rust', 'tc=0xFFC107 mc=0xF5DEB3 bc=0x8F3209 bdr=0xF5DEB3 tf=Georgia mf=Arial',
            'Galactic', 'tc=0xFFD700 mc=White bc=Black bdr=White tf=Verdana mf=Arial',
            'Steampunk', 'tc=0xFFD700 mc=0xB87333 bc=0x3E2723 bdr=0xFFD700 tf=Trebuchet MS mf=Times New Roman',
            'Pastel', 'tc=0xFF69B4 mc=0x0072E3 bc=0xFFF0F5 bdr=0x0072E3 tf=Calibri',
            'Nature', 'tc=0x2E8B57 mc=0x4A5E4A bc=0xE8F3E8 bdr=0x4A5E4A tf=Trebuchet MS',
            'Pink Light', 'tc=0xFF1493 mc=0xFF69B4 bc=0xFFE4E1 bdr=0xFF69B4 tf=Comic Sans MS mf=Verdana',
            'Pink Dark', 'tc=0xFF1493 mc=0xFF69B4 bc=0x1F1F1F bdr=0xFF69B4 tf=Comic Sans MS mf=Verdana',
            'Sticky', 'tc=Black mc=0x333333 bc=0xF9E15B bdr=0x5F5103 tf=Arial mf=Verdana',
            'OK', 'tc=Black mc=Black bc=0x49C149 bdr=0x336F50',
            'OKLight', 'tc=0x52CB43 mc=Black bc=0xF1F8F4 bdr=0x52CB43',
            'OKDark', 'tc=0x52CB43 mc=0xEAEAEA bc=0x1F1F1F bdr=0x52CB43 ',
            'x', 'tc=White mc=0xEAEAEA bc=0xC61111 bdr=0xEAEAEA image=iconx',
            'i', 'tc=White mc=0xEAEAEA bc=0x4682B4 bdr=0xEAEAEA image=iconi',
            '!', 'tc=Black mc=Black bc=0xFFD953 bdr=0x6F5600 image=icon!',
            '?', 'tc=White mc=0xEAEAEA bc=0x4682B4 bdr=0xEAEAEA image=icon?',
            'xLight', 'tc=0xC61111 mc=Black bc=0xFBEFEB bdr=0xC61111 image=iconx',
            '!Light', 'tc=0xE1AA04 mc=Black bc=0xFEF8EB bdr=0xE1AA04 image=icon!',
            'iLight', 'tc=0x2543AC mc=Black bc=0xE7EFFA bdr=0x2543AC image=iconi',
            '?Light', 'tc=0x2543AC mc=Black bc=0xE7EFFA bdr=0x2543AC image=icon?',
            'xDark', 'tc=0xC61111 mc=0xEAEAEA bc=0x1F1F1F bdr=0xC61111 image=iconx',
            '!Dark', 'tc=0xDEA309 mc=0xEAEAEA bc=0x1F1F1F bdr=0xDEA309 image=icon!',
            'iDark', 'tc=0x41A5EE mc=0xEAEAEA bc=0x1F1F1F bdr=0x41A5EE image=iconi',
            '?Dark', 'tc=0x41A5EE mc=0xEAEAEA bc=0x1F1F1F bdr=0x41A5EE image=icon?',
        )

        this.mDefaults := this.MapCI().Set(
            'theme', 'Default',
            'style', 'Round',
            'mon', 'Primary',      ; Monitor
            'pos', 'BR',           ; Position
            'dur', 8,              ; Duration
            'iw', 32,              ; Image width
            'ih', -1,              ; Image height
            'tf', 'Segoe UI',      ; Title font
            'tfo', 'norm Bold',    ; Title font options
            'ts', 15,              ; Title size
            'tc', 'White',       ; Title color
            'tali', 'Left',        ; Title alignment
            'mf', 'Segoe UI',      ; Message font
            'mfo', 'norm',         ; Message font options
            'ms', 12,              ; Message size
            'mc', '0xEAEAEA',    ; Message color
            'mali', 'Left',        ; Message alignment
            'bc', '0x1F1F1F',    ; Background color
            'dg', 0,               ; Destroy GUIs
            'dgc', 1,              ; Destroy GUI click
            'bdr', 'Default',      ; Border
            'prog', '',            ; Progress bar
            'wstc', '',            ; WinSetTransColor
            'wstp', '',            ; WinSetTransparent
            'width', '',           ; Fixed width
            'maxW', '',            ; Maximum width
            'tag', '',             ; GUI window title identifying marker
            'opt', '+Owner -Caption +AlwaysOnTop',
            'image', 'None',
            'sound', 'None',
            'pad', ',,16,16,8,10'
        )

        this.padG := 10 ; Pad between GUIs
        this.bdrWdefaultEdge := 2
        this.arrBdrWrange := [1,5]
        this.arrPadRange := [0,25]
        this.ParsePadOption(this.mDefaults)
        this.arrFonts := Array()
        this.isTooManyFonts := false

        this.mAHKcolors := this.MapCI().Set(
            'Black',  '0x000000', 'Silver', '0xC0C0C0',
            'Gray',   '0x808080', 'White',  '0xFFFFFF',
            'Maroon', '0x800000', 'Red',    '0xFF0000',
            'Purple', '0x800080', 'Fuchsia','0xFF00FF',
            'Green',  '0x008000', 'Lime',   '0x00FF00',
            'Olive',  '0x808000', 'Yellow', '0xFFFF00',
            'Navy',   '0x000080', 'Blue',   '0x0000FF',
            'Teal',   '0x008080', 'Aqua',   '0x00FFFF'
        )

        this.mAW := this.MapCI().Set(
            'none', '',
            'fade', '0x80000',           ; AW_BLEND
            'expand', '0x00010',         ; AW_CENTER
            'slideEast', '0x40001',      ; AW_SLIDE | AW_HOR_POSITIVE
            'slideWest', '0x40002',      ; AW_SLIDE | AW_HOR_NEGATIVE
            'slideNorth', '0x40008',     ; AW_SLIDE | AW_VER_NEGATIVE
            'slideSouth', '0x40004',     ; AW_SLIDE | AW_VER_POSITIVE
            'slideNorthEast', '0x40009', ; AW_SLIDE | AW_VER_NEGATIVE | AW_HOR_POSITIVE
            'slideNorthWest', '0x4000A', ; AW_SLIDE | AW_VER_NEGATIVE | AW_HOR_NEGATIVE
            'slideSouthEast', '0x40005', ; AW_SLIDE | AW_VER_POSITIVE | AW_HOR_POSITIVE
            'slideSouthWest', '0x40006', ; AW_SLIDE | AW_VER_POSITIVE | AW_HOR_NEGATIVE
            'rollEast', '0x00001',       ; AW_HOR_POSITIVE
            'rollWest', '0x00002',       ; AW_HOR_NEGATIVE
            'rollNorth', '0x00008',      ; AW_VER_NEGATIVE
            'rollSouth', '0x00004',      ; AW_VER_POSITIVE
            'rollNorthEast', '0x00009',  ; ROLL_DIAG_BL_TO_TR
            'rollNorthWest', '0x0000a',  ; ROLL_DIAG_BR_TO_TL
            'rollSouthEast', '0x00005',  ; ROLL_DIAG_TL_TO_BR
            'rollSouthWest', '0x00006'   ; ROLL_DIAG_TR_TO_BL
        )

        this.pathImagesFolder := RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'My Pictures') '\Notify'
        this.arrImageExt := ['ico', 'dll', 'exe', 'cpl', 'png', 'jpeg', 'jpg', 'gif', 'bmp', 'tif']
        this.strImageExt := this.ArrayToString(this.arrImageExt, '|')
        this.mImages := this.MapCI().Set('icon!', 2, 'icon?', 3, 'iconx', 4, 'iconi', 5)

        Loop Files this.pathImagesFolder '\*.*'
            if RegExMatch(A_LoopFileExt, 'i)^(' this.strImageExt ')$')
                SplitPath(A_LoopFilePath,,,, &fileName), this.mImages[fileName] := A_LoopFilePath

        ;==============================================

        this.pathSoundsFolder := RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'My Music') '\Sounds'
        this.mSounds := this.MapCI().Set('soundx', '*16', 'soundi', '*64')

        for path in [A_WinDir '\Media', this.pathSoundsFolder]
            Loop Files path '\*.wav'
                SplitPath(A_LoopFilePath,,,, &fileName), this.mSounds[fileName] := A_LoopFilePath

        ;==============================================

        this.mThemes := this.MapCI()

        for theme, str in this.mThemesStrings
            this.OptionsStringToMap(this.mThemes[theme] := this.MapCI(), str)

        ;==============================================

        this.mOrig_mDefaults := this.MapCI()

        for key, value in this.mDefaults
            this.mOrig_mDefaults[key] := value

        ;==============================================

        this.mOrig_mThemes := this.MapCI()

        for theme, mTheme in this.mThemes {
            this.mOrig_mThemes[theme] := this.MapCI()

            for key, value in mTheme
                this.mOrig_mThemes[theme][key] := value
        }

        ;==============================================

        sourceFile := A_IsCompiled ? A_ScriptFullPath : A_LineFile
        SplitPath(sourceFile,, &pathDir)

        if (FileExist(pathDir '\Preferences.json')) {
            objFile := FileOpen(pathDir '\Preferences.json', 'r', 'UTF-8')
            mJSON := _JSON_thqby.parse(objFile.Read(), keepbooltype := false, as_map := true)
            objFile.Close()

            if (mJSON.Has('mDefaults')) {
                this.mThemes['Default'] := this.MapCI()

                for key, value in mJSON['mDefaults']
                    this.mThemes['Default'][key] := value

                for key, value in this.mDefaults
                    if this.mThemes['Default'].Has(key)
                        this.mDefaults[key] := this.mThemes['Default'][key]

                for key in ['padX', 'padY', 'gmX', 'gmY', 'spX', 'spY']
                    if this.mDefaults.Has(key)
                        this.mDefaults.Delete(key)

                this.ParsePadOption(this.mDefaults)
            }

            if (mJSON.Has('mThemes')) {
                for key, value in mJSON['mThemes'] {
                    this.mThemes[key] := this.MapCI()

                    for k, v in value
                        this.mThemes[key][k] := v
                }
            }
        }

        ;==============================================

        this.mThemes['Default'] := this.MapCI()

        if !this.mThemes.Has(this.mDefaults['theme'])
            this.mDefaults['theme'] := 'Default'

        ;==============================================

        for value in ['mThemes', 'mOrig_mThemes'] {
            for theme, mTheme in this.%value% {
                if (theme != 'default') {
                    arrKeyDefined := Array()

                    for key, v in mTheme
                        arrKeyDefined.Push(key)

                    mTheme['arrKeyDefined'] := arrKeyDefined
                }
            }
        }

        ;==============================================

        for theme, mTheme in this.mThemes {
            this.ParseBorderOption(mTheme)

            for value in ['show', 'hide']
                if mtheme.Has(value)
                    mtheme.Delete(value)
        }
    }

    ;============================================================================================

    static _Show(title:='', msg:='', image:='', sound:='', callback:='', options:='')
    {
        static gIndex := 0
        this.OptionsStringToMap(m := this.MapCI(), options)

        if !m.Has('theme') || !this.mThemes.Has(m['theme'])
            m['theme'] := this.mDefaults['theme']

        this.SetThemeSettings(m, this.mThemes[m['theme']])
        this.SetDefault_MiscValues(m)
        this.ParseAnimationOption(m)
        this.SetAnimationDefault(m)
        this.ParsePadOption(m)
        this.SetPadDefault(m)
        this.ParseBorderOption(m)
        this.SetBorderOption(m)

        if image
            m['image'] := image

        if sound
            m['sound'] := sound

        if (!title && !msg && (m['image'] = '' || m['image'] = 'none'))
            return

        ;==============================================

        switch {
            case (m['mon'] = 'mouse' || m['pos'] = 'mouse'): m['mon'] := this.MonitorGetMouseIsIn()
            case m['mon'] = 'active': m['mon'] := this.MonitorGetWindowIsIn('A')
            case (m['mon'] = 'primary' || m['mon'] < 1 || m['mon'] > MonitorGetCount()) : m['mon'] := MonitorGetPrimary()
        }

        switch m['dg'] {
            case 1: this.DestroyAllOnMonitorAtPosition(m['mon'], m['pos'])
            case 2: this.DestroyAllOnAllMonitorAtPosition(m['pos'])
            case 3: this.DestroyAllOnMonitor(m['mon'])
            case 4: this.DestroyAll()
            case 5: m['tag'] && this.Destroy(m['tag'])
        }

        ;==============================================

        g := Gui(m['opt'], 'NotifyGUI_' m['mon'] '_' m['pos'] '_' m['style'] '_' m['bdrC'] '_' m['bdrW'] '_'  m['padY'] '_' A_Now A_MSec (m['tag'] && '_' m['tag']))
        g.BackColor := m['bc']
        g.MarginX := m['gmX'] + m['bdrW']
        g.MarginY := m['gmY'] + m['bdrW']
        g.gIndex := ++gIndex
        m['hwnd'] := g.handle := g.hwnd

        for value in ['pos', 'mon', 'hideHex', 'hideDur', 'tag']
            g.%value% := m[value]

        ;==============================================

        switch {
            case RegExMatch(m['image'], 'i)^(icon!|icon\?|iconx|iconi)$'):
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'] ' Icon' this.mImages[m['image']], A_WinDir '\system32\user32.dll')

            case this.mImages.Has(m['image']) && FileExist(this.mImages[m['image']]):
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'], this.mImages[m['image']])

            case RegExMatch(m['image'], 'i)^(.+?\.(?:dll|exe|cpl))\|icon(\d+)$', &matchIcon) && FileExist(matchIcon[1]):
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'] ' Icon' matchIcon[2], matchIcon[1])

            case FileExist(m['image']) || RegExMatch(m['image'], 'i)^h(icon|bitmap).*\d+'):
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'], m['image'])
        }

        ;==============================================

        MonitorGetWorkArea(m['mon'], &monWALeft, &monWATop, &monWARight, &monWABottom)
        monWAwidth := Abs(monWARight - monWALeft)
        monWAheight := Abs(monWABottom - monWATop)
        visibleScreenWidth := monWAwidth / (A_ScreenDPI / 96)

        if m.Has('pic')
            picWidth := this.GetPicWidth(m['pic'], monWALeft, monWATop) + m['spX'] + g.MarginX*2

        if title
            titleCtrlW := this.GetTextWidth(title, m['tf'], m['ts'], m['tfo'], monWALeft, monWATop)

        if msg
            msgCtrlW := this.GetTextWidth(msg, m['mf'], m['ms'], m['mfo'], monWALeft, monWATop)

        if title && (titleCtrlW + (picWidth ?? g.MarginX*2)) > visibleScreenWidth
            titleWidth := visibleScreenWidth - m['padX']*2 - (picWidth ?? g.MarginX*2)

        if msg && (msgCtrlW + (picWidth ?? g.MarginX*2)) > visibleScreenWidth
            msgWidth := visibleScreenWidth - m['padX']*2 - (picWidth ?? g.MarginX*2)

        if m['prog'] && RegExMatch(m['prog'], 'i)\bw(\d+)\b', &match_width)
            progUserW := match_width[1]

        if (m['prog'] && IsSet(progUserW)) && ((progUserW + (picWidth ?? g.MarginX*2)) > (visibleScreenWidth))
            progWidth := visibleScreenWidth - m['padX']*2 - (picWidth ?? g.MarginX*2)

        bodyWidth := Max(
            (title ? (titleWidth ?? titleCtrlW ?? 0) : 0),
            (msg ? (msgWidth ?? msgCtrlW ?? 0) : 0),
            (m['prog'] ? (progWidth ?? progUserW ?? 0) : 0)
        )

        switch {
            case m['width']: bodyWidth := m['width']
            case (m['maxW'] && m['maxW'] < bodyWidth): bodyWidth := m['maxW']
        }

        ;==============================================

        if (title) {
            this.SetFont(g, 's' m['ts'] ' c' m['tc'] ' ' m['tfo'], m['tf'])
            m['title'] := g.Add('Text', m['tali'] (IsSet(picWidth) ? ' x+' m['spX'] : '') ' w' bodyWidth, title)
        }

        if (m['prog']) {
            switch {
                case !IsSet(progUserW): m['prog'] := m['prog'] ' w' bodyWidth
                case IsSet(progUserW): m['prog'] := progUserW > bodyWidth ? RegExReplace(m['prog'], 'w\d+', 'w' bodyWidth) : m['prog']
            }

            g.MarginY := title ? m['spY'] : m['gmY'] + m['bdrW']
            m['prog'] := g.Add('Progress', (!title && IsSet(picWidth) ? ' x+' m['spX'] : '') ' ' m['prog'])
        }

        if (msg) {
            g.MarginY := title || m['prog'] ? m['spY'] : m['gmY'] + m['bdrW']
            this.SetFont(g, 's' m['ms'] ' c' m['mc'] ' ' m['mfo'], m['mf'])
            m['msg'] := g.Add('Text', m['mali'] ((!title && !m['prog']) && IsSet(picWidth) ? ' x+' m['spX'] : '') ' w' bodyWidth, msg)
        }

        g.MarginY := m['gmY'] + m['bdrW']
        g.Show('Hide')
        WinGetPos(,, &gW, &gH, g)
        clickArea := g.Add('Text', 'x0 y0 w' gW ' h' gH ' BackgroundTrans')

        if callback
            clickArea.OnEvent('Click', callback)

        if m['dgc']
            clickArea.OnEvent('Click', this.gDestroy.Bind(this, g, 'clickArea'))

        g.OnEvent('Close', this.gDestroy.Bind(this, g, 'close'))
        g.boundFuncTimer := this.gDestroy.Bind(this, g, 'timer')

        if m['sound']
            this.Sound(m['sound'])

        ;==============================================

        switch m['pos'], false {
            case 'br', 'bc', 'bl': minMaxPosY := monWABottom
            case 'tr', 'tc', 'tl', 'ct', 'ctl', 'ctr': minMaxPosY := monWATop
        }

        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_' m['mon'] '_' m['pos'] '_ ahk_class AutoHotkeyGUI') {
            try {
                WinGetPos(, &guiY,, &guiH, 'ahk_id ' id)
                switch m['pos'], false {
                    case 'br', 'bc', 'bl': minMaxPosY := Min(minMaxPosY, guiY)
                    case 'tr', 'tc', 'tl', 'ct', 'ctl', 'ctr': minMaxPosY := Max(minMaxPosY, guiY + guiH)
                }
            } catch
                break
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])

        switch m['pos'], false {
            case 'br':  gPos := 'x' monWARight - gW - m['padX']      ' y' ((minMaxPosY = monWABottom) ? monWABottom - gH - m['padY'] : minMaxPosY - gH - this.padG)
            case 'bc':  gPos := 'x' monWARight - monWAwidth/2 - gW/2 ' y' ((minMaxPosY = monWABottom) ? monWABottom - gH - m['padY'] : minMaxPosY - gH - this.padG)
            case 'bl':  gPos := 'x' monWALeft + m['padX']            ' y' ((minMaxPosY = monWABottom) ? monWABottom - gH - m['padY'] : minMaxPosY - gH - this.padG)
            case 'tl':  gPos := 'x' monWALeft + m['padX']            ' y' ((minMaxPosY = monWATop) ? monWATop + m['padY'] : minMaxPosY + this.padG)
            case 'tc':  gPos := 'x' monWARight - monWAwidth/2 - gW/2 ' y' ((minMaxPosY = monWATop) ? monWATop + m['padY'] : minMaxPosY + this.padG)
            case 'tr':  gPos := 'x' monWARight - m['padX'] - gW      ' y' ((minMaxPosY = monWATop) ? monWATop + m['padY'] : minMaxPosY + this.padG)
            case 'ct':  gPos := 'x' monWARight - monWAwidth/2 - gW/2 ' y' ((minMaxPosY = monWATop) ? monWATop + monWAheight/2 - gH/2 : minMaxPosY + this.padG)
            case 'ctl': gPos := 'x' monWALeft + m['padX']            ' y' ((minMaxPosY = monWATop) ? monWATop + monWAheight/2 - gH/2 : minMaxPosY + this.padG)
            case 'ctr': gPos := 'x' monWARight - m['padX'] - gW      ' y' ((minMaxPosY = monWATop) ? monWATop + monWAheight/2 - gH/2 : minMaxPosY + this.padG)
            case 'mouse': gPos := this.CalculatePopupWindowPosition(g.hwnd)
        }

        switch g.pos, false {
            case 'br', 'bc', 'bl': outOfWorkArea := (minMaxPosY < (monWATop + gH + this.padG))
            case 'tr', 'tc', 'tl', 'ct', 'ctl', 'ctr': outOfWorkArea := (minMaxPosY > (monWABottom - gH - this.padG))
            case 'mouse': outOfWorkArea := false
        }

        ;==============================================

        this.mNotifyGUIs[gIndex] := g

        switch m['style'], false {
            case 'round': this.FrameShadow(g.hwnd), !RegExMatch(m['bdrC'], 'i)^(default|1|0)$') && this.DrawBorderRound(g.hwnd, m['bdrC'])
            case 'edge': RegExMatch(m['bdrC'], 'i)^(default|1)$') && g.Opt('+Border')
        }

        if m['wstp'] || m['wstp'] = 0
            WinSetTransparent(m['wstp'], g)

        if m['wstc']
            WinSetTransColor(m['wstc'], g)

        if m['showHex']
            g.Show(gPos ' NoActivate Hide'), DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', m['showDur'], 'Int', m['showHex'])
        else
            g.Show(gPos ' NoActivate')

        if m['style'] = 'edge' && !RegExMatch(m['bdrC'], 'i)^(default|1|0)$')
            try this.DrawBorderEdge(g.Hwnd, m['bdrC'], m['bdrW'])

        if m['dur']
            SetTimer(g.boundFuncTimer, - ((m['dur'] + (outOfWorkArea ? 8 : 0)) * 1000))

        return m
    }

    ;============================================================================================

    static gDestroy(g, fromMethod:='', *)
    {
        SetTimer(g.boundFuncTimer, 0)

        if g.hideHex && !RegExMatch(fromMethod, 'i)^(destroy|close)')
            try DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', g.hideDur, 'Int', Format("{:#X}", g.hideHex + 0x10000))

        g.Destroy()

        if this.mNotifyGUIs.Has(g.gIndex)
            this.mNotifyGUIs.Delete(g.gIndex)

        ;==============================================
        Sleep(25)
        arrGUIs := Array()
        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_' g.mon '_' g.pos '_ ahk_class AutoHotkeyGUI') {
            try {
                WinGetPos(, &gY,, &gH, 'ahk_id ' id)
                RegExMatch(WinGetTitle('ahk_id ' id), 'i)^NotifyGUI_\d+_([a-z]+)_([a-z]+)_(\w+)_(\d+)_(\d+)_\d+', &match)

                if match[1] = 'mouse'
                    continue

                arrGUIs.Push(this.MapCI().Set('gY', gY, 'gH', gH, 'id', id, 'style', match[2], 'bdrC', match[3], 'bdrW', match[4], 'padY', match[5]))
            } catch {
                arrGUIs := Array()
                break
            }
        }

        if (arrGUIs.Length) {
            try MonitorGetWorkArea(g.mon,, &monWATop,, &monWABottom)
            catch {
                this.RedrawAllBorderEdge()
                this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
                return
            }

            monWAheight := Abs(monWABottom - monWATop)
            SetWinDelay(0)

            switch g.pos, false {
                case 'br', 'bc', 'bl': arrGUIs := this.SortArrayGUIPosY(arrGUIs, true),  posY := monWABottom - arrGUIs[1]['padY']
                case 'tr', 'tc', 'tl', 'ct', 'ctl', 'ctr': arrGUIs := this.SortArrayGUIPosY(arrGUIs),  posY := monWATop + arrGUIs[1]['padY']
            }

            for value in arrGUIs {
                switch g.pos, false {
                    case 'br', 'bc', 'bl': posY -= value['gH']
                    case 'ct', 'ctl', 'ctr': (A_Index = 1 && posY := monWATop + monWAheight/2 - value['gH']/2)
                }

                if (Abs(posY - value['gY']) > 10) {
                    try {
                        WinMove(, posY,,, 'ahk_id ' value['id'])
                        this.ReDrawBorderEdge(value['id'], value['style'], value['bdrC'], value['bdrW'])
                    }
                    catch
                        break
                }

                switch g.pos, false {
                    case 'br', 'bc', 'bl': posY -= this.padG
                    case 'tr', 'tc', 'tl', 'ct', 'ctl', 'ctr': posY += value['gH'] + this.padG
                }
            }
        }

        this.RedrawAllBorderEdge()
        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
    }

    /********************************************************************************************
     * Destroys GUIs.
     * @param {integer|string} param
     * - Window handle (hwnd) - Destroys the GUI with the specified window handle.
     * - Tag - destroys every GUI containing this tag across all scripts.
     * - 'oldest' or no param - Destroys the oldest GUI.
     * - 'latest' - Destroys the most recent GUI.
     */
    static Destroy(param:='')
    {
        mDhwTmm := this.Set_DHWindows_TMMode(0, A_TitleMatchMode)
        SetWinDelay(25)

        if (WinExist('ahk_id ' param)) {
            for gIndex, value in this.mNotifyGUIs.Clone() {
                if (param = value.handle && this.mNotifyGUIs.Has(gIndex)) {
                    this.gDestroy(this.mNotifyGUIs[gIndex], 'destroy')
                    break
                }
            }

            SetTitleMatchMode(1)
            for id in WinGetList('NotifyGUI_ ahk_class AutoHotkeyGUI') {
                if (param = id) {
                    try WinClose('ahk_id ' id)
                    break
                }
            }
        }

        ;==============================================

        if (param) {
            for gIndex, value in this.mNotifyGUIs.Clone()
                if param = value.tag && this.mNotifyGUIs.Has(gIndex)
                    this.gDestroy(this.mNotifyGUIs[gIndex], 'destroy')

            SetTitleMatchMode('RegEx')
            for id in WinGetList('i)^NotifyGUI_\d+_[a-z]+_[a-z]+_\w+_\d+_\d+_\d+_\Q' param '\E$ ahk_class AutoHotkeyGUI')
                try WinClose('ahk_id ' id)
        }

        ;==============================================

        if (param = 'oldest' || param = 'latest' || param = '') {
            m := Map()
            SetTitleMatchMode(1)
            for id in WinGetList('NotifyGUI_ ahk_class AutoHotkeyGUI') {
                try {
                    RegExMatch(WinGetTitle('ahk_id ' id), 'i)^NotifyGUI_\d+_[a-z]+_[a-z]+_\w+_\d+_\d+_(\d+)', &match)
                    m[match[1]] := id
                }
            }

            if (param = 'latest') {
                for timestamp, id in m
                    destroyId := id
            } else {
                for timestamp, id in m {
                    destroyId := id
                    break
                }
            }

            if IsSet(destroyId)
                try WinClose('ahk_id ' destroyId)
        }

        ;==============================================

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
    }

    ;============================================================================================

    static DestroyAllOnMonitorAtPosition(monNum, position)
    {
        for gIndex, value in this.mNotifyGUIs.Clone()
            if value.mon = monNum && value.pos = position && this.mNotifyGUIs.Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[gIndex], 'destroyAllOnMonitorAtPosition')

        this.WinGetList_WinClose('i)^NotifyGUI_' monNum '_' position '_ ahk_class AutoHotkeyGUI', 0, 'RegEx')
    }

    ;============================================================================================

    static DestroyAllOnAllMonitorAtPosition(position)
    {
        for gIndex, value in this.mNotifyGUIs.Clone()
            if value.pos = position && this.mNotifyGUIs.Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[gIndex], 'destroyAllOnAllMonitorAtPosition')

        this.WinGetList_WinClose('i)^NotifyGUI_\d+_' position '_ ahk_class AutoHotkeyGUI', 0, 'RegEx')
    }

    ;============================================================================================

    static DestroyAllOnMonitor(monNum)
    {
        for gIndex, value in this.mNotifyGUIs.Clone()
            if value.mon = monNum && this.mNotifyGUIs.Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[gIndex], 'destroyAllOnMonitor')

        this.WinGetList_WinClose('i)NotifyGUI_' monNum '_ ahk_class AutoHotkeyGUI', 0, 'RegEx')
    }

    ;============================================================================================

    static DestroyAll()
    {
        for gIndex, value in this.mNotifyGUIs.Clone()
            if this.mNotifyGUIs.Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[gIndex], 'destroyAll')

        this.WinGetList_WinClose('NotifyGUI_ ahk_class AutoHotkeyGUI', 0, 1)
    }

    ;============================================================================================

    static WinGetList_WinClose(winTitle, dhWindows, tmMode)
    {
        mDhwTmm := this.Set_DHWindows_TMMode(dhWindows, tmMode)
        SetWinDelay(25)

        for id in WinGetList(winTitle)
            try WinClose('ahk_id ' id)

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
    }

    ;============================================================================================

    static Exist(tag)
    {
        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_\d+_[a-z]+_[a-z]+_\w+_\d+_\d+_\d+_\Q' tag '\E$ ahk_class AutoHotkeyGUI') {
            idFound := id
            break
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
        return idFound ?? 0
    }

    ;============================================================================================

    static SetDefaultTheme(theme:='')
    {
        switch {
            case this.mThemes.Has(theme): this.mDefaults['theme'] := theme
            case !theme: this.mDefaults['theme'] := 'default'
        }
    }

    ;============================================================================================

    static SetDefault_MiscValues(m)
    {
        switch {
            case (m.has('iw') && !m.has('ih')) : m['ih'] := -1
            case (m.has('ih') && !m.has('iw')) : m['iw'] := -1
        }

        for key, value in this.mDefaults
            if !m.has(key)
                m[key] := value

        if !RegExMatch(m['style'], 'i)^(round|edge)$')
            m['style'] := this.mDefaults['style']

        for value in ['tfo', 'mfo'] {
            m['arr' value] := Array()

            for v in ['bold', 'italic', 'strike', 'underline']
                if InStr(m[value], v)
                    m['arr' value].Push(v)

            if !InStr(m[value], 'norm')
                m[value] := Trim('norm ' m[value])
        }
    }

    ;============================================================================================

    static ParseAnimationOption(m)
    {
        for value in ['show', 'hide'] {
            if (m.has(value)) {
                arrAnim := StrSplit(m[value], '@', A_Space)
                m[value 'Hex'] := this.mAW[arrAnim[1] = 0 ? 'none' : arrAnim[1]]
                arrAnim.Has(2) && (m[value 'Dur'] := Min(2500, Max(1, integer(arrAnim[2]))))
            }
        }
    }

    ;============================================================================================

    static SetAnimationDefault(m)
    {
        switch m['style'], false {
            case 'edge':
            {
                if !m.has('showHex') {
                    switch m['pos'], false {
                        case 'br', 'tr', 'ctr': m['showHex'] := this.mAW['slideWest']
                        case 'bl', 'tl', 'ctl': m['showHex'] := this.mAW['slideEast']
                        case 'bc': m['showHex'] := this.mAW['slideNorth']
                        case 'tc': m['showHex'] := this.mAW['slideSouth']
                        case 'ct': m['showHex'] := this.mAW['expand']
                        case 'mouse': m['showHex'] := this.mAW['none']
                    }
                }

                if !m.has('hideHex') {
                    switch m['pos'], false {
                        case 'br', 'tr', 'ctr': m['hideHex'] := this.mAW['slideEast']
                        case 'bl', 'tl', 'ctl': m['hideHex'] := this.mAW['slideWest']
                        case 'bc': m['hideHex'] := this.mAW['slideSouth']
                        case 'tc': m['hideHex'] := this.mAW['slideNorth']
                        case 'ct': m['hideHex'] := this.mAW['expand']
                        case 'mouse': m['hideHex'] := this.mAW['none']
                    }
                }
                m['showDur'] := m.Get('showDur', 75)
                m['hideDur'] := m.Get('hideDur', 100)
            }

            case 'round':
            {
                m['showHex'] := m.Get('showHex', this.mAW['fade'])
                m['hideHex'] := m.Get('hideHex', this.mAW['none'])
                m['showDur'] := m.Get('showDur', 1)
                m['hideDur'] := m.Get('hideDur', 1)
            }
        }
    }

    ;============================================================================================

    static ParsePadOption(m)
    {
        if (m.has('pad')) {
            arrPad := StrSplit(m['pad'], ',', A_Space)

            for index, value in ['padX', 'padY', 'gmX', 'gmY', 'spX', 'spY']
                if arrPad.Has(index) && arrPad[index] != ''
                    m[value] := Min(this.arrPadRange[2], Max(this.arrPadRange[1], Integer(arrPad[index])))
        }
    }

    ;============================================================================================

    static SetPadDefault(m)
    {
        m['padX'] := m.Has('padX') ? m['padX'] : (m['style'] = 'edge' ? 0 : 10)
        m['padY'] := m.Has('padY') ? m['padY'] : (m['style'] = 'edge' ? 0 : 10)

        for key in ['gmX', 'gmY', 'spX', 'spY']
            if !m.has(key)
                m[key] := this.mDefaults[key]
    }

    ;============================================================================================

    static ParseBorderOption(m)
    {
        if (m.has('bdr')) {
            arrBdr := StrSplit(m['bdr'], ',', A_Space)
            m['bdr'] := this.NormAHKColor(m['bdr'])
            m['bdrC'] := this.NormAHKColor(arrBdr[1])
            arrBdr.Has(2) && (m['bdrW'] := this.SetValidBorderWidth(arrBdr[2]))
        }
    }

    ;============================================================================================

    static SetBorderOption(m)
    {
        mTheme := this.mThemes.Has(m['theme']) ? this.mThemes[m['theme']] : this.MapCI()

        switch {
            case m['bdr'] = 0: m['bdrC'] := 0
            case m.Has('bdrC') && m['bdrC']: m['bdrC'] := m['bdrC']
            case (!m.Has('bdrC') || !m['bdrC']) && mTheme.Has('bdrC'): m['bdrC'] := mTheme['bdrC']
            case (!m.Has('bdrC') || !m['bdrC']) && !mTheme.Has('bdrC'): m['bdrC'] := 'default'
        }

        switch {
            case RegExMatch(m['bdrC'], 'i)^(default|1|0)$'): m['bdrW'] := 0
            case !m.Has('bdrW'): m['bdrW'] := (m['style'] = 'edge' ? this.bdrWdefaultEdge : 0)
            case m.Has('bdrW'):
                switch m['style'], false {
                    case 'edge': m['bdrW'] := this.SetValidBorderWidth(m['bdrW'])
                    case 'round': m['bdrW'] := 0
                }
        }
    }

    ;============================================================================================

    static SetValidBorderWidth(width) => Min(this.arrBdrWrange[2], Max(this.arrBdrWrange[1], Integer(width)))

    ;============================================================================================

    static SetFont(g, options, fontName)
    {
        g.SetFont(options, fontName)

        if !this.HasVal(strFont := options ' ' fontName, this.arrFonts)
            this.arrFonts.Push(strFont)

        if (this.arrFonts.Length >= 190) {
            this.isTooManyFonts := true
            return false
        }

        return true
    }

    ;============================================================================================

    static Set_DHWindows_TMMode(dhw, tmm)
    {
        dhwPrev := A_DetectHiddenWindows
        tmmPrev := A_TitleMatchMode
        DetectHiddenWindows(dhw)
        SetTitleMatchMode(tmm)
        return Map('dhwPrev', dhwPrev, 'tmmPrev', tmmPrev)
    }

    ;============================================================================================

    static Sound(sound)
    {
        if this.mSounds.Has(sound)
            sound := this.mSounds[sound]

        switch {
            case FileExist(sound): try this.PlayWavConcurrent(sound)
            case RegExMatch(sound,'^\*\-?\d+'): try Soundplay(sound)
        }
    }

    ;============================================================================================

    static OptionsStringToMap(m, haystack)
    {
        pos := 1
        while (pos := RegExMatch(haystack, 'i)(\w+)\s*=\s*(.*?)\s*(?=\s*\w+\s*=|$)', &match, pos))
            m[match[1]] := match[2], pos += StrLen(match[0])
    }

    ;============================================================================================

    static SetThemeSettings(m, mTheme)
    {
        if (m['theme'] != 'default')
            for key in mTheme['arrKeyDefined']
                if !m.Has(key)
                    m[key] := mTheme[key]
    }

    ;============================================================================================

    static GetTextWidth(str:='', font:='', fontSize:='', fontOption:='', monWALeft:='', monWATop:='')
    {
        g := Gui()
        g.SetFont('s' fontSize ' ' fontOption, font)
        g.txt := g.Add('Text',, str)
        g.Show('x' monWALeft ' y' monWATop ' Hide')
        g.txt.GetPos(,, &ctrlWidth)
        g.Destroy()
        return ctrlWidth
    }

    ;============================================================================================

    static GetPicWidth(picCtrl, monWALeft:='', monWATop:='')
    {
        g := Gui()
        g.pic := picCtrl
        g.Show('x' monWALeft ' y' monWATop ' Hide')
        g.pic.GetPos(,, &ctrlWidth)
        g.Destroy()
        return ctrlWidth
    }

    ;============================================================================================

    static SortArrayGUIPosY(arr, sortReverse := false)
    {
        for value in arr
            listValueY .= value['gY'] ','

        listSortValueY := Sort(RTrim(listValueY, ','), (sortReverse ? 'RN' : 'N') ' D,')
        sortArray := Array()

        for value in StrSplit(listSortValueY, ',')
            for v in arr
                if v['gY'] = value
                    sortArray.Push(v)

        return sortArray
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

    static ArrayToString(arr, delim)
    {
        for value in arr
            str .= value delim

        return RTrim(str, delim)
    }

    ;============================================================================================

    static NormAllColors(m)
    {
        for key in ['tc', 'mc', 'bc']
            if m.Has(key)
                m[key] := NormColor(m[key])

        for key in ['bdr', 'bdrC']
            if m.Has(key) && !RegExMatch(m[key], 'i)^(1|0|default)$')
                m[key] := NormColor(m[key])

        NormColor(key) => this.NormAHKColor(this.NormHexClrCode(key))
    }

    ;============================================================================================

    static NormAHKColor(color)
    {
        if RegExMatch(color, '^(0|1)$')
            return color

        for colorName, colorValue in this.mAHKcolors {
            if (colorValue = color) {
                color := colorName
                break
            }
        }

        return color
    }

    ;============================================================================================

    static NormHexClrCode(color)
    {
        if this.mAHKcolors.Has(color)
            color := this.mAHKcolors[color]

        if RegExMatch(Color, '^[0-9A-Fa-f]{1,6}$') && SubStr(color, 1, 2) != '0x'
            color := '0x' color

        if (RegExMatch(color, '^0x[0-9A-Fa-f]{1,6}$')) {
            hexPart := SubStr(color, 3)
            while StrLen(hexPart) < 6
                hexPart := '0' hexPart
            color := '0x' hexPart
        }
        else color := '0xFFFFFF'

        return color
    }

    /********************************************************************************************
     * @credits Klark92, XMCQCX (v2 conversion)
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117&hilit=FrameShadow AHK Forum}
     */
    static FrameShadow(hwnd)
    {
        DllCall("dwmapi.dll\DwmIsCompositionEnabled", "int*", &dwmEnabled:=0)

        if !dwmEnabled {
            DllCall("user32.dll\SetClassLongPtr", "ptr", hwnd, "int", -26, "ptr", DllCall("user32.dll\GetClassLongPtr", "ptr", hwnd, "int", -26) | 0x20000)
        }
        else {
            margins := Buffer(16, 0)
            NumPut("int", 1, "int", 1, "int", 1, "int", 1, margins)
            DllCall("dwmapi.dll\DwmSetWindowAttribute", "ptr", hwnd, "Int", 2, "Int*", 2, "Int", 4)
            DllCall("dwmapi.dll\DwmExtendFrameIntoClientArea", "ptr", hwnd, "ptr", margins)
        }
    }

    /********************************************************************************************
     * @credits ericreeves
     * @see {@link https://gist.github.com/ericreeves/fd426cc0457a5a47058e1ad1a29d9bd6 GitHub Gist}
     */
    static DrawBorderRound(hwnd, color)
    {
        color := this.RGB_BGR(this.NormHexClrCode(color))
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_BORDER_COLOR := 34, "int*", color, "int", 4)
    }

    ;============================================================================================

    static DrawBorderEdge(hwnd, color, width)
    {
        color := this.RGB_BGR(this.NormHexClrCode(color))
        rect := Buffer(16)
        DllCall("GetClientRect", "ptr", hwnd, "ptr", rect)
        left := NumGet(rect, 0, "int")
        top := NumGet(rect, 4, "int")
        right := NumGet(rect, 8, "int")
        bottom := NumGet(rect, 12, "int")
        hdc := DllCall("GetDC", "ptr", hwnd)
        hBrush := DllCall("gdi32\CreateSolidBrush", "uint", color, "ptr")
        hOldBrush := DllCall("gdi32\SelectObject", "ptr", hdc, "ptr", hBrush, "ptr")
        DllCall("gdi32\PatBlt", "ptr", hdc, "int", left, "int", top, "int", right - left, "int", width, "uint", 0x00F00021) ; Top border
        DllCall("gdi32\PatBlt", "ptr", hdc, "int", left, "int", bottom - width, "int", right - left, "int", width, "uint", 0x00F00021) ; Bottom border
        DllCall("gdi32\PatBlt", "ptr", hdc, "int", left, "int", top, "int", width, "int", bottom - top, "uint", 0x00F00021) ; Left border
        DllCall("gdi32\PatBlt", "ptr", hdc, "int", right - width, "int", top, "int", width, "int", bottom - top, "uint", 0x00F00021) ; Right border
        DllCall("gdi32\SelectObject", "ptr", hdc, "ptr", hOldBrush)
        DllCall("gdi32\DeleteObject", "ptr", hBrush)
        DllCall("ReleaseDC", "ptr", hwnd, "ptr", hdc)
    }

    ;============================================================================================

    static ReDrawBorderEdge(hwnd, style, color, width)
    {
        if style = 'edge' && !RegExMatch(color, 'i)^(default|1|0)$')
            this.DrawBorderEdge(hwnd, color, width)
    }

    ;============================================================================================

    static RedrawAllBorderEdge()
    {
        mDhwTmm := this.Set_DHWindows_TMMode(0, 1)

        for id in WinGetList('NotifyGUI_ ahk_class AutoHotkeyGUI') {
            try {
                RegExMatch(WinGetTitle('ahk_id ' id), 'i)^NotifyGUI_\d+_([a-z]+)_([a-z]+)_(\w+)_(\d+)_(\d+)_\d+', &match)
                this.ReDrawBorderEdge(id, match[2], match[3], match[4])
            }
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
    }

    ;============================================================================================

    static MonitorGetMouseIsIn()
    {
        cmmPrev := A_CoordModeMouse
        CoordMode('Mouse', 'Screen')
        MouseGetPos(&posX, &posY)
        CoordMode('Mouse', cmmPrev)

        Loop MonitorGetCount() {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            if (posX >= monLeft) && (posX <= monRight) && (posY >= monTop) && (posY <= monBottom)
                return A_Index
        }

        return MonitorGetPrimary()
    }

    ;============================================================================================

    static MonitorGetWindowIsIn(winTitle)
    {
        try WinGetPos(&posX, &posY, &winW, &winH, winTitle)
        catch
            return MonitorGetPrimary()

        centerWinX := posX + winW/2
        centerWinY := posY + winH/2

        Loop MonitorGetCount() {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            if (centerWinX >= monLeft) && (centerWinX < monRight) && (centerWinY >= monTop) && (centerWinY < monBottom)
                return A_Index
        }

        return MonitorGetPrimary()
    }

    /********************************************************************************************
     * @credits lexikos
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?t=103459 AHK Forum}
     */
    static CalculatePopupWindowPosition(hwnd)
    {
        cmmPrev := A_CoordModeMouse
        CoordMode('Mouse', 'Screen')
        MouseGetPos(&x, &y)
        CoordMode('Mouse', cmmPrev)
        anchorPt := Buffer(8)
        windowRect := Buffer(16), windowSize := windowRect.ptr + 8
        excludeRect := Buffer(16)
        outRect := Buffer(16)
        DllCall("GetClientRect", "ptr", hwnd, "ptr", windowRect)

        /*
            Windows 7 permits overlap with the taskbar, whereas Windows 10 requires the
            tooltip to be within the work area (WinMove can subvert that, so this is just
            for consistency with the normal behaviour).
        */
        flags := VerCompare(A_OSVersion, "6.2") < 0 ? 0 : 0x10000 ; TPM_WORKAREA

        NumPut("int", x+16, "int", y+16, anchorPt) ; ToolTip normally shows at an offset of 16,16 from the cursor.
        NumPut("int", x-3, "int", y-3, "int", x+3, "int", y+3, excludeRect) ; Avoid the area around the mouse pointer.
        DllCall("CalculatePopupWindowPosition", "ptr", anchorPt, "ptr", windowSize, "uint", flags, "ptr", excludeRect, "ptr", outRect)
        return 'x' NumGet(outRect, 0, 'int') ' y' NumGet(outRect, 4, 'int')
    }

    /********************************************************************************************
     * @credits Faddix
     * @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=130425 AHK Forum}
     */
    static PlayWavConcurrent(wavFileName) {
        static obj := initialize()

        initialize() {
            if !hModule := DllCall("LoadLibrary", "Str", "XAudio2_9.dll", "Ptr")
                return false

            DllCall("XAudio2_9\XAudio2Create", "Ptr*", IXAudio2 := ComValue(13, 0), "Uint", 0, "Uint", 1)
            ComCall(7, IXAudio2, "Ptr*", &IXAudio2MasteringVoice := 0, "Uint", 0, "Uint", 0, "Uint", 0, "Ptr", 0, "Ptr", 0, "Int", 6) ;CreateMasteringVoice
            return { IXAudio2: IXAudio2, someMap: Map() }
        }

        if !obj
            return

        ;freeing is unnecessary, but..
        XAUDIO2_VOICE_STATE := Buffer(A_PtrSize * 2 + 0x8)
        keys_to_delete := []
        for IXAudio2SourceVoice in obj.someMap {
            ComCall(25, IXAudio2SourceVoice, "Ptr", XAUDIO2_VOICE_STATE, "Uint", 0, "Int") ;GetState
            if (!NumGet(XAUDIO2_VOICE_STATE, A_PtrSize, "Uint")) { ;BuffersQueued (includes the one that is being processed)
                keys_to_delete.Push(IXAudio2SourceVoice)
            }
        }
        for IXAudio2SourceVoice in keys_to_delete {
            ComCall(20, IXAudio2SourceVoice, "Uint", 0, "Uint", 0) ;Stop
            ComCall(18, IXAudio2SourceVoice, "Int") ;void DestroyVoice
            obj.someMap.Delete(IXAudio2SourceVoice)
        }

        waveFile := FileRead(wavFileName, "RAW")
        root_tag_to_offset := get_tag_to_offset_map(0, waveFile.Size)
        idk_tag_to_offset := get_tag_to_offset_map(root_tag_to_offset["RIFF"].ofs + 0xc, waveFile.Size)
        WAVEFORMAT_ofs := idk_tag_to_offset["fmt "].ofs + 0x8
        data_ofs := idk_tag_to_offset["data"].ofs + 0x8
        data_size := idk_tag_to_offset["data"].size

        get_tag_to_offset_map(i, end) {
            tag_to_offset := Map()
            while (i < end) {
                tag := StrGet(waveFile.Ptr + i, 4, "UTF-8") ;RIFFChunk::tag
                size := NumGet(waveFile, i + 0x4, "Uint") ;RIFFChunk::size
                tag_to_offset[tag] := { ofs: i, size: size }
                i += size + 0x8
            }
            return tag_to_offset
        }

        ComCall(5, obj.IXAudio2, "Ptr*", &IXAudio2SourceVoice := 0, "Ptr", waveFile.Ptr + WAVEFORMAT_ofs, "int", 0, "float", 2.0, "Ptr", 0, "Ptr", 0, "Ptr", 0) ;CreateSourceVoice
        XAUDIO2_BUFFER := Buffer(A_PtrSize * 2 + 0x1c, 0)
        NumPut("Uint", 0x0040, XAUDIO2_BUFFER, 0x0) ;Flags=XAUDIO2_END_OF_STREAM
        NumPut("Uint", data_size, XAUDIO2_BUFFER, 0x4) ;AudioBytes
        NumPut("Ptr", waveFile.Ptr + data_ofs, XAUDIO2_BUFFER, 0x8) ;pAudioData
        ComCall(21, IXAudio2SourceVoice, "Ptr", XAUDIO2_BUFFER, "Ptr", 0) ;SubmitSourceBuffer
        ComCall(19, IXAudio2SourceVoice, "Uint", 0, "Uint", 0) ;Start
        obj.someMap[IXAudio2SourceVoice] := waveFile
    }

    ;============================================================================================

    static RGB_BGR(c) => ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)

    ;============================================================================================

    static MapCI() => (m := Map(), m.CaseSense := false, m)
}

/****************************************************************************************************************************************
 * @description: JSON格式字符串序列化和反序列化, 修改自[HotKeyIt/Yaml](https://github.com/HotKeyIt/Yaml)
 * 增加了对true/false/null类型的支持, 保留了数值的类型
 * @author thqby, HotKeyIt
 * @date 2024/02/24
 * @version 1.0.7
 ************************************************************************************************/
class _JSON_thqby {
	static null := ComValue(1, 0), true := ComValue(0xB, 1), false := ComValue(0xB, 0)

	/**
	 * Converts a AutoHotkey Object Notation JSON string into an object.
	 * @param text A valid JSON string.
	 * @param keepbooltype convert true/false/null to JSON.true / JSON.false / JSON.null where it's true, otherwise 1 / 0 / ''
	 * @param as_map object literals are converted to map, otherwise to object
	 */
	static parse(text, keepbooltype := false, as_map := true) {
		keepbooltype ? (_true := this.true, _false := this.false, _null := this.null) : (_true := true, _false := false, _null := "")
		as_map ? (map_set := (maptype := Map).Prototype.Set) : (map_set := (obj, key, val) => obj.%key% := val, maptype := Object)
		NQ := "", LF := "", LP := 0, P := "", R := ""
		D := [C := (A := InStr(text := LTrim(text, " `t`r`n"), "[") = 1) ? [] : maptype()], text := LTrim(SubStr(text, 2), " `t`r`n"), L := 1, N := 0, V := K := "", J := C, !(Q := InStr(text, '"') != 1) ? text := LTrim(text, '"') : ""
		Loop Parse text, '"' {
			Q := NQ ? 1 : !Q
			NQ := Q && RegExMatch(A_LoopField, '(^|[^\\])(\\\\)*\\$')
			if !Q {
				if (t := Trim(A_LoopField, " `t`r`n")) = "," || (t = ":" && V := 1)
					continue
				else if t && (InStr("{[]},:", SubStr(t, 1, 1)) || A && RegExMatch(t, "m)^(null|false|true|-?\d+(\.\d*(e[-+]\d+)?)?)\s*[,}\]\r\n]")) {
					Loop Parse t {
						if N && N--
							continue
						if InStr("`n`r `t", A_LoopField)
							continue
						else if InStr("{[", A_LoopField) {
							if !A && !V
								throw Error("Malformed JSON - missing key.", 0, t)
							C := A_LoopField = "[" ? [] : maptype(), A ? D[L].Push(C) : map_set(D[L], K, C), D.Has(++L) ? D[L] := C : D.Push(C), V := "", A := Type(C) = "Array"
							continue
						} else if InStr("]}", A_LoopField) {
							if !A && V
								throw Error("Malformed JSON - missing value.", 0, t)
							else if L = 0
								throw Error("Malformed JSON - to many closing brackets.", 0, t)
							else C := --L = 0 ? "" : D[L], A := Type(C) = "Array"
						} else if !(InStr(" `t`r,", A_LoopField) || (A_LoopField = ":" && V := 1)) {
							if RegExMatch(SubStr(t, A_Index), "m)^(null|false|true|-?\d+(\.\d*(e[-+]\d+)?)?)\s*[,}\]\r\n]", &R) && (N := R.Len(0) - 2, R := R.1, 1) {
								if A
									C.Push(R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R)
								else if V
									map_set(C, K, R = "null" ? _null : R = "true" ? _true : R = "false" ? _false : IsNumber(R) ? R + 0 : R), K := V := ""
								else throw Error("Malformed JSON - missing key.", 0, t)
							} else {
								; Added support for comments without '"'
								if A_LoopField == '/' {
									nt := SubStr(t, A_Index + 1, 1), N := 0
									if nt == '/' {
										if nt := InStr(t, '`n', , A_Index + 2)
											N := nt - A_Index - 1
									} else if nt == '*' {
										if nt := InStr(t, '*/', , A_Index + 2)
											N := nt + 1 - A_Index
									} else nt := 0
									if N
										continue
								}
								throw Error("Malformed JSON - unrecognized character.", 0, A_LoopField " in " t)
							}
						}
					}
				} else if A || InStr(t, ':') > 1
					throw Error("Malformed JSON - unrecognized character.", 0, SubStr(t, 1, 1) " in " t)
			} else if NQ && (P .= A_LoopField '"', 1)
				continue
			else if A
				LF := P A_LoopField, C.Push(InStr(LF, "\") ? UC(LF) : LF), P := ""
			else if V
				LF := P A_LoopField, map_set(C, K, InStr(LF, "\") ? UC(LF) : LF), K := V := P := ""
			else
				LF := P A_LoopField, K := InStr(LF, "\") ? UC(LF) : LF, P := ""
		}
		return J
		UC(S, e := 1) {
			static m := Map('"', '"', "a", "`a", "b", "`b", "t", "`t", "n", "`n", "v", "`v", "f", "`f", "r", "`r")
			local v := ""
			Loop Parse S, "\"
				if !((e := !e) && A_LoopField = "" ? v .= "\" : !e ? (v .= A_LoopField, 1) : 0)
					v .= (t := m.Get(SubStr(A_LoopField, 1, 1), 0)) ? t SubStr(A_LoopField, 2) :
						(t := RegExMatch(A_LoopField, "i)^(u[\da-f]{4}|x[\da-f]{2})\K")) ?
							Chr("0x" SubStr(A_LoopField, 2, t - 2)) SubStr(A_LoopField, t) : "\" A_LoopField,
							e := A_LoopField = "" ? e : !e
			return v
		}
	}

	/**
	 * Converts a AutoHotkey Array/Map/Object to a Object Notation JSON string.
	 * @param obj A AutoHotkey value, usually an object or array or map, to be converted.
	 * @param expandlevel The level of JSON string need to expand, by default expand all.
	 * @param space Adds indentation, white space, and line break characters to the return-value JSON text to make it easier to read.
	 */
	static stringify(obj, expandlevel := unset, space := "  ") {
		expandlevel := IsSet(expandlevel) ? Abs(expandlevel) : 10000000
		return Trim(CO(obj, expandlevel))
		CO(O, J := 0, R := 0, Q := 0) {
			static M1 := "{", M2 := "}", S1 := "[", S2 := "]", N := "`n", C := ",", S := "- ", E := "", K := ":"
			if (OT := Type(O)) = "Array" {
				D := !R ? S1 : ""
				for key, value in O {
					F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
					Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
					D .= (J > R ? "`n" CL(R + 2) : "") (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (OT = "Array" && O.Length = A_Index ? E : C)
				}
			} else {
				D := !R ? M1 : ""
				for key, value in (OT := Type(O)) = "Map" ? (Y := 1, O) : (Y := 0, O.OwnProps()) {
					F := (VT := Type(value)) = "Array" ? "S" : InStr("Map,Object", VT) ? "M" : E
					Z := VT = "Array" && value.Length = 0 ? "[]" : ((VT = "Map" && value.count = 0) || (VT = "Object" && ObjOwnPropCount(value) = 0)) ? "{}" : ""
					D .= (J > R ? "`n" CL(R + 2) : "") (Q = "S" && A_Index = 1 ? M1 : E) ES(key) K (F ? (%F%1 (Z ? "" : CO(value, J, R + 1, F)) %F%2) : ES(value)) (Q = "S" && A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? M2 : E) (J != 0 || R ? (A_Index = (Y ? O.count : ObjOwnPropCount(O)) ? E : C) : E)
					if J = 0 && !R
						D .= (A_Index < (Y ? O.count : ObjOwnPropCount(O)) ? C : E)
				}
			}
			if J > R
				D .= "`n" CL(R + 1)
			if R = 0
				D := RegExReplace(D, "^\R+") (OT = "Array" ? S2 : M2)
			return D
		}
		ES(S) {
			switch Type(S) {
				case "Float":
					if (v := '', d := InStr(S, 'e'))
						v := SubStr(S, d), S := SubStr(S, 1, d - 1)
					if ((StrLen(S) > 17) && (d := RegExMatch(S, "(99999+|00000+)\d{0,3}$")))
						S := Round(S, Max(1, d - InStr(S, ".") - 1))
					return S v
				case "Integer":
					return S
				case "String":
					S := StrReplace(S, "\", "\\")
					S := StrReplace(S, "`t", "\t")
					S := StrReplace(S, "`r", "\r")
					S := StrReplace(S, "`n", "\n")
					S := StrReplace(S, "`b", "\b")
					S := StrReplace(S, "`f", "\f")
					S := StrReplace(S, "`v", "\v")
					S := StrReplace(S, '"', '\"')
					return '"' S '"'
				default:
					return S == this.true ? "true" : S == this.false ? "false" : "null"
			}
		}
		CL(i) {
			Loop (s := "", space ? i - 1 : 0)
				s .= space
			return s
		}
	}
}
