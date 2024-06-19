/**********************************************
* @description Notify - This class makes it easier to create and display notification GUIs.
* @author XMCQCX
* @date 2024/06/19
* @version 1.4.2
* @see {@link https://github.com/XMCQCX/Notify_Class Notify_Class - GitHub} | {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=129635 Notify_Class - AHK Forum}
* @credits
* - Notify by gwarble. {@link https://www.autohotkey.com/board/topic/44870-notify-multiple-easy-tray-area-notifications-v04991/ source}
* - Notify Class v2 by the-Automator. {@link https://www.the-automator.com/downloads/maestrith-notify-class-v2/ source}
* - FrameShadow by Klark92. {@link https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117&hilit=FrameShadow source}
* - WiseGui by SKAN. {@link https://www.autohotkey.com/boards/viewtopic.php?t=94044 source}
* @features
* - Change text, font, color, image, animation.
* - Rounded or edged corners.
* - Position at different locations on the screen.
* - Multi-Monitor support.
* - Multi-Script support. Finds all GUIs from all scripts and positions them accordingly.
* - Play a sound when it appears.
* - Call a function when clicking on it.
* @methods
* - Show - Builds and shows a notification GUI.
* - SoundsList() - Lists and plays all available sounds.
* - MonitorGetInfo() - Displays information about the monitors connected to the system.
* - Destroy(hwnd) - Destroys the GUI.
* - DestroyAllOnMonitorAtPosition(monitorNumber, position) - Destroy all GUIs on a specific monitor at a specific position.
* - DestroyAllOnAllMonitorAtPosition(position) - Destroys all GUIs on all monitors at a specific position.
* - DestroyAllOnMonitor(monitorNumber) - Destroys all GUIs on a specific monitor.
* - DestroyAll() - Destroys all GUIs.
* @example
* #include <v2\Notify\Notify>
* Notify.MonitorGetInfo()
* Notify.Show('The quick brown fox jumps over the lazy dog.',,,,, 'dur=4 pos=tc')
* Notify.Show('Alert!', 'You are being warned.', 'icon!',,, 'TC=black MC=black BC=DCCC75')
* Notify.Show('Error', 'Something has gone wrong!', 'iconx', 'soundx',, 'BC=C72424 style=edge show=expand hide=expand')
* Notify.Show('Info', 'Some information to show.', 'iconi',,, 'TC=black MC=black BC=75AEDC style=edge show=slideWest@250 hide=slideEast@250')
**********************************************/
Class Notify {
/*
   ***MORE EXAMPLES***
;=======================
*Destroy a specific GUI.*

mNotifyGUI := Notify.Show('The quick brown fox jumps over the lazy dog.',,,,, 'dur=0 pos=tc')
F1::Notify.Destroy(mNotifyGUI['hwnd'])

;=======================
*Modify the icon and text upon left-clicking the GUI using a callback.*

mNotifyGUI := Notify.Show('Title value 0', 'Message value 0', A_WinDir '\system32\user32.dll|Icon5',, NotifyGUICallback, 'dur=0 dgc=0')

NotifyGUICallback(*)
{
    mNotifyGUI['pic'].Value := A_WinDir '\system32\user32.dll'

    Loop 3 {
        mNotifyGUI['title'].Text := 'Title value ' A_Index
        mNotifyGUI['msg'].Text := 'Message value ' A_Index      
        Sleep(2000)
    }

    Sleep(3000)
    Notify.Destroy(mNotifyGUI['hwnd'])
}

*/
/**********************************************
* @method Show(title, msg, icon, sound, callback, options)
* @description Builds and shows a notification GUI.    
* @param title Title
* @param msg Message
* @param icon {@link https://www.autohotkey.com/docs/v2/lib/GuiControls.htm#Picture Picture GuiControls}
* - The path of an icon/picture. See the link above for supported file types.
* - String: 'icon!', 'icon?', 'iconx', 'iconi'
* - Icon from dll: A_WinDir '\system32\user32.dll|Icon4'
* @param sound {@link https://www.autohotkey.com/docs/v2/lib/SoundPlay.htm SoundPlay function}
* - The path of the WAV file to be played.
* - String: 'soundx', 'soundi'
* - Filename of WAV file located in "C:\Windows\Media" and "Music\Sounds": 'Ding', 'tada', 'Windows Error', etc.
* - Call `Notify.SoundsList()` to list and hear all the available sounds.
* @param callback Function object to call when left-clicking on the GUI. {@link https://www.autohotkey.com/docs/v2/misc/Functor.htm Function Objects}
* @param options For example: `'POS=TL DUR=6 IW=70 TF=Impact TS=42 TC=GREEN MC=blue BC=Silver STYLE=edge SHOW=Fade Hide=Fade@250'`
* - The string is case-insensitive.
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
* - `MON` - Monitor number to display the GUI. Call `Notify.MonitorGetInfo()` to show the monitor numbers. AutoHotkey displays different monitor numbers than Windows System Display/NVIDIA Control Panel.
* - `IW` - Image width - `*32` If only one dimension (width or height) is specified, the other dimension will automatically be set to the same value.
* - `IH` - Image height `*32`
* - `TF` - Title font `*Segoe UI bold`
* - `TFO` - Title font options. For example: `tfo=underline italic strike`
* - `TS` - Title size `*15`
* - `TC` - Title color `*White`
* - `TALI` - Title alignment
*   - `LEFT`* 
*   - `RIGHT`
*   - `CENTER`
* - `MF` - Message font `*Segoe UI`
* - `MFO` - Message font options. For example: `mfo=underline italic strike`
* - `MS` - Message size `*12`
* - `MC` - Message color `*White`
* - `MALI` - Message alignment
*   - `LEFT`* 
*   - `RIGHT`
*   - `CENTER`
* - `BC` - Background color `*1F1F1F`
* - `STYLE` - Notification style
*   - `ROUND` - Rounded corners*
*   - `EDGE` - Edged corners
* - `BDR` - Border. Not compatible with the round style.
*   - `0` - No border
*   - `1` - Border*
* - `WSTC` - WinSetTransColor. Not compatible with the round style.
* - `WSTP` - WinSetTransparent. Not compatible with the round style.
* - `PADX` - The space between the left or right edge of the GUI and the edge of the screen. Can range from 0 to 25.
* - `PADY` - The space between the top or bottom edge of the first GUI created at a position and the edge of the screen. Can range from 0 to 25.
* - `SHOW` and `HIDE` - Animation when showing and hiding the GUI. The duration, which is optional, can range from 1 to 2500 milliseconds. For example: `'STYLE=EDGE SHOW=SLIDEWEST HIDE=SLIDEEAST@500'`
* - THE ROUND STYLE IS NOT COMPATIBLE WITH MOST ANIMATIONS! The round style renders only the fade-in (SHOW=Fade) animation correctly. The corners become edged during the fade-out if (HIDE=Fade) is used.
*   - `0` - No animation.
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
* - `DGC` - Destroy GUI click. Allow or prevent the GUI from being destroyed when clicked.
*   - `0` - Clicking on the GUI does not destroy it.   
*   - `1` - Clicking on the GUI destroys it.*
* - `DG` - Destroy GUIs before creating the new GUI.
*   - `0` - Do not destroy GUIs.*
*   - `1` - Destroy all GUIs on the monitor option at the position option.
*   - `2` - Destroy all GUIs on all monitors at the position option.
*   - `3` - Destroy all GUIs on the monitor option.
*   - `4` - Destroy all GUIs.
* - `DGA` - Enable or disable HIDE animation when using methods that begin with "Destroy". Destroy(hwnd), DestroyAll() etc.
*   - `0` - Disable* 
*   - `1` - Enable
* - `OPT` - Sets various options and styles for the appearance and behavior of the window. `*+Owner -Caption +AlwaysOnTop` {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Opt GUI Opt}    
* @returns Map object
**********************************************/
    static Show(title:='', msg:='', icon:='', sound:='', callback:='', options:='') => this._Show(title, msg, icon, sound, callback, options)

    ;============================================================================================
    
    static __New()
    {
        this.mDefault := Map(), this.mDefault.CaseSense := 'off'
        this.mDefault['pos'] := 'br'           ; Position
        this.mDefault['dur'] := 8              ; Duration    
        this.mDefault['iw'] := 32              ; Image width
        this.mDefault['ih'] := 32              ; Image height
        this.mDefault['tf'] := 'Segoe UI bold' ; Title font
        this.mDefault['tfo'] := ''             ; Title font options.
        this.mDefault['ts'] := 15              ; Title size
        this.mDefault['tali'] := 'left'        ; Title alignment
        this.mDefault['tc'] := 'white'         ; Title color
        this.mDefault['mf'] := 'Segoe UI'      ; Message font
        this.mDefault['mfo'] := ''             ; Message font options.
        this.mDefault['ms'] := 12              ; Message size
        this.mDefault['mc'] := 'white'         ; Message color
        this.mDefault['mali'] := 'left'        ; Message alignment
        this.mDefault['bc'] := '1F1F1F'        ; Background color
        this.mDefault['style'] := 'round'      ; Style
        this.mDefault['dg'] := 0               ; Destroy GUIs
        this.mDefault['dga'] := 0              ; Enable or disable HIDE animation.
        this.mDefault['dgc'] := 1              ; OnEvent click
        this.mDefault['bdr'] := 1              ; Border    
        this.mDefault['wstc'] := ''            ; WinSetTransColor 
        this.mDefault['wstp'] := ''            ; WinSetTransparent    
        this.mDefault['mon'] := MonitorGetPrimary() ; Monitor number to display the GUI.
        this.mDefault['opt'] := '+Owner -Caption +AlwaysOnTop' ; GUI options

        this.mNotifyGUIs := Map(), this.mNotifyGUIs.CaseSense := 'off'
        this.aPosition := ['br', 'bc', 'bl', 'tl', 'tc', 'tr', 'ct']
        this.maxMonCount := 0

        this.pathSoundsFolder := RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'My Music') '\Sounds'
        this.mSounds := Map(), this.mSounds.CaseSense := 'off'
        this.mSounds['soundx'] := '*16'
        this.mSounds['soundi'] := '*64'

        for _, path in [A_WinDir '\Media', this.pathSoundsFolder]
            Loop Files path '\*.wav'
                SplitPath(A_LoopFilePath,,,, &fileName), this.mSounds[fileName] := A_LoopFilePath

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
        this.mAW['0']              := 0         ; No animation
        this.mAW['fade']           := '0x80000' ; AW_BLEND
        this.mAW['expand']         := '0x00010' ; AW_CENTER
        this.mAW['slideEast']      := '0x40001' ; AW_SLIDE | AW_HOR_POSITIVE
        this.mAW['slideWest']      := '0x40002' ; AW_SLIDE | AW_HOR_NEGATIVE
        this.mAW['slideNorth']     := '0x40008' ; AW_SLIDE | AW_VER_NEGATIVE
        this.mAW['slideSouth']     := '0x40004' ; AW_SLIDE | AW_VER_POSITIVE
        this.mAW['slideNorthEast'] := '0x40009' ; AW_SLIDE | AW_VER_NEGATIVE | AW_HOR_POSITIVE
        this.mAW['slideNorthWest'] := '0x4000A' ; AW_SLIDE | AW_VER_NEGATIVE | AW_HOR_NEGATIVE
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

    static _Show(title:='', msg:='', icon:='', sound:='', callback:='', options:='') 
    {       
        Critical        
        static gIndex := 0, paddingY := 10, paddingXpicTxt := 10
        m := Map(), m.CaseSense := 'off'      
        
        while RegExMatch(Trim(options), 'i)(\w+)=(.*?(?=\s+\w+=|$))', &match, IsSet(match) ? match.Pos + match.Len : 1)
            m[Trim(match[1])] := Trim(match[2])

        Switch {
            case (m.has('iw') && !m.has('ih')) : m['ih'] := m['iw']
            case (m.has('ih') && !m.has('iw')) : m['iw'] := m['ih']
        }

        for value in ['pos', 'mon', 'dur', 'iw', 'ih', 'tf', 'tfo', 'ts', 'tc', 'tali', 'mf', 'mfo', 'ms', 'mc', 'mali', 'bc', 'style', 'dg', 'dgc', 'bdr', 'opt', 'wstc', 'wstp', 'dga']
            if !m.has(value)
                m[value] := this.mDefault[value]

        for value in ['show', 'hide'] {          
            if (m.has(value)) {
                p := StrSplit(m[value], '@')
                m[value 'Hex'] := this.mAW[p[1]]
                (p.Length > 1) ? m[value 'Dur'] := Min(2500, Max(1, Format("{:d}", p[2]))) : ''
            }
        }

        m['mon'] := Integer(m['mon'])
        monCount := MonitorGetCount()
        this.maxMonCount := Max(this.maxMonCount, monCount)

        if !(m['mon'] >= 1 && m['mon'] <= monCount)
            m['mon'] := MonitorGetPrimary()

        ;==============================================

        if !RegExMatch(m['style'], 'i)(round|edge)$')
            m['style'] := this.mDefault['style']         
 
        switch m['style'], 'off' {
            case 'edge':
            {
                if !m.has('showHex') {
                    Switch m['pos'], 'off' {
                        case 'br', 'tr': m['showHex'] := this.mAW['slideWest']
                        case 'bl', 'tl': m['showHex'] := this.mAW['slideEast']
                        case 'bc': m['showHex'] := this.mAW['slideNorth']
                        case 'tc': m['showHex'] := this.mAW['slideSouth']
                        case 'ct': m['showHex'] := this.mAW['0']
                    }
                }

                if !m.has('hideHex') {
                    Switch m['pos'], 'off' {
                        case 'br', 'tr': m['hideHex'] := this.mAW['slideEast']
                        case 'bl', 'tl': m['hideHex'] := this.mAW['slideWest']
                        case 'bc': m['hideHex'] := this.mAW['slideSouth']
                        case 'tc': m['hideHex'] := this.mAW['slideNorth']
                        case 'ct': m['hideHex'] := this.mAW['0']
                    }
                }
                                  
                (!m.has('showDur')) ? m['showDur'] := 75 : '' 
                (!m.has('hideDur')) ? m['hideDur'] := 100 : '' 
                (!m.has('padX')) || !(m['padX'] >= 0 && m['padX'] <= 25) ? m['padX'] := 0 : ''  
                (!m.has('padY')) || !(m['padY'] >= 0 && m['padY'] <= 25) ? m['padY'] := 0 : ''                                   
            }

            case 'round': 
            {
                (!m.has('showHex')) ? m['showHex'] := this.mAW['fade'] : ''                              
                (!m.has('hideHex')) ? m['hideHex'] := this.mAW['0'] : ''
                (!m.has('showDur')) ? m['showDur'] := 1 : ''
                (!m.has('hideDur')) ? m['hideDur'] := 0 : ''                
                (!m.has('padX') || !(m['padX'] >= 0 && m['padX'] <= 25)) ? m['padX'] := 10 : '' 
                (!m.has('padY') || !(m['padY'] >= 0 && m['padY'] <= 25)) ? m['padY'] := 10 : ''                 
            }
        }

        ;==============================================  
        
        Loop monCount {
            monNum := A_Index
            if (!this.mNotifyGUIs.Has(monNum)) {
                this.mNotifyGUIs[monNum] := Map(), this.mNotifyGUIs[monNum].CaseSense := 'off'                               
                
                for position in this.aPosition
                    this.mNotifyGUIs[monNum][position] := Map(), this.mNotifyGUIs[monNum][position].CaseSense := 'off'   
            }                
        }

        switch m['dg'] {
            case 1: this.DestroyAllOnMonitorAtPosition(m['mon'], m['pos'], '_Show')
            case 2: this.DestroyAllOnAllMonitorAtPosition(m['pos'], '_Show')
            case 3: this.DestroyAllOnMonitor(m['mon'], '_Show')
            case 4: this.DestroyAll('_Show')
        }

        ;==============================================
       
        g := Gui(m['opt'], 'NotifyGUI_' m['mon'] '_' m['pos'])    
        g.BackColor := m['bc']
        g.MarginY := 15
        g.MarginX := 15
        gIndex++
        g.gIndex := gIndex
        m['hwnd'] := g.hwnd
        
        for value in ['pos', 'mon', 'hideHex', 'hideDur', 'dga']
            g.%value% := m[value]
            
        ;==============================================          

        switch {
            case FileExist(icon) || RegExMatch(icon, 'i)h(icon|bitmap).*\d+'):  
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'], icon)
                    
            case RegExMatch(icon, 'i)^(icon!|icon\?|iconx|iconi)$'):           
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'] ' Icon' this.mIconsUser32[icon], A_WinDir '\system32\user32.dll')

            case RegExMatch(icon, 'i)(.+?\.(?:dll|exe))\|icon(\d+)', &match) && FileExist(match[1]):
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'] ' Icon' match[2], match[1])
        }

        ;============================================== 

        MonitorGetWorkArea(m['mon'], &monWALeft, &monWATop, &monWARight, &monWABottom)
        monWAwidth := Abs(monWARight - monWALeft)
        monWAheight := Abs(monWABottom - monWATop)
        visibleScreenWidth := monWAwidth / (A_ScreenDPI / 94) - m['padX']*2
        
        if m.Has('pic')
            gPicWidth := this.ControlGetPicWidth(m['pic'], monWALeft, monWATop) + paddingXpicTxt + g.MarginX*2

        if title
            titleCtrlW := this.ControlGetTextWidth(title, m['tf'], m['ts'], monWALeft, monWATop)

        if msg
            msgCtrlW := this.ControlGetTextWidth(msg, m['mf'], m['ms'], monWALeft, monWATop)

        if title && (titleCtrlW + (IsSet(gPicWidth) ? gPicWidth : 0)) > (visibleScreenWidth)           
            titleWidth := visibleScreenWidth - (IsSet(gPicWidth) ? gPicWidth : 0)

        if msg && (msgCtrlW + (IsSet(gPicWidth) ? gPicWidth : 0)) > (visibleScreenWidth) 
            msgWidth := visibleScreenWidth - (IsSet(gPicWidth) ? gPicWidth : 0)

        if (title && msg) ; related to alignment options.
            titleWidth := msgWidth := Max( IsSet(titleWidth) ? titleWidth : titleCtrlW,  IsSet(msgWidth) ? msgWidth : msgCtrlW )

        ;==============================================        
        
        if (title) {
            g.SetFont('s' m['ts'] ' c' m['tc'] ' ' m['tfo'], m['tf'])
            m['title'] := g.Add('Text', m['tali'] (IsSet(gPicWidth) ? ' x+' paddingXpicTxt : '') (IsSet(titleWidth) ? ' w' titleWidth : ''), title)                     
            
            if m['tfo']
                g.SetFont()
        }

        if (msg) {
            if title
                g.MarginY := 6            

            g.SetFont('s' m['ms'] ' c' m['mc'] ' ' m['mfo'], m['mf'])
            m['msg'] := g.Add('Text', m['mali'] (!title && IsSet(gPicWidth) ? ' x+' paddingXpicTxt : '') (IsSet(msgWidth) ? ' w' msgWidth : ''), msg)
        }

        g.MarginY := 15
        g.Show('Hide')
        WinGetPos(&gX, &gY, &gW, &gH, g)
        clickArea := g.Add('Text', 'x0 y0 w' gW ' h' gH ' BackgroundTrans')
                
        if callback
            clickArea.OnEvent('Click', callback)
        
        if (m['dgc'])
            clickArea.OnEvent('Click', this.gDestroy.Bind(this, g, 'clickArea'))

        g.OnEvent('Close', this.gDestroy.Bind(this, g, 'close'))
        g.boundFuncTimer := this.gDestroy.Bind(this, g, 'timer')

        if m['dur']
            SetTimer(g.boundFuncTimer, -(m['dur']*1000 + m['showDur']))
        
        if sound
            this.Sound(sound)
        
        ;==============================================
        ; For placement, find all GUIs from all scripts. Find the highest or lowest depending on the position option.
        Switch m['pos'], 'off' {
            case 'br', 'bc', 'bl': minMaxPosY := monWABottom              
            case 'tr', 'tc', 'tl', 'ct': minMaxPosY := monWATop  
        }

	dhwPrev := A_DetectHiddenWindows
	tmmPrev := A_TitleMatchMode
	DetectHiddenWindows(0)
	SetTitleMatchMode('RegEx')   

	for id in WinGetList('i)^NotifyGUI_' m['mon'] '_' m['pos'] ' ahk_class AutoHotkeyGUI') {            
		WinGetPos(&guiX, &guiY, &guiW, &guiH, 'ahk_id ' id)
		switch m['pos'], 'off' {
			case 'br', 'bc', 'bl': minMaxPosY := Min(minMaxPosY, guiY)               
			case 'tr', 'tc', 'tl', 'ct': minMaxPosY := Max(minMaxPosY, guiY + guiH)
		}
	}

	DetectHiddenWindows(dhwPrev)
	SetTitleMatchMode(tmmPrev)

        switch m['pos'], 'off' {
            case 'br':
            {           
                if minMaxPosY = monWABottom || minMaxPosY <= (monWATop + gH + paddingY)
                    gPos := 'x' monWARight - gW - m['padX'] ' y' monWABottom - gH - m['padY']
                else 
                    gPos := 'x' monWARight - gW - m['padX'] ' y' minMaxPosY - gH - paddingY
            }
            case 'bc':
            {
                if minMaxPosY = monWABottom || minMaxPosY <= (monWATop + gH + paddingY)
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y'  monWABottom - gH - m['padY']         
                else
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' minMaxPosY - gH - paddingY
            }
            case 'bl': 
            {
                if minMaxPosY = monWABottom || minMaxPosY <= (monWATop + gH + paddingY)
                    gPos := 'x' monWALeft + m['padX'] ' y' monWABottom - gH - m['padY']
                else 
                    gPos := 'x' monWALeft + m['padX'] ' y' minMaxPosY - gH - paddingY  
            }          
            case 'tl': 
            {
                if minMaxPosY = monWATop || minMaxPosY >= (monWABottom - gH - paddingY)
                    gPos := 'x' monWALeft + m['padX'] ' y' monWATop + m['padY']
                else
                    gPos := 'x' monWALeft + m['padX'] ' y' minMaxPosY + paddingY  
            }              
            case 'tc': 
            {
                if minMaxPosY = monWATop || minMaxPosY >= (monWABottom - gH - paddingY)
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' monWATop + m['padY']
                else
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' minMaxPosY + paddingY   
            }          
            case 'tr': 
            {
                if minMaxPosY = monWATop || minMaxPosY >= (monWABottom - gH - paddingY)
                    gPos := 'x' monWARight - m['padX'] - gW ' y' monWATop + m['padY']
                else
                    gPos := 'x' monWARight - m['padX'] - gW ' y' minMaxPosY + paddingY 
            }              
            case 'ct':
            {
                if minMaxPosY = monWATop || minMaxPosY >= (monWABottom - gH - paddingY)
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' monWATop + (monWAheight/2 - gH/2)
                else
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' minMaxPosY + paddingY
            }
        }

        ;==============================================
        
        this.mNotifyGUIs[m['mon']][m['pos']][gIndex] := g
        
        Switch m['style'], 'off' {
            case 'round': this.FrameShadow(g.hwnd)
            case 'edge': m['bdr'] ? g.Opt('+Border'): ''
        }
                                     
        If m['wstp']
            WinSetTransparent(m['wstp'], g)

        If m['wstc']
            WinSetTransColor(m['wstc'], g)

        if m['showHex']
            g.Show(gPos ' NoActivate Hide'), DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', m['showDur'], 'Int', m['showHex'])  
        else
            g.Show(gPos ' NoActivate')
                                   
        Critical('Off')
        return m
    }

    ;============================================================================================

    static gDestroy(g, fromMethod:='', *)
    {
        if RegExMatch(fromMethod, '^(clickArea|timer|close)$')
            Critical

        if RegExMatch(fromMethod, '^(DestroyAll|close)') && !g.dga
            g.hideHex := 0

        SetTimer(g.boundFuncTimer, 0)

        if g.hideHex
            DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', g.hideDur, 'Int', Format("{:#X}", g.hideHex + 0x10000))
              
        g.Destroy()

        if this.mNotifyGUIs[g.mon][g.pos].Has(g.gIndex)
            this.mNotifyGUIs[g.mon][g.pos].Delete(g.gIndex)
        
        if RegExMatch(fromMethod, '^(clickArea|timer|close)$')
            Critical('Off')
    }

    ;============================================================================================

    static Destroy(hwnd)
    {
        try WinClose('ahk_id ' hwnd)
    }

    ;============================================================================================

    static DestroyAllOnMonitorAtPosition(monNum, position, fromMethod:='')
    {                         
        if fromMethod !== '_Show' 
            Critical

        for gIndex, _ in this.mNotifyGUIs[monNum][position].Clone()
            if this.mNotifyGUIs[monNum][position].Has(gIndex) 
                this.gDestroy(this.mNotifyGUIs[monNum][position][gIndex], 'DestroyAllOnMonitorAtPosition')         

        tmmPrev := A_TitleMatchMode
        SetTitleMatchMode('RegEx')
        SetWinDelay(1)         
                 
        for id in WinGetList('i)^NotifyGUI_' monNum '_' position ' ahk_class AutoHotkeyGUI')
            try WinClose('ahk_id ' id)

        SetTitleMatchMode(tmmPrev)

        if fromMethod !== '_Show' 
            Critical('Off')        
    }

    ;============================================================================================

    static DestroyAllOnAllMonitorAtPosition(position, fromMethod:='') 
    {
        Loop this.maxMonCount
            this.DestroyAllOnMonitorAtPosition(A_Index, position, fromMethod)
    }    

    ;============================================================================================    

    static DestroyAllOnMonitor(monNum, fromMethod:='')
    {         
        if fromMethod !== '_Show' 
            Critical

        for position in this.aPosition              
            for gIndex, _ in this.mNotifyGUIs[monNum][position].Clone()
                if this.mNotifyGUIs[monNum][position].Has(gIndex) 
                    this.gDestroy(this.mNotifyGUIs[monNum][position][gIndex], 'DestroyAllOnMonitor')        

        tmmPrev := A_TitleMatchMode
        SetTitleMatchMode(1)
        SetWinDelay(1)       

        for id in WinGetList('NotifyGUI_' monNum ' ahk_class AutoHotkeyGUI')
            try WinClose('ahk_id ' id)

        SetTitleMatchMode(tmmPrev)

        if fromMethod !== '_Show' 
            Critical('Off')    
    } 

    ;============================================================================================

    static DestroyAll(fromMethod:='')
    {       
        if fromMethod !== '_Show' 
            Critical

        Loop this.maxMonCount {
            monNum := A_Index

            if !this.mNotifyGUIs.Has(monNum) 
                continue

            for position in this.aPosition                 
                for gIndex, _ in this.mNotifyGUIs[monNum][position].Clone()
                    if this.mNotifyGUIs[monNum][position].Has(gIndex) 
                        this.gDestroy(this.mNotifyGUIs[monNum][position][gIndex], 'DestroyAll')
        }
    
        tmmPrev := A_TitleMatchMode
        SetTitleMatchMode(1)
        SetWinDelay(1)       

        for id in WinGetList('NotifyGUI_ ahk_class AutoHotkeyGUI')
            try WinClose('ahk_id ' id)

        SetTitleMatchMode(tmmPrev)

        if fromMethod !== '_Show' 
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
        static gHwnd := 0

        if WinExist('ahk_id ' gHwnd)
            return     

        this.gSnd := Gui(, 'Notify - Sounds list')
        gHwnd := this.gSnd.hwnd
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
        this._Show('"' A_Clipboard '"', 'Saved to clipboard.', 'iconi',,, 'POS=BC DUR=5 DG=1')
    }

    ;============================================================================================

    static gSnd_ddl_CtrlChange(*) => SetTimer( this.Sound.Bind(this, this.gSnd.ddl.Text) , -1)   

    ;============================================================================================ 
    ; DisplayCheck by the-Automator  https://www.the-automator.com/downloads/maestrith-notify-class-v2/
    static MonitorGetInfo()
    {
        static gHwnd := 0

        if WinExist('ahk_id ' gHwnd)
            return

        monCount := MonitorGetCount()
		monPrimary := MonitorGetPrimary()
		gHwnd := this._Show('Monitor Info', 'Monitor Count: ' monCount '`nPrimary Monitor: ' monPrimary '`nClick here to close all Monitor Info GUIs.',,,
        (*) => this.DestroyAllOnAllMonitorAtPosition('ct'), 'dur=0 pos=ct mali=center tali=center tfo=underline italic tc=00FF46 mc=00FF46 style=edge dga=1 show=expand@125 hide=expand@125')['hwnd']

		Loop monCount {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            MonitorGetWorkArea(A_Index, &monWALeft, &monWATop, &monWARight, &monWABottom)
            this._Show(
                'Monitor:`t#' A_Index, 
                (
                'Name:`t' MonitorGetName(A_Index) '
                Left:`t' monLeft ' (WorkArea: ' monWALeft ')
                Top:`t' monTop ' (WorkArea: ' monWATop ')
                Right:`t' monRight ' (WorkArea: ' monWARight ')
                Bottom:`t' monBottom ' (WorkArea: ' monWABottom ')'
                ),,,, 'dur=0 mon=' A_Index ' pos=ct'   
            )                  
        }
    }

    ;============================================================================================

    static ControlGetTextWidth(str:='', font:='', fontSize:='', monWALeft:='', monWATop:='')
    {
        g := Gui()
        g.SetFont('s' fontSize, font)
        g.txt := g.Add('Text',, str)
        g.Show('x' monWALeft ' y' monWATop ' Hide')
        g.txt.GetPos(,, &ctrlWidth)
        g.Destroy()
        return ctrlWidth
    }      

    ;============================================================================================

    static ControlGetPicWidth(picCtrl, monWALeft:='', monWATop:='')
    {
        g := Gui()
        g.pic := picCtrl
        g.Show('x' monWALeft ' y' monWATop ' Hide')
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
