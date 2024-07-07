/********************************************************************************************
@description Notify - This class makes it easier to create and display notification GUIs.
@author XMCQCX
@date 2024/07/05
@version 1.6.0
@see {@link https://github.com/XMCQCX/Notify_Class Notify_Class - GitHub} | {@link https://www.autohotkey.com/boards/viewtopic.php?f=83&t=129635 Notify_Class - AHK Forum}
@credits
- Notify by gwarble. {@link https://www.autohotkey.com/board/topic/44870-notify-multiple-easy-tray-area-notifications-v04991/ source}
- Notify by the-Automator. {@link https://www.the-automator.com/downloads/maestrith-notify-class-v2/ source}
- FrameShadow by Klark92. {@link https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29117&hilit=FrameShadow source}
- WiseGui by SKAN. {@link https://www.autohotkey.com/boards/viewtopic.php?t=94044 source}
@features
- Change text, font, color, image, animation.
- Rounded or edged corners.
- Position at different locations on the screen.
- Multi-Monitor support.
- Multi-Script support. Finds all GUIs from all scripts and positions them accordingly.
- Play a sound when it appears.
- Call a function when clicking on it.
@methods
- Show - Builds and shows a notification GUI.
- SoundsList() - Lists and plays all available sounds.
- MonitorGetInfo() - Displays information about the monitors connected to the system.
- Exist(tag) - Checks if a GUI with the specified tag exists and returns the unique ID (HWND) of the first matching GUI.
- Destroy(hwnd or tag) - Destroys GUIs. Specifying a tag destroys every GUI containing this tag across all scripts.
- DestroyAllOnMonitorAtPosition(monitorNumber, position) - Destroys all GUIs on a specific monitor at a specific position.
- DestroyAllOnAllMonitorAtPosition(position) - Destroys all GUIs on all monitors at a specific position.
- DestroyAllOnMonitor(monitorNumber) - Destroys all GUIs on a specific monitor.
- DestroyAll() - Destroys all GUIs.
@example
#include <v2\Notify\Notify>
Notify.MonitorGetInfo()
Notify.Show('The quick brown fox jumps over the lazy dog.',,,,, 'dur=4 pos=tc')
Notify.Show('Alert!', 'You are being warned.', 'icon!',,, 'TC=black MC=black BC=DCCC75')
Notify.Show('Error', 'Something has gone wrong!', 'iconx', 'soundx',, 'BC=C72424 style=edge show=expand hide=expand')
Notify.Show('Info', 'Some information to show.', 'iconi',,, 'TC=black MC=black BC=75AEDC style=edge show=slideWest@250 hide=slideEast@250')

; ===== Destroy a specific GUI. =====

mNotifyGUI := Notify.Show('The quick brown fox jumps over the lazy dog.',,,,, 'dur=0 pos=tc')
^F1::Notify.Destroy(mNotifyGUI['hwnd'])

; With the TAG option. It destroys every GUI containing this tag across all scripts.

Notify.Show('Notify Title',,,,, 'dur=0 pos=ct tag=myTAG')
^F2::Notify.Destroy('myTAG')

; ===== Modify the icon and text upon left-clicking the GUI using a callback. =====

mNotifyGUI_CB := Notify.Show('Title value 0', 'Message value 0', A_WinDir '\system32\user32.dll|Icon5',, NotifyGUICallback, 'dur=0 dgc=0')

NotifyGUICallback(*)
{
    mNotifyGUI_CB['pic'].Value := A_WinDir '\system32\user32.dll'

    Loop 3 {
        mNotifyGUI_CB['title'].Text := 'Title value ' A_Index
        mNotifyGUI_CB['msg'].Text := 'Message value ' A_Index      
        Sleep(2000)
    }

    Notify.Destroy(mNotifyGUI_CB['hwnd'])
}

; ===== Progress Bar Example. =====

mNotifyGUI_Prog := Notify.Show('Progress Bar Example',,,,, 'dur=0 prog=w325 dgc=0')

Loop 5 {
    mNotifyGUI_Prog['prog'].Value := A_Index * 20
    Sleep(1000)
}

Notify.Destroy(mNotifyGUI_Prog['hwnd'])

; ===== Lock keys indicators. =====

~*NumLock:: 
~*ScrollLock::
~*Insert::	
{
    Sleep(10)  
	thisHotkey := SubStr(A_ThisHotkey, 3)
	Notify.Destroy(thisHotkey)

	if (GetKeyState(thisHotkey, 'T'))
		Notify.Show(thisHotkey ' ON',,,,, 'pos=bl dur=3 ts=20 tfo=italic bc=00A22B style=edge show=0 dgc=0 tag=' thisHotkey)
	else
		Notify.Show(thisHotkey ' OFF',,,,, 'pos=bl dur=3 ts=20 tfo=italic bc=F09800 style=edge show=0 dgc=0 tag=' thisHotkey) 		
}

~*CapsLock:: 
{
	Sleep(10)
	thisHotkey := SubStr(A_ThisHotkey, 3)
	Notify.Destroy(thisHotkey)

	if (GetKeyState(thisHotkey, 'T'))
		Notify.Show(thisHotkey ' ON',,,,, 'pos=bl dur=0 ts=20 tfo=italic tc=red bc=white dgc=0 tag=' thisHotkey)  
}

********************************************************************************************/
Class Notify {

/********************************************************************************************
@method Show(title, msg, icon, sound, callback, options)
@description Builds and shows a notification GUI.    
@param title Title
@param msg Message
@param icon {@link https://www.autohotkey.com/docs/v2/lib/GuiControls.htm#Picture Picture GuiControls}
- The path of an icon/picture. See the link above for supported file types.
- String: `'icon!'`, `'icon?'`, `'iconx'`, `'iconi'`
- Icon from dll: `A_WinDir '\system32\user32.dll|Icon4'`
@param sound {@link https://www.autohotkey.com/docs/v2/lib/SoundPlay.htm SoundPlay function}
- The path of the WAV file to be played.
- String: `'soundx'`, `'soundi'`
- Filename of WAV file located in "C:\Windows\Media" and "Music\Sounds". For example: `'Ding'`, `'tada'`, `'Windows Error'` etc.
- Call `Notify.SoundsList()` to list and hear all the available sounds.
@param callback Function object to call when left-clicking on the GUI. {@link https://www.autohotkey.com/docs/v2/misc/Functor.htm Function Objects}
@param options For example: `'POS=TL DUR=6 IW=70 TF=Impact TS=42 TC=GREEN MC=blue BC=Silver STYLE=edge SHOW=Fade Hide=Fade@250'`
- The string is case-insensitive.
- The asterisk (*) indicates the default option.
- `POS` - Position
  - `BR` - Bottom right*
  - `BC` - Bottom center
  - `BL` - Bottom left
  - `TL` - Top left
  - `TC` - Top center
  - `TR` - Top right
  - `CT` - Center
- `DUR` - Display duration (in seconds). Set it to 0 to keep it on the screen until left-clicking on the GUI. `*8`
- `MON` - Monitor number to display the GUI. Call `Notify.MonitorGetInfo()` to show the monitor numbers. AutoHotkey displays different monitor numbers than Windows System Display and NVIDIA Control Panel.
- `IW` - Image width - `*32` If only one dimension (width or height) is specified, the other dimension will be automatically set preserving its aspect ratio.
- `IH` - Image height `*32`
- `TF` - Title font `*Segoe UI bold`
- `TFO` - Title font options. For example: `tfo=underline italic strike`
- `TS` - Title size `*15`
- `TC` - Title color `*White`
- `TALI` - Title alignment
  - `LEFT`*
  - `RIGHT`
  - `CENTER`
- `MF` - Message font `*Segoe UI`
- `MFO` - Message font options. For example: `mfo=underline italic strike`
- `MS` - Message size `*12`
- `MC` - Message color `*White`
- `MALI` - Message alignment
  - `LEFT`* 
  - `RIGHT`
  - `CENTER`
- `PROG` - Progress bar. For example: `prog=w325`, `prog=w200 h80 cGreen` {@link https://www.autohotkey.com/docs/v2/lib/GuiControls.htm#Progress Progress Options}
- `BC` - Background color `*1F1F1F`
- `STYLE` - Notification style
  - `ROUND` - Rounded corners*
  - `EDGE` - Edged corners
- `TAG` - Marker to identify a GUI. The Destroy method accepts a handle or a tag, it destroys every GUI containing this tag across all scripts.
- `BDR` - Border. Not compatible with the round style.
  - `0` - No border
  - `1` - Border*
- `WSTC` - WinSetTransColor. Not compatible with the round style, fade animation. For example: `style=edge bdr=0 bc=black WSTC=black` {@link https://www.autohotkey.com/docs/v2/lib/WinSetTransColor.htm WinSetTransColor}
- `WSTP` - WinSetTransparent. Not compatible with the round style, fade animation. For example: `style=edge wstp=120` {@link https://www.autohotkey.com/docs/v2/lib/WinSetTransparent.htm WinSetTransparent} 
- `PADX` - The space between the left or right edge of the GUI and the edge of the screen. Can range from 0 to 25.
- `PADY` - The space between the top or bottom edge of the first GUI created at a position and the edge of the screen. Can range from 0 to 25.
- `SHOW` and `HIDE` - Animation when showing and hiding the GUI. The duration, which is optional, can range from 1 to 2500 milliseconds. For example: `STYLE=EDGE SHOW=SLIDEWEST HIDE=SLIDEEAST@250`
- THE ROUND STYLE IS NOT COMPATIBLE WITH MOST ANIMATIONS! The round style renders only the fade-in (SHOW=Fade@225) animation correctly. The corners become edged during the fade-out if (HIDE=Fade@225) is used.
  - `0` - No animation.
  - `Fade`
  - `Expand`
  - `SlideEast`
  - `SlideWest`
  - `SlideNorth`
  - `SlideSouth`
  - `SlideNorthEast`
  - `SlideNorthWest`
  - `SlideSouthEast`
  - `SlideSouthWest`
  - `RollEast`
  - `RollWest`
  - `RollNorth`
  - `RollSouth`
  - `RollNorthEast`
  - `RollNorthWest`
  - `RollSouthEast`
  - `RollSouthWest`
- `DGC` - Destroy GUI click. Allow or prevent the GUI from being destroyed when clicked.
  - `0` - Clicking on the GUI does not destroy it.   
  - `1` - Clicking on the GUI destroys it.*
- `DG` - Destroy GUIs before creating the new GUI.
  - `0` - Do not destroy GUIs.*
  - `1` - Destroy all GUIs on the monitor option at the position option.
  - `2` - Destroy all GUIs on all monitors at the position option.
  - `3` - Destroy all GUIs on the monitor option.
  - `4` - Destroy all GUIs.
  - `5` - Destroy all GUIs containing the tag. For example: `tag=myTAG dg=5`
- `OPT` - Sets various options and styles for the appearance and behavior of the window. `*+Owner -Caption +AlwaysOnTop` {@link https://www.autohotkey.com/docs/v2/lib/Gui.htm#Opt GUI Opt}    
@returns Map object
********************************************************************************************/
    static Show(title:='', msg:='', icon:='', sound:='', callback:='', options:='') => this._Show(title, msg, icon, sound, callback, options)
    
    static __New()
    {
        this.mNotifyGUIs := Map(), this.mNotifyGUIs.CaseSense := 'off'
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
        this.mDefault['prog'] := ''            ; Progress bar
        this.mDefault['bc'] := '1F1F1F'        ; Background color
        this.mDefault['style'] := 'round'      ; Style
        this.mDefault['tag'] := ''             ; GUI window title identifying marker.
        this.mDefault['dg'] := 0               ; Destroy GUIs.
        this.mDefault['dgc'] := 1              ; Destroy GUI click.
        this.mDefault['bdr'] := 1              ; Border   
        this.mDefault['wstc'] := ''            ; WinSetTransColor 
        this.mDefault['wstp'] := ''            ; WinSetTransparent    
        this.mDefault['mon'] := MonitorGetPrimary() ; Monitor number to display the GUI.
        this.mDefault['opt'] := '+Owner -Caption +AlwaysOnTop' ; GUI options        
        this.padH := 10 ; Space between GUIs

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
        
        this.mIconsUser32 := Map(), this.mIconsUser32.CaseSense := 'off'
        this.mIconsUser32['icon!'] := 2
        this.mIconsUser32['icon?'] := 3
        this.mIconsUser32['iconx'] := 4
        this.mIconsUser32['iconi'] := 5             

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
    }

    ;============================================================================================

    static _Show(title:='', msg:='', icon:='', sound:='', callback:='', options:='') 
    {           
        static gIndex := 0, padXpicTxt := 10

        if !title && !msg && !icon
            return   
        
        m := Map(), m.CaseSense := 'off'

        while RegExMatch(Trim(options), 'i)(\w+)=(.*?(?=\s+\w+=|$))', &match, IsSet(match) ? match.Pos + match.Len : 1)
            m[Trim(match[1])] := Trim(match[2])            

        switch {
            case (m.has('iw') && !m.has('ih')) : m['ih'] := -1
            case (m.has('ih') && !m.has('iw')) : m['iw'] := -1
        }

        for key, value in this.mDefault
            if !m.has(key)
                m[key] := value

        for value in ['show', 'hide'] {          
            if (m.has(value)) {
                p := StrSplit(m[value], '@')
                m[value 'Hex'] := this.mAW[p[1]]
                (p.Length > 1) ? m[value 'Dur'] := Min(2500, Max(1, Format("{:d}", p[2]))) : ''
            }
        }

        m['mon'] := Integer(m['mon'])
        monCount := MonitorGetCount()

        if !(m['mon'] >= 1 && m['mon'] <= monCount)
            m['mon'] := MonitorGetPrimary()

        ;==============================================

        if !RegExMatch(m['style'], 'i)(round|edge)$')
            m['style'] := this.mDefault['style']         
 
        switch m['style'], 'off' {
            case 'edge':
            {
                if !m.has('showHex') {
                    switch m['pos'], 'off' {
                        case 'br', 'tr': m['showHex'] := this.mAW['slideWest']
                        case 'bl', 'tl': m['showHex'] := this.mAW['slideEast']
                        case 'bc': m['showHex'] := this.mAW['slideNorth']
                        case 'tc': m['showHex'] := this.mAW['slideSouth']
                        case 'ct': m['showHex'] := this.mAW['expand']
                    }
                }

                if !m.has('hideHex') {
                    switch m['pos'], 'off' {
                        case 'br', 'tr': m['hideHex'] := this.mAW['slideEast']
                        case 'bl', 'tl': m['hideHex'] := this.mAW['slideWest']
                        case 'bc': m['hideHex'] := this.mAW['slideSouth']
                        case 'tc': m['hideHex'] := this.mAW['slideNorth']
                        case 'ct': m['hideHex'] := this.mAW['expand']
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

        switch m['dg'] {
            case 1: this.DestroyAllOnMonitorAtPosition(m['mon'], m['pos'])
            case 2: this.DestroyAllOnAllMonitorAtPosition(m['pos'])
            case 3: this.DestroyAllOnMonitor(m['mon'])
            case 4: this.DestroyAll()
            case 5: m['tag'] ? this.Destroy(m['tag']) : ''
        }

        ;==============================================
       
        g := Gui(m['opt'], 'NotifyGUI_' m['mon'] '_' m['pos'] '_' m['padY'] (m['tag'] ? '_' m['tag'] : ''))
        g.BackColor := m['bc']
        g.MarginX := 15
        g.MarginY := 15
        g.gIndex := ++gIndex
        m['hwnd'] := g.handle := g.hwnd
     
        for value in ['pos', 'mon', 'hideHex', 'hideDur', 'tag']
            g.%value% := m[value]
            
        ;==============================================          

        switch {
            case FileExist(icon) || RegExMatch(icon, 'i)h(icon|bitmap).*\d+'):  
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'], icon)
                    
            case RegExMatch(icon, 'i)^(icon!|icon\?|iconx|iconi)$'):           
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'] ' Icon' this.mIconsUser32[icon], A_WinDir '\system32\user32.dll')

            case RegExMatch(icon, 'i)(.+?\.(?:dll|exe))\|icon(\d+)', &mth) && FileExist(mth[1]):
                try m['pic'] := g.Add('Picture', 'w' m['iw'] ' h' m['ih'] ' Icon' mth[2], mth[1])
        }

        ;============================================== 

        MonitorGetWorkArea(m['mon'], &monWALeft, &monWATop, &monWARight, &monWABottom)
        monWAwidth := Abs(monWARight - monWALeft)
        monWAheight := Abs(monWABottom - monWATop)
        visibleScreenWidth := monWAwidth / (A_ScreenDPI / 94) - m['padX']*2
       
        if m.Has('pic')
            picWidth := this.ControlGetPicWidth(m['pic'], monWALeft, monWATop) + padXpicTxt + g.MarginX*2   
     
        if title
            titleCtrlW := this.ControlGetTextWidth(title, m['tf'], m['ts'], monWALeft, monWATop)

        if msg
            msgCtrlW := this.ControlGetTextWidth(msg, m['mf'], m['ms'], monWALeft, monWATop)

        if title && (titleCtrlW + (IsSet(picWidth) ? picWidth : 0)) > (visibleScreenWidth)           
            titleWidth := visibleScreenWidth - (IsSet(picWidth) ? picWidth : 0)

        if m['prog'] && RegExMatch(m['prog'], 'i)\bw(\d+)\b', &match_width)
            progUserW := match_width[1]

        if (m['prog'] && IsSet(progUserW)) && ((progUserW + (IsSet(picWidth) ? picWidth : 0)) > (visibleScreenWidth))  
            progWidth := visibleScreenWidth - (IsSet(picWidth) ? picWidth : 0)
      
        if msg && (msgCtrlW + (IsSet(picWidth) ? picWidth : 0)) > (visibleScreenWidth) 
            msgWidth := visibleScreenWidth - (IsSet(picWidth) ? picWidth : 0)

        if (title && msg) || (title && m['prog']) || (msg && m['prog']) {
            titleWidth := msgWidth := progWidth := Max( 
                (title && IsSet(titleWidth) ? titleWidth : IsSet(titleCtrlW) ? titleCtrlW : 0),  
                (msg && IsSet(msgWidth) ? msgWidth : IsSet(msgCtrlW) ? msgCtrlW : 0),  
                (m['prog'] && IsSet(progWidth) ? progWidth : IsSet(progUserW) ? progUserW : 0)
            )           
        }

        ;==============================================        
        
        if (title) {
            g.SetFont('s' m['ts'] ' c' m['tc'] ' ' m['tfo'], m['tf'])
            m['title'] := g.Add('Text', m['tali'] (IsSet(picWidth) ? ' x+' padXpicTxt : '') (IsSet(titleWidth) ? ' w' titleWidth : ''), title)                                     
            m['tfo'] ? g.SetFont() : ''     
        }

        if (m['prog']) {
            m['prog'] = 1 ? m['prog'] := '' : ''                 
            m['prog'] := g.Add('Progress', (!title && IsSet(picWidth) ? ' x+' padXpicTxt : '') ' ' m['prog'] (!IsSet(progWidth) || (IsSet(progUserW) && (progUserW < progWidth)) ? '':  ' w' progWidth))
        }

        if (msg) {
            title ? g.MarginY := 6 : ''               
            g.SetFont('s' m['ms'] ' c' m['mc'] ' ' m['mfo'], m['mf'])
            m['msg'] := g.Add('Text', m['mali'] ((!title && !m['prog']) && IsSet(picWidth) ? ' x+' padXpicTxt : '') (IsSet(msgWidth) ? ' w' msgWidth : ''), msg)
        }

        g.MarginY := 15
        g.Show('Hide')
        WinGetPos(,, &gW, &gH, g)
        clickArea := g.Add('Text', 'x0 y0 w' gW ' h' gH ' BackgroundTrans')

        if callback
            clickArea.OnEvent('Click', callback)
        
        if (m['dgc'])
            clickArea.OnEvent('Click', this.gDestroy.Bind(this, g, 'clickArea'))

        g.OnEvent('Close', this.gDestroy.Bind(this, g, 'close'))
        g.boundFuncTimer := this.gDestroy.Bind(this, g, 'timer')
        
        if sound
            this.Sound(sound)
        
        ;==============================================
        
        switch m['pos'], 'off' {
            case 'br', 'bc', 'bl': minMaxPosY := monWABottom              
            case 'tr', 'tc', 'tl', 'ct': minMaxPosY := monWATop  
        }

        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')  

        for id in WinGetList('i)^NotifyGUI_' m['mon'] '_' m['pos'] ' ahk_class AutoHotkeyGUI') {            
            WinGetPos(, &guiY,, &guiH, 'ahk_id ' id)
            switch m['pos'], 'off' {
                case 'br', 'bc', 'bl': minMaxPosY := Min(minMaxPosY, guiY)               
                case 'tr', 'tc', 'tl', 'ct': minMaxPosY := Max(minMaxPosY, guiY + guiH)
            }
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])

        switch m['pos'], 'off' {
            case 'br':
            {           
                if minMaxPosY = monWABottom
                    gPos := 'x' monWARight - gW - m['padX'] ' y' monWABottom - gH - m['padY']
                else 
                    gPos := 'x' monWARight - gW - m['padX'] ' y' minMaxPosY - gH - this.padH                                 
            }
            case 'bc':
            {
                if minMaxPosY = monWABottom
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y'  monWABottom - gH - m['padY']         
                else
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' minMaxPosY - gH - this.padH
            }
            case 'bl': 
            {
                if minMaxPosY = monWABottom
                    gPos := 'x' monWALeft + m['padX'] ' y' monWABottom - gH - m['padY']
                else 
                    gPos := 'x' monWALeft + m['padX'] ' y' minMaxPosY - gH - this.padH                 
            }          
            case 'tl': 
            {
                if minMaxPosY = monWATop
                    gPos := 'x' monWALeft + m['padX'] ' y' monWATop + m['padY']
                else
                    gPos := 'x' monWALeft + m['padX'] ' y' minMaxPosY + this.padH 
            }              
            case 'tc': 
            {
                if minMaxPosY = monWATop
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' monWATop + m['padY']
                else
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' minMaxPosY + this.padH 
            }          
            case 'tr': 
            {
                if minMaxPosY = monWATop
                    gPos := 'x' monWARight - m['padX'] - gW ' y' monWATop + m['padY']
                else
                    gPos := 'x' monWARight - m['padX'] - gW ' y' minMaxPosY + this.padH
            }     
            case 'ct':
            {
                if minMaxPosY = monWATop
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' monWATop + (monWAheight/2 - gH/2)
                else
                    gPos := 'x' (monWARight - monWAwidth/2 - gW/2) ' y' minMaxPosY + this.padH
            }
        }

        switch g.pos, 'off' {    
            case 'br', 'bc', 'bl': (minMaxPosY < (monWATop + gH + this.padH)) ? outOfWorkArea := true : ''       
            case 'tr', 'tc', 'tl', 'ct': (minMaxPosY > (monWABottom - gH - this.padH)) ? outOfWorkArea := true : ''           
        }

        if m['dur']
            SetTimer(g.boundFuncTimer, -((m['dur'] + (IsSet(outOfWorkArea) ? 8 : 0)) * 1000 + m['showDur']))

        ;==============================================    
        
        this.mNotifyGUIs[gIndex] := g
        
        switch m['style'], 'off' {
            case 'round': this.FrameShadow(g.hwnd)
            case 'edge': m['bdr'] ? g.Opt('+Border'): ''
        }
                                     
        if m['wstp']
            WinSetTransparent(m['wstp'], g)

        if m['wstc']
            WinSetTransColor(m['wstc'], g)

        if m['showHex']
            g.Show(gPos ' NoActivate Hide'), DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', m['showDur'], 'Int', m['showHex'])  
        else
            g.Show(gPos ' NoActivate')
            
        return m
    }

    ;============================================================================================

    static gDestroy(g, fromMethod:='', *)
    {
        SetTimer(g.boundFuncTimer, 0)

        if g.hideHex && !RegExMatch(fromMethod, '^(Destroy|close)')
            DllCall('AnimateWindow', 'Ptr', g.hwnd, 'Int', g.hideDur, 'Int', Format("{:#X}", g.hideHex + 0x10000))
     
        g.Destroy()

        if this.mNotifyGUIs.Has(g.gIndex)
            this.mNotifyGUIs.Delete(g.gIndex) 

        ;==============================================
        
        Sleep(10)        
        aGUIs := Array()
        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_' g.mon '_' g.pos ' ahk_class AutoHotkeyGUI') {            
            try {
                WinGetPos(, &gY,, &gH, 'ahk_id ' id)
                RegExMatch(WinGetTitle('ahk_id ' id), 'i)^NotifyGUI_\d+_[a-z]+_(\d+)', &match)           
                aGUIs.Push(Map('gY', gY, 'gH', gH, 'id', id, 'padY', match[1]))
            } catch {
                aGUIs := Array()
                break
            }
        }
        
        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])
        
        if (aGUIs.Length) {
            MonitorGetWorkArea(g.mon,, &monWATop,, &monWABottom)
            monWAheight := Abs(monWABottom - monWATop)
            SetWinDelay(0)
            
            switch g.pos, 'off' {
                case 'br', 'bc', 'bl': aGUIs := this.SortArrayGUIPosY(aGUIs, true),  posY := monWABottom - aGUIs[1]['padY']               
                case 'tr', 'tc', 'tl', 'ct': aGUIs := this.SortArrayGUIPosY(aGUIs),  posY := monWATop + aGUIs[1]['padY']
            }           
            
            for _, value in aGUIs {
                switch g.pos, 'off'{
                    case 'br', 'bc', 'bl': posY -= value['gH']        
                    case 'ct': (A_Index = 1 ? posY := monWATop + monWAheight/2 - value['gH']/2 : '') 
                }                    
                
                if (Abs(posY - value['gY']) > 10) {
                    try WinMove(, posY,,, 'ahk_id ' value['id'])
                    catch
                        break
                }

                switch g.pos, 'off' {    
                    case 'br', 'bc', 'bl': posY -= this.padH        
                    case 'tr', 'tc', 'tl', 'ct': posY += value['gH'] + this.padH 
                } 
            }
        }
    }

    ;============================================================================================

    static Exist(tag)
    {
        mDhwTmm := this.Set_DHWindows_TMMode(0, 'RegEx')

        for id in WinGetList('i)^NotifyGUI_\d+_[a-z]+_\d+_\Q' tag '\E$ ahk_class AutoHotkeyGUI') {
            idFound := id
            break
        }

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])

        if IsSet(idFound)
            return idFound
        
        return 0
    }       

    ;============================================================================================

    static Destroy(str)
    {
        mDhwTmm := this.Set_DHWindows_TMMode(0, A_TitleMatchMode)        
        SetWinDelay(25)
     
        if (WinExist('ahk_id ' str)) {
            for gIndex, value in this.mNotifyGUIs.Clone() {
                if (str = value.handle && this.mNotifyGUIs.Has(gIndex)) {
                    this.gDestroy(this.mNotifyGUIs[gIndex], 'Destroy')   
                    break  
                }
            }                    

            SetTitleMatchMode(1)     
            for id in WinGetList('NotifyGUI_ ahk_class AutoHotkeyGUI') {
                if (str = id) { 
                    try WinClose('ahk_id ' id)
                    break
                }
            }              
        }         
        
        for gIndex, value in this.mNotifyGUIs.Clone()
            if str = value.tag && this.mNotifyGUIs.Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[gIndex], 'Destroy')   

        SetTitleMatchMode('RegEx')                                   
        for id in WinGetList('i)^NotifyGUI_\d+_[a-z]+_\d+_\Q' str '\E$ ahk_class AutoHotkeyGUI')                                                              
            try WinClose('ahk_id ' id)  
        
        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])                             
    }

    ;============================================================================================

    static DestroyAllOnMonitorAtPosition(monNum, position)
    {                                    
        for gIndex, value in this.mNotifyGUIs.Clone()
            if value.mon = monNum && value.pos = position && this.mNotifyGUIs.Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[gIndex], 'DestroyAllOnMonitorAtPosition')  
        
        this.WinGetList_WinClose('i)^NotifyGUI_' monNum '_' position ' ahk_class AutoHotkeyGUI', 0, 'RegEx')    
    }

    ;============================================================================================

    static DestroyAllOnAllMonitorAtPosition(position) 
    {
        for gIndex, value in this.mNotifyGUIs.Clone()
            if value.pos = position && this.mNotifyGUIs.Has(gIndex) 
                this.gDestroy(this.mNotifyGUIs[gIndex], 'DestroyAllOnAllMonitorAtPosition')

        this.WinGetList_WinClose('i)^NotifyGUI_\d+_' position ' ahk_class AutoHotkeyGUI', 0, 'RegEx')
    }    

    ;============================================================================================    

    static DestroyAllOnMonitor(monNum)
    {             
        for gIndex, value in this.mNotifyGUIs.Clone()
            if value.mon = monNum && this.mNotifyGUIs.Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[gIndex], 'DestroyAllOnMonitor') 
        
        this.WinGetList_WinClose('NotifyGUI_' monNum ' ahk_class AutoHotkeyGUI', 0, 1)                      
    } 

    ;============================================================================================

    static DestroyAll()
    {           
        for gIndex, value in this.mNotifyGUIs.Clone()                              
            if this.mNotifyGUIs.Has(gIndex)
                this.gDestroy(this.mNotifyGUIs[gIndex], 'DestroyAll')
        
        this.WinGetList_WinClose('NotifyGUI_ ahk_class AutoHotkeyGUI', 0, 1)                           
    } 

    ;============================================================================================

    static WinGetList_WinClose(winTtile, dhWindows, tmMode)
    {
        mDhwTmm := this.Set_DHWindows_TMMode(dhWindows, tmMode)
        SetWinDelay(25)
        
        for id in WinGetList(winTtile)
            try WinClose('ahk_id ' id)

        this.Set_DHWindows_TMMode(mDhwTmm['dhwPrev'], mDhwTmm['tmmPrev'])        
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
        this.Destroy('SaveToClipboard')
        A_Clipboard := ''
        A_Clipboard := this.gSnd.ddl.Text

        if ClipWait(1)
            this._Show('"' A_Clipboard '"', 'Saved to clipboard.', 'iconi',,, 'pos=bc dur=5 tag=SaveToClipboard')
        else
            this._Show('Error', 'Save to clipboard failed.', 'iconx', 'soundx',, 'pos=bc dur=5 tag=SaveToClipboard')
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
        (*) => this.Destroy('MonitorInfo'), 
        'dur=0 pos=ct mali=center tali=center tfo=underline italic tc=00FF46 mc=00FF46 style=edge show=expand@125 tag=MonitorInfo')['hwnd']

        Loop monCount {
            MonitorGet(A_Index, &monLeft, &monTop, &monRight, &monBottom)
            MonitorGetWorkArea(A_Index, &monWALeft, &monWATop, &monWARight, &monWABottom)
            this._Show(
                'Monitor #' A_Index, 
                (
                'Left:`t' monLeft ' (WorkArea: ' monWALeft ')
                Top:`t' monTop ' (WorkArea: ' monWATop ')
                Right:`t' monRight ' (WorkArea: ' monWARight ')
                Bottom:`t' monBottom ' (WorkArea: ' monWABottom ')'
                ),,,, 'dur=0 mon=' A_Index ' pos=ct tali=center tag=MonitorInfo'   
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

    static SortArrayGUIPosY(arr, sortReverse := false)
    {
        for _, value in arr
            listValueY .= value['gY'] ','

        listSortValueY := Sort(RTrim(listValueY, ','), (sortReverse ? 'RN' : 'N') ' D,')
        sortArray := Array()

        for index, value in StrSplit(listSortValueY, ',')
            for _, v in arr
                if v['gY'] = value
                    sortArray.Push(v)
            
        return sortArray    
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
