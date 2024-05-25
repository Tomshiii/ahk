/**********************************************
* @description Notify - This class makes it easier to create and display notification GUIs.
* @author XMCQCX
* @date 2024/05/24
* @version 1.2.1
* @see {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=129635 |AHK Forum}
* @credits
* - gwarble for the original v1 Notify function. {@link https://www.autohotkey.com/board/topic/44870-notify-multiple-easy-tray-area-notifications-v04991/ |source}
* - Inspired by the Automator Notify Class for v2. {@link https://www.the-automator.com/downloads/maestrith-notify-class-v2/ |source}
* @features
* - Changing text, image, font, color.
* - Rounded or edged corners.
* - Positioning at different locations on the screen.
* - Playing sound when it appears.
* - Call function when clicking on it.
* @methods
* - Show - Builds and shows a notification GUI.
* - SoundsList - GUI to list and hear all the available sounds.
* - DestroyAllAtPosition(position) - Destroy all GUIs at the specified position.
* - DestroyAll - Destroy all GUIs.
* @example
* #include <v2\Notify\Notify>
* Notify.SoundsList()
* Notify.Show('The quick brown fox jumps over the lazy dog.',,,,, 'POS=TC')
* Notify.Show(, 'Some information to show.', 'iconi', 'soundi',, 'POS=BC MC=black BC=75AEDC')
* Notify.Show('Alert!', 'You are being warned.', 'icon!', 'soundx',, 'TC=black MC=black BC=DCCC75')
* Notify.Show('Error', 'Something has gone wrong!', 'iconx', 'soundx',, 'BC=C72424 STYLE=edge AWD=500')
**********************************************/
Class Notify {

    /**********************************************
    * @method Show
    * @description Builds and shows a notification GUI.
    * @param title Title of the notification.
    * @param msg Message of the notification.
    * @param icon {@link https://www.autohotkey.com/docs/v2/lib/GuiControls.htm#Picture |Picture GuiControls}
    * - The path of an icon/picture. See link above for supported file types.
    * - String: 'icon!', 'icon?', 'iconx', 'iconi'
    * - Icon from dll: A_WinDir '\system32\user32.dll|Icon4'
    * @param sound {@link https://www.autohotkey.com/docs/v2/lib/SoundPlay.htm |SoundPlay function}
    * - The path of the .wav file to be played.
    * - String: 'soundx', 'soundi'
    * - WAV files located in "C:\Windows\Media" and "Music\Sounds": 'Ding', 'tada', 'Windows Error' etc.
    * - Call Notify.SoundsList() to list and hear all the available sounds.
    * @param callback A function object to call when left-clicking on the GUI. {@link https://www.autohotkey.com/docs/v2/misc/Functor.htm |Function Objects}
    * @param options Default*
    * - `POS`
    *   - `BR` - Bottom right*
    *   - `BC` - Bottom center
    *   - `BL` - Bottom left
    *   - `TL` - Top left
    *   - `TC` - Top center
    *   - `TR` - Top right
    *   - `CT` - Center
    * - `ALI`
    *   - `LEFT`
    *   - `RIGHT`
    *   - `CENTER`
    * - `DUR` - The display duration (in seconds) before it disappears. Set it to 0 to keep it on the screen until left-clicking on the GUI. *8
    * - `IW` - Image width `*32`
    * - `IH` - Image height `*32`
    * - `TF` - Title font `*Segoe UI bold`
    * - `TS` - Title size `*15`
    * - `TC` - Title color `*White`
    * - `MF` - Message font `*Segoe UI`
    * - `MS` - Message size `*12`
    * - `MC` - Message color `*White`
    * - `BC` - Background color `*1F1F1F`
    * - `STYLE` - Notification style
    *   - `round` - Rounded corners *
    *   - `edge` - Edged corners
    * - `AWD` - Animation window duration in milliseconds for the GUI to disappear. Round style not supported. `*25`
    * - `DG`
    *   - `1` - Do not destroy GUIs. *
    *   - `2` - Destroy all GUIs at the position option.
    *   - `3` - Destroy all GUIs.
    * - `OPT` - Sets various options and styles for the appearance and behavior of the window. *+Owner -Caption +AlwaysOnTop {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Opt |GUI Opt}
    * @example options parameter:
    * 'POS=TL DUR=7 IW=70 IH=100 TF=Impact TS=42 TC=GREEN MF=MV Boli MS=35 MC=Olive BC=Silver STYLE=edge AWD=500 DG=2'
    * @returns GUI hwnd
    **********************************************/
    static Show(title:='', msg:='', icon :='', sound:='', callback:='', options:='') => this._Show(title, msg, icon, sound, callback, options)

    Static __New()
    {
        this.mNotifyGUIs := Map(), this.mNotifyGUIs.CaseSense := 'off'
        this.aPosition := ['br', 'bc', 'bl', 'tl', 'tc', 'tr', 'ct']

        for position in this.aPosition
            this.mNotifyGUIs[position] := Map()

        this.mIconsUser32 := Map(), this.mIconsUser32.CaseSense := 'off'
        this.mIconsUser32['icon!'] := 2
        this.mIconsUser32['icon?'] := 3
        this.mIconsUser32['iconx'] := 4
        this.mIconsUser32['iconi'] := 5

        ;==============================================

        this.pathSoundsFolder := RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'My Music') '\Sounds'
        this.mSounds := Map(), this.mSounds.CaseSense := 'off'
        this.mSounds['soundx'] := '*16'
        this.mSounds['soundi'] := '*64'

        for _, path in [A_WinDir '\Media', this.pathSoundsFolder] {
            Loop Files path '\*.wav' {
                SplitPath(A_LoopFilePath,,,, &fileName)
                this.mSounds[fileName] := A_LoopFilePath
            }
        }

        this.aSounds := Array()

        for soundName in this.mSounds
            this.aSounds.Push(soundName)
    }

    ;============================================================================================

    Static _Show(title:='', msg:='', icon :='', sound:='', callback:='', options:='')
    {
        Critical

        static strOptions := 'pos|ali|dur|iw|ih|tf|ts|tc|mf|ms|mc|bc|style|awd|dg|opt'
        static gLastPosYbr :=0, gLastPosYbc :=0, gLastPosYbL :=0, gLastPosYtL :=10, gLastPosYtc :=10, gLastPosYtr :=10, gLastPosYctr :=''
        static paddingX := 15, paddingY := 10, paddingYb := 75, paddingXpicTxt := 10
        static gIndex := 0
        gIndex++

        ; Default options ============================
        pos := 'br'
        ali := 'left'
        dur := 8
        iw := 32
        ih := 32
        tf := 'Segoe UI bold'
        ts := 15
        tc := 'white'
        mf := 'Segoe UI'
        ms := 12
        mc := 'white'
        bc := '1F1F1F'
        style := 'round'
        awd := 25
        dg := 1
        opt := '+Owner -Caption +AlwaysOnTop'

        ;==============================================
        m := Map(), m.CaseSense := 'off'

        while RegExMatch(Trim(options), 'i)(\b(?:' strOptions ')\b)\s*=\s*(.+?)(?=\s*(?:\b(?:' strOptions ')\b|\z))', &match, IsSet(match) ? match.Pos + match.Len : 1)
            m[Trim(match[1])] := Trim(match[2])

        Switch {
            case (m.has('iw') && !m.has('ih')): m['ih'] := m['iw']
            case (m.has('ih') && !m.has('iw')): m['iw'] := m['ih']
        }

        for value in StrSplit(strOptions, '|')
            if !m.has(value)
                m[value] := %value%

        ;==============================================

        g := Gui(m['opt'], gTitle := 'NotifyGUI_' m['pos'])
        g.BackColor := m['bc']
        g.MarginX := 15
        g.MarginY := 15
        g.gIndex := gIndex
        g.position := m['pos']
        g.style := m['style']
        g.animeWinDur := m['awd']

        ;==============================================

        switch {
            case FileExist(icon) || RegExMatch(icon, 'i)h(icon|bitmap).*\d+'):
                try g.pic := g.Add('Picture', 'w' m['iw'] ' h' m['ih'], icon)

            case RegExMatch(icon, 'i)^(icon!|icon\?|iconx|iconi)$'):
                try g.pic := g.Add('Picture', 'w' m['iw'] ' h' m['ih'] ' Icon' this.mIconsUser32[icon], A_WinDir '\system32\user32.dll')

            case RegExMatch(icon, 'i)(.+?\.(?:dll|exe))\|icon(\d+)', &match) && FileExist(match[1]):
                try g.pic := g.Add('Picture', 'w' m['iw'] ' h' m['ih'] ' Icon' match[2], match[1])
        }

        ;==============================================

        for hwnd, ctrlObj in g
            if ctrlObj.Type == 'Pic'
                gPicWidth := this.ControlGetPicWidth(g.pic) + paddingXpicTxt + g.MarginX*2 + paddingY*2

        visibleScreenWidth := A_ScreenWidth / (A_ScreenDPI / 96)

        if title && (this.ControlGetTextWidth(title, m['tf'], m['ts']) + (IsSet(gPicWidth) ? gPicWidth : 0)) > (visibleScreenWidth)
            titleWidth := visibleScreenWidth - (IsSet(gPicWidth) ? gPicWidth : 0)

        if msg && (this.ControlGetTextWidth(msg, m['mf'], m['ms']) + (IsSet(gPicWidth) ? gPicWidth : 0)) > (visibleScreenWidth)
            msgWidth := visibleScreenWidth - (IsSet(gPicWidth) ? gPicWidth : 0)

        ;==============================================

        if (title) {
            g.SetFont('s' m['ts'] ' c' m['tc'], m['tf'])
            g.Add('Text', (IsSet(gPicWidth) ? 'x+' paddingXpicTxt : '') (IsSet(titleWidth) ? ' w' titleWidth : ''), title)
        }

        if (msg) {
            if title
                g.MarginY := 6

            g.SetFont('s' m['ms'] ' c' m['mc'], m['mf'])
            g.Add('Text', m["ali"] (!title && IsSet(gPicWidth) ? ' x+' paddingXpicTxt : '') (IsSet(msgWidth) ? ' w' msgWidth : ''), msg)
        }

        g.MarginY := 15
        g.Show('Hide')
        WinGetPos(&gX, &gY, &gW, &gH, g)
        clickArea := g.Add('Text', 'x0 y0 w' gW ' h' gH ' BackgroundTrans')

        if callback
            clickArea.OnEvent('Click', callback)

        clickArea.OnEvent('Click', this.gDestroy.Bind(this, g))
        SetTimer(  g.boundFuncTimer := this.gDestroy.Bind(this, g)  , -m['dur']*1000)

        if sound
            this.Sound(sound)

        switch m['dg'] {
            case 2: this.DestroyAllAtPosition(m['pos'])
            case 3: this.DestroyAll()
        }

        ;==============================================

        Switch m['pos'], 'off' {
            case 'br':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYbr := 0

                if gLastPosYbr < gH + paddingY
                    gPos := 'x' A_ScreenWidth - gW - paddingX 'y' (gLastPosYbr := A_ScreenHeight - gH - paddingYb)
                else
                    gPos := 'x' A_ScreenWidth - gW - paddingX ' y' (gLastPosYbr := gLastPosYbr - gH - paddingY)
            }

            case 'bc':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYbc := 0

                if gLastPosYbc < gH + paddingY
                    gPos := 'x' A_ScreenWidth/2 - gW/2 'y' (gLastPosYbc := A_ScreenHeight - gH - paddingYb)
                else
                    gPos := 'x' A_ScreenWidth/2 - gW/2 'y' (gLastPosYbc := gLastPosYbc - gH - paddingY)
            }

            case 'bl':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYbL := 0

                if gLastPosYbL < gH + paddingY
                    gPos := 'x' paddingX ' y' (gLastPosYbL := A_ScreenHeight - gH - paddingYb)
                else
                    gPos := 'x' paddingX ' y' (gLastPosYbL := gLastPosYbL - gH - paddingY)
            }

            case 'tl':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYtL := paddingY

                if (gLastPosYtL = paddingY || (gLastPosYtL + gH + paddingY) > A_ScreenHeight)
                    gPos := 'x' paddingX ' y' paddingY, gLastPosYtL := paddingY + gH
                else
                    gPos := 'x' paddingX ' y' gLastPosYtL + paddingY, (gLastPosYtL := gLastPosYtL + paddingY + gH)
            }

            case 'tc':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYtc := paddingY

                if (gLastPosYtc = paddingY || (gLastPosYtc + gH + paddingY) > A_ScreenHeight)
                    gPos := 'x' A_ScreenWidth/2 - gW/2 ' y' paddingY, gLastPosYtc := paddingY + gH
                else
                    gPos := 'x' A_ScreenWidth/2 - gW/2 ' y' gLastPosYtc + paddingY, (gLastPosYtc := gLastPosYtc + paddingY + gH)
            }

            case 'tr':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYtr := paddingY

                if (gLastPosYtr = paddingY || (gLastPosYtr + gH + paddingY) > A_ScreenHeight)
                    gPos := 'x' A_ScreenWidth - gW - paddingX ' y' paddingY, gLastPosYtr := paddingY + gH
                else
                    gPos := 'x' A_ScreenWidth - gW - paddingX ' y' gLastPosYtr + paddingY, (gLastPosYtr := gLastPosYtr + paddingY + gH)
            }

            case 'ct':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYctr := ''

                if (!gLastPosYctr || (gLastPosYctr + gH + paddingY + paddingYb) > A_ScreenHeight)
                    gPos := '', gLastPosYctr := gY + gH
                else
                    gPos := 'y' gLastPosYctr + paddingY, (gLastPosYctr := gLastPosYctr + paddingY + gH)
            }
        }

        ;==============================================

        Switch m['style'], 'off' {
            case 'round':
            {
                g.Show(gPos ' NoActivate Hide')
                this.FrameShadow(g.hwnd)
                DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', 25, 'Int', AW_BLEND := 0x00080000)
            }

            default:
            {
                g.Opt('+Border')
                g.Show(gPos ' NoActivate')
            }
        }

        this.mNotifyGUIs[m['pos']][gIndex] := g
        Critical('Off')
        return g.hwnd
    }

    ;============================================================================================

    static gDestroy(g, *)
    {
        Critical

        SetTimer(this.mNotifyGUIs[g.position][g.gIndex].boundFuncTimer, 0)

        Switch g.style, 'off' {
            case 'round': DllCall('AnimateWindow', 'Ptr', this.mNotifyGUIs[g.position][g.gIndex].hwnd, 'Int', 25, 'Int', AW_HIDE := 0x00010000)

            default:
            {
                Switch g.position, 'off' {
                    case 'br', 'tr': animate := '0x00050001' ; AW_HOR_POSITIVE
                    case 'bl', 'tl': animate := '0x00050002' ; AW_HOR_NEGATIVE
                    case 'bc': animate := '0x00050004' ; AW_VER_POSITIVE
                    case 'tc': animate := '0x00050008' ; AW_VER_NEGATIVE
                    case 'ct': animate := '0x00010000' ; AW_HIDE
                }
                DllCall('AnimateWindow', 'Ptr', this.mNotifyGUIs[g.position][g.gIndex].hwnd, 'Int', this.mNotifyGUIs[g.position][g.gIndex].animeWinDur, 'Int', animate)
            }
        }

        this.mNotifyGUIs[g.position][g.gIndex].Destroy()
        this.mNotifyGUIs[g.position].Delete(g.gIndex)
        Critical('Off')
    }

    ;============================================================================================
    ; FrameShadow by Klark92  https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117&hilit=FrameShadow
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

    ;============================================================================================

    ; Destroy the currently existing GUIs at the position parameter.
    static DestroyAllAtPosition(position)
    {
        for gIndex, _ in this.mNotifyGUIs[position].Clone()
            this.gDestroy(this.mNotifyGUIs[position][gIndex])

        tmmPrev := A_TitleMatchMode
        SetTitleMatchMode('RegEx')

        for id in WinGetList('i)NotifyGUI_' position ' ahk_class AutoHotkeyGUI')
            WinClose('ahk_id ' id)

        SetTitleMatchMode(tmmPrev)
    }

    ;============================================================================================

    ; Destroy the currently existing GUIs at all positions.
    static DestroyAll()
    {
        for position in this.aPosition
            for gIndex, _ in this.mNotifyGUIs[position].Clone()
                this.gDestroy(this.mNotifyGUIs[position][gIndex])

        tmmPrev := A_TitleMatchMode
        SetTitleMatchMode('RegEx')

        for id in WinGetList('i)NotifyGUI_ ahk_class AutoHotkeyGUI')
            WinClose('ahk_id ' id)

        SetTitleMatchMode(tmmPrev)
    }

    ;============================================================================================

    static Sound(sound)
    {
        if RegExMatch(sound, 'i)^(soundx|soundi)$') || this.mSounds.Has(sound)
            sound := this.mSounds[sound]

        if FileExist(sound) || RegExMatch(sound,'^\*\-?\d+')
            Soundplay(sound)
    }

    ;============================================================================================

    static SoundsList()
    {
        this.gSnd := Gui(, 'Notify - Sounds list')
        this.gSnd.MarginY := 15
        this.gSnd.OnEvent('Close', (*) => this.gSnd.Destroy())
        this.gSnd.ddl := this.gSnd.Add('DropDownList', 'w260 Choose1', this.aSounds)
        this.gSnd.ddl.OnEvent('Change', this.gSnd_ddl_CtrlChange.Bind(this))
        this.gSnd.btn := this.gSnd.Add('Button',, 'Save to Clipboard')
        this.gSnd.btn.OnEvent('Click', this.gSnd_SaveToClipboard.Bind(this))
        this.gSnd.Show()
    }

    ;============================================================================================

    static gSnd_SaveToClipboard(*)
    {
        A_Clipboard := this.gSnd.ddl.Text
        this.Show('"' A_Clipboard '"', 'Saved to clipboard.', 'iconi',,, 'POS=BC DUR=5 DG=2')
    }

    ;============================================================================================

    static gSnd_ddl_CtrlChange(*) => SetTimer( this.Sound.Bind(this, this.gSnd.ddl.Text) , -1 )

    ;============================================================================================

    static ControlGetTextWidth(str:='', font:='', fontSize:='')
    {
        g := Gui()
        g.SetFont('s' fontSize, font)
        g.txt := g.Add('Text',, str)
        g.Show('Hide')
        g.txt.GetPos(,, &ctrlWidth)
        g.Destroy()
        return ctrlWidth
    }

    ;============================================================================================

    static ControlGetPicWidth(picCtrl)
    {
        g := Gui()
        g.pic := picCtrl
        g.Show('Hide')
        g.pic.GetPos(,, &ctrlWidth)
        g.Destroy()
        return ctrlWidth
    }
}

;============================================================================================