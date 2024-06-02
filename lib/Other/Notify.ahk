/**********************************************
* @description Notify - This class makes it easier to create and display notification GUIs.
* @author XMCQCX
* @date 2024/05/31
* @version 1.3.0
* @see {@link https://github.com/XMCQCX/Notify_Class Notify_Class - GitHub} | {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=129635 Notify_Class - AHK Forum}
* @credits
* - Notify by gwarble. {@link https://www.autohotkey.com/board/topic/44870-notify-multiple-easy-tray-area-notifications-v04991/ source}
* - FrameShadow by Klark92. {@link https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117&hilit=FrameShadow source}
* - WiseGui by SKAN {@link https://www.autohotkey.com/boards/viewtopic.php?t=94044 source}
* - Notify Class v2 by the-Automator. {@link https://www.the-automator.com/downloads/maestrith-notify-class-v2/ source}
* @features
* - Changing text, image, font, color, animation.
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
* Notify.Show('The quick brown fox jumps over the lazy dog.',,,,, 'dur=4 pos=tc')
* Notify.Show('Alert!', 'You are being warned.', 'icon!', 'soundx',, 'TC=black MC=black BC=DCCC75')
* Notify.Show('Error', 'Something has gone wrong!', 'iconx', 'soundx',, 'BC=C72424 style=edge show=expand hide=expand')
* Notify.Show('Info', 'Some information to show.', 'iconi',,, 'TC=black MC=black BC=75AEDC style=edge show=slideWest@250 hide=slideEast@250')
**********************************************/
Class Notify {
    
    /**********************************************
    * @method Show(title, msg, icon, sound, callback, options)
    * @description Builds and shows a notification GUI.    
    * @param title Title of the notification.
    * @param msg Message of the notification.
    * @param icon {@link https://www.autohotkey.com/docs/v2/lib/GuiControls.htm#Picture Picture GuiControls}
    * - The path of an icon/picture. See link above for supported file types.
    * - String: 'icon!', 'icon?', 'iconx', 'iconi'
    * - Icon from dll: A_WinDir '\system32\user32.dll|Icon4'
    * @param sound {@link https://www.autohotkey.com/docs/v2/lib/SoundPlay.htm SoundPlay function}
    * - The path of the WAV file to be played.
    * - String: 'soundx', 'soundi'
    * - Filename of WAV file located in "C:\Windows\Media" and "Music\Sounds": 'Ding', 'tada', 'Windows Error' etc.
    * - Call Notify.SoundsList() to list and hear all the available sounds.
    * @param callback Function object to call when left-clicking on the GUI. {@link https://www.autohotkey.com/docs/v2/misc/Functor.htm Function Objects}
    * @param options For example: `'POS=TL DUR=6 IW=70 TF=Impact TS=42 TC=GREEN MC=blue BC=Silver STYLE=edge DG=2 SHOW=Fade Hide=Fade@250'`
    * - Case-insensitive.
    * - The asterisk (*) indicates the default option.
    * - `POS` - Position
    *   - `BR` - Bottom right*
    *   - `BC` - Bottom center
    *   - `BL` - Bottom left
    *   - `TL` - Top left
    *   - `TC` - Top center
    *   - `TR` - Top right
    *   - `CT` - Center
    * - `DUR` - Display duration (in seconds). Set it to 0 to keep it on the screen until left-clicking on the GUI. `*8`
    * - `IW` - Image width `*32`
    * - `IH` - Image height `*32`
    * - `TF` - Title font `*Segoe UI bold`
    * - `TS` - Title size `*15`
    * - `TC` - Title color `*White`
    * - `MF` - Message font `*Segoe UI`
    * - `MS` - Message size `*12`
    * - `MC` - Message color `*White`
    * - `ALI` - Message alignment
    *   - `LEFT`* 
    *   - `RIGHT`
    *   - `CENTER`
    * - `BC` - Background color `*1F1F1F`
    * - `STYLE` - Notification style
    *   - `ROUND` - Rounded corners *
    *   - `EDGE` - Edged corners
    * - `BDR` - Border. Edged corners only.
    *   - `0` - No border
    *   - `1` - Border *
    * - `SHOW` `*50` and `HIDE` `*75` - Animation when showing and hiding the GUI.
    * - For example: `'STYLE=EDGE SHOW=SLIDEWEST HIDE=SLIDEEAST@500'`
    * - The duration, which is optional, can range from 25 to 2500 milliseconds.
    * - Only the fade animation is rendered correctly with the round style.
    * - `SHOW` and `HIDE`
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
    * - `DG` - Destroy GUIs
    *   - `1` - Do not destroy GUIs. * 
    *   - `2` - Destroy all GUIs at the position option.
    *   - `3` - Destroy all GUIs.
    * - `OPT` - Sets various options and styles for the appearance and behavior of the window. `*+Owner -Caption +AlwaysOnTop` {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Opt GUI Opt}    
    * @returns GUI hwnd
    **********************************************/
    static Show(title:='', msg:='', icon:='', sound:='', callback:='', options:='') => this._Show(title, msg, icon, sound, callback, options)

    ;============================================================================================
    
    Static __New()
    {
        this.mDefault := Map(), this.mDefault.CaseSense := 'off'
        this.mDefault['pos'] := 'br'           ; Position
        this.mDefault['dur'] := 8              ; Duration    
        this.mDefault['iw'] := 32              ; Image width
        this.mDefault['ih'] := 32              ; Image height
        this.mDefault['tf'] := 'Segoe UI bold' ; Title font
        this.mDefault['ts'] := 15              ; Title size
        this.mDefault['tc'] := 'white'       ; Title color
        this.mDefault['mf'] := 'Segoe UI'      ; Message font
        this.mDefault['ms'] := 12              ; Message size
        this.mDefault['mc'] := 'white'       ; Message color
        this.mDefault['ali'] := 'left'         ; Message alignment
        this.mDefault['bc'] := '1F1F1F'      ; Background color
        this.mDefault['style'] := 'round'      ; Style
        this.mDefault['dg'] := 1               ; Destroy GUIs
        this.mDefault['opt'] := '+Owner -Caption +AlwaysOnTop' ; GUI options
        this.mDefault['bdr'] := 1              ; Border
        this.mDefault['showDur'] := 50         ; Animate window show duration
        this.mDefault['hideDur'] := 75         ; Animate window hide duration

        this.mNotifyGUIs := Map(), this.mNotifyGUIs.CaseSense := 'off'
        this.aPosition := ['br', 'bc', 'bl', 'tl', 'tc', 'tr', 'ct']
        
        for position in this.aPosition
            this.mNotifyGUIs[position] := Map()        

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
        
        this.mIconsUser32 := Map(), this.mIconsUser32.CaseSense := 'off'
        this.mIconsUser32['icon!'] := 2
        this.mIconsUser32['icon?'] := 3
        this.mIconsUser32['iconx'] := 4
        this.mIconsUser32['iconi'] := 5        

        ; Animate window show/hide effects ================
        this.mAW := Map(), this.mAW.CaseSense := 'off'  
        this.mAW['fade']           := '0x80000' ; AW_BLEND 
        this.mAW['expand']         := '0x00010' ; AW_CENTER
        this.mAW['slideEast']      := '0x40001' ; AW_SLIDE | AW_HOR_POSITIVE
        this.mAW['slideWest']      := '0x40002' ; AW_SLIDE | AW_HOR_NEGATIVE
        this.mAW['slideNorth']     := '0x40008' ; AW_SLIDE | AW_VER_NEGATIVE
        this.mAW['slideSouth']     := '0x40004' ; AW_SLIDE | AW_VER_POSITIVE
        this.mAW['slideNorthEast'] := '0x40009' ; AW_SLIDE | AW_VER_NEGATIVE | AW_HOR_POSITIVE
        this.mAW['SlideNorthWest'] := '0x4000A' ; AW_SLIDE | AW_VER_NEGATIVE | AW_HOR_NEGATIVE
        this.mAW['slideSouthEast'] := '0x40005' ; AW_SLIDE | AW_VER_POSITIVE | AW_HOR_POSITIVE
        this.mAW['slideSouthWest'] := '0x40006' ; AW_SLIDE | AW_VER_POSITIVE | AW_HOR_NEGATIVE
        this.mAW['rollEast']       := '0x00001' ; AW_HOR_POSITIVE
        this.mAW['rollWest']       := '0x00002' ; AW_HOR_NEGATIVE    
        this.mAW['rollNorth']      := '0x00008' ; AW_VER_NEGATIVE
        this.mAW['rollSouth']      := '0x00004' ; AW_VER_POSITIVE
        this.mAW['rollNorthEast']  := '0x00009' ; ROLL_DIAG_BL_TO_TR
        this.mAW['rollNorthWest']  := '0x0000a' ; ROLL_DIAG_BR_TO_TL 
        this.mAW['rollSouthEast']  := '0x00005' ; ROLL_DIAG_TL_TO_BR 
        this.mAW['rollSouthWest']  := '0x00006' ; ROLL_DIAG_TR_TO_BL                 
    }

    ;============================================================================================

    Static _Show(title:='', msg:='', icon:='', sound:='', callback:='', options:='') 
    {       
        Critical
        
        static gLastPosYbr := 0, gLastPosYbc := 0, gLastPosYbL := 0, gLastPosYtL := 10, gLastPosYtc := 10, gLastPosYtr := 10, gLastPosYct := ''
        static paddingX := 15, paddingY := 10, paddingYb := 75, paddingXpicTxt := 10
        static gIndex := 0

        m := Map(), m.CaseSense := 'off'      
        
        while RegExMatch(Trim(options), 'i)(\w+)=((?:.*?)(?=\s+\w+=|$))', &match, IsSet(match) ? match.Pos + match.Len : 1)
            m[Trim(match[1])] := Trim(match[2])

        Switch {
            case (m.has('iw') && !m.has('ih')): m['ih'] := m['iw']
            case (m.has('ih') && !m.has('iw')): m['iw'] := m['ih']
        }

        for value in ['pos', 'dur', 'iw', 'ih', 'tf', 'ts', 'tc', 'mf', 'ms', 'mc', 'ali', 'bc', 'style', 'dg', 'opt', 'bdr']
            if !m.has(value)
                m[value] := this.mDefault[value]

        for value in ['show', 'hide'] 
        {          
            if (m.has(value)) {
                p := StrSplit(m[value], '@')
                m[value 'Hex'] := this.mAW[p[1]]
                m[value 'Dur'] := (p.Length > 1) ? Min(2500, Max(25, Format("{:d}", p[2]))): this.mDefault[value 'Dur']
            }

            if !m.has(value 'Dur')
                m[value 'Dur'] := this.mDefault[value 'Dur']
        }

        if !RegExMatch(m['style'], 'i)(round|edge)$')
            m['style'] := this.mDefault['style']        

        ;==============================================
 
        Switch m['style'], 'off' {
            case 'edge':
            {
                if !m.has('showHex')
                    m['showHex'] := this.mAW['fade']

                if !m.has('hideHex') {
                    Switch m['pos'], 'off' {
                        case 'br', 'tr': m['hideHex'] := this.mAW['slideEast']
                        case 'bl', 'tl': m['hideHex'] := this.mAW['slideWest']
                        case 'bc': m['hideHex'] := this.mAW['slideSouth']
                        case 'tc': m['hideHex'] := this.mAW['slideNorth']
                        case 'ct': m['hideHex'] := this.mAW['fade']
                    }
                }
            }

            case 'round': 
            {
                if !m.has('showHex')
                    m['showHex'] := this.mAW['fade']
                
                if !m.has('hideHex')
                    m['hideHex'] := this.mAW['fade']
            }
        }

        ;==============================================     
        
        switch m['dg'] {
            case 2: this.DestroyAllAtPosition(m['pos'], '_Show')
            case 3: this.DestroyAll('_Show')
        }
       
        g := Gui(m['opt'], gTitle := 'NotifyGUI_' m['pos'])
        gIndex++
        g.gIndex := gIndex        
        g.BackColor := m['bc']
        g.MarginY := 15
        g.MarginX := 15
        g.pos := m['pos']
        g.style := m['style']
        g.hideHex :=  m['hideHex']
        g.hideDur := m['hideDur']
        m['hwnd'] := g.hwnd

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

        if g.HasOwnProp('pic')
            gPicWidth := this.ControlGetPicWidth(g.pic) + paddingXpicTxt + g.MarginX*2

        visibleScreenWidth := A_ScreenWidth / (A_ScreenDPI / 95) - paddingX*2

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
            g.Add('Text', m['ali'] (!title && IsSet(gPicWidth) ? ' x+' paddingXpicTxt : '') (IsSet(msgWidth) ? ' w' msgWidth : ''), msg)
        }

        g.MarginY := 15
        g.Show('Hide')
        WinGetPos(&gX, &gY, &gW, &gH, g)
        clickArea := g.Add('Text', 'x0 y0 w' gW ' h' gH ' BackgroundTrans')
        
        if callback
            clickArea.OnEvent('Click', callback)
        
        clickArea.OnEvent('Click', this.gDestroy.Bind(this, g, 'clickArea'))
        g.boundFuncTimer := this.gDestroy.Bind(this, g, 'timer')

        if m['dur']
            SetTimer(g.boundFuncTimer, -(m['dur']*1000 + m['showDur']))
        
        if sound
            this.Sound(sound)
        
        ;==============================================
        
        Switch m['pos'], 'off' {
            case 'br': 
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYbr := 0
         
                if gLastPosYbr < gH + paddingY
                    gPos := 'x' A_ScreenWidth - gW - paddingX ' y' (gLastPosYbr := A_ScreenHeight - gH - paddingYb)
                else
                    gPos := 'x' A_ScreenWidth - gW - paddingX ' y' (gLastPosYbr := gLastPosYbr - gH - paddingY)
            }

            case 'bc':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYbc := 0

                if gLastPosYbc < gH + paddingY 
                    gPos := 'x' A_ScreenWidth/2 - gW/2 ' y' (gLastPosYbc := A_ScreenHeight - gH - paddingYb)            
                else
                    gPos := 'x' A_ScreenWidth/2 - gW/2 ' y' (gLastPosYbc := gLastPosYbc - gH - paddingY)
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

                if (gLastPosYtL = paddingY || (gLastPosYtL + gH + paddingY) > A_ScreenHeight - paddingYb)
                    gPos := 'x' paddingX ' y' paddingY, gLastPosYtL := paddingY + gH
                else
                    gPos := 'x' paddingX ' y' gLastPosYtL + paddingY, (gLastPosYtL := gLastPosYtL + paddingY + gH)
            }     
            
            case 'tc': 
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYtc := paddingY

                if (gLastPosYtc = paddingY || (gLastPosYtc + gH + paddingY) > A_ScreenHeight - paddingYb)
                    gPos := 'x' A_ScreenWidth/2 - gW/2 ' y' paddingY, gLastPosYtc := paddingY + gH
                else
                    gPos := 'x' A_ScreenWidth/2 - gW/2 ' y' gLastPosYtc + paddingY, (gLastPosYtc := gLastPosYtc + paddingY + gH)
            }  
            
            case 'tr': 
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYtr := paddingY

                if (gLastPosYtr = paddingY || (gLastPosYtr + gH + paddingY) > A_ScreenHeight - paddingYb)
                    gPos := 'x' A_ScreenWidth - gW - paddingX ' y' paddingY, gLastPosYtr := paddingY + gH
                else
                    gPos := 'x' A_ScreenWidth - gW - paddingX ' y' gLastPosYtr + paddingY, (gLastPosYtr := gLastPosYtr + paddingY + gH)
            }             
        
            case 'ct':
            {
                if !this.mNotifyGUIs[m['pos']].Count
                    gLastPosYct := ''

                if (!gLastPosYct || (gLastPosYct + gH + paddingY + paddingYb) > A_ScreenHeight)
                    gPos := '', gLastPosYct := gY + gH
                else
                    gPos := 'y' gLastPosYct + paddingY, (gLastPosYct := gLastPosYct + paddingY + gH)
            }          
        }

        Switch m['style'], 'off' {
            case 'round': this.FrameShadow(g.hwnd)
            case 'edge': m['bdr'] ? g.Opt('+Border'): ''
        }

        this.mNotifyGUIs[m['pos']][gIndex] := g
        g.Show(gPos ' NoActivate Hide')
        DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', m['showDur'], 'Int', m['showHex'])              
        Critical('Off')
        return m['hwnd']
    }

    ;============================================================================================

    static gDestroy(g, fromMethod:='', *)
    {
        if RegExMatch(fromMethod,'^(clickArea|timer)$')
            Critical

        SetTimer(g.boundFuncTimer, 0)
        DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', g.hideDur, 'Int', Format("{:#X}", g.hideHex + 0x10000))
        g.Destroy()

        if this.mNotifyGUIs[g.pos].Has(g.gIndex)
            this.mNotifyGUIs[g.pos].Delete(g.gIndex)
        
        if RegExMatch(fromMethod,'^(clickArea|timer)$')
            Critical('Off')
    }

    ;============================================================================================
    ; Destroy the currently existing GUIs at the position parameter.
    static DestroyAllAtPosition(position, fromMethod:='')
    {
        if fromMethod != '_Show'
            Critical

        for gIndex, _ in this.mNotifyGUIs[position].Clone()
            if this.mNotifyGUIs[position].Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[position][gIndex], 'DestroyAllAtPosition')

        tmmPrev := A_TitleMatchMode
        SetTitleMatchMode('RegEx')         
          
        for id in WinGetList('i)NotifyGUI_' position ' ahk_class AutoHotkeyGUI')
            try WinClose('ahk_id ' id)

        SetTitleMatchMode(tmmPrev)

        if fromMethod != '_Show'
            Critical('Off')        
    }

    ;============================================================================================    
    ; Destroy the currently existing GUIs at all positions.
    static DestroyAll(fromMethod:='')
    {       
        if fromMethod != '_Show'
            Critical

        for position in this.aPosition                 
            for gIndex, _ in this.mNotifyGUIs[position].Clone()
                if this.mNotifyGUIs[position].Has(gIndex)
                    this.gDestroy(this.mNotifyGUIs[position][gIndex], 'DestroyAll')

        tmmPrev := A_TitleMatchMode
        SetTitleMatchMode('RegEx')        

        for id in WinGetList('i)NotifyGUI_ ahk_class AutoHotkeyGUI')
            try WinClose('ahk_id ' id)

        SetTitleMatchMode(tmmPrev)

        if fromMethod != '_Show'
            Critical('Off')    
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

    static gSnd_ddl_CtrlChange(*) => SetTimer( this.Sound.Bind(this, this.gSnd.ddl.Text) , -1)   

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

    ;============================================================================================
    ; FrameShadow by Klark92.  https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117&hilit=FrameShadow
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
}
