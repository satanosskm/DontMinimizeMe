#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

global WindowPositions := Map()
global LastStates := Map()
global IgnoredWindows := Map()  ; NOUVEAU: fenêtres à ignorer
global MaxWindows := 50

SetTimer(CheckWindows, 250)      ; Ralenti: 250ms au lieu de 100ms
SetTimer(CleanupClosedWindows, 10000)  ; Plus fréquent: 10s

CheckWindows() {
    global WindowPositions, LastStates, IgnoredWindows, MaxWindows
    
    for hwnd in WinGetList() {
        try {
            ; Ignorer les fenêtres problématiques
            if (IgnoredWindows.Has(hwnd))
                continue
            
            if (WindowPositions.Count >= MaxWindows && !WindowPositions.Has(hwnd))
                continue
            
            title := WinGetTitle("ahk_id " hwnd)
            if (title = "" || title = "Program Manager")
                continue
            
            class := WinGetClass("ahk_id " hwnd)
            if (class ~= "i)(Shell_|Progman|WorkerW|TopLevelWindowForOverflowXamlIsland|Windows\.UI)")
                continue
            
            style := WinGetStyle("ahk_id " hwnd)
            exStyle := WinGetExStyle("ahk_id " hwnd)
            
            if !(style & 0x10000000)
                continue
            if (exStyle & 0x80)
                continue
            
            minmax := WinGetMinMax("ahk_id " hwnd)
            
            if (minmax = 0 || minmax = 1) {
                WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
                if (x != "" && w > 0) {
                    WindowPositions[hwnd] := {x: x, y: y, w: w, h: h}
                    LastStates[hwnd] := minmax
                }
            }
            else if (minmax = -1) {
                if (LastStates.Has(hwnd) && LastStates[hwnd] != -1) {
                    
                    ; NOUVEAU: Protection anti-boucle
                    WinRestore("ahk_id " hwnd)
                    Sleep(50)  ; Attendre la restauration
                    
                    ; Vérifier si la restauration a fonctionné
                    newState := WinGetMinMax("ahk_id " hwnd)
                    if (newState = -1) {
                        ; La fenêtre refuse - l'ignorer désormais
                        IgnoredWindows[hwnd] := true
                        continue
                    }
                    
                    if WindowPositions.Has(hwnd) {
                        pos := WindowPositions[hwnd]
                        WinMove(pos.x, pos.y, pos.w, pos.h, "ahk_id " hwnd)
                    }
                    
                    WinMoveBottom("ahk_id " hwnd)
                    LastStates[hwnd] := 0
                }
            }
        } catch as e {
            ; NOUVEAU: Gestion silencieuse des erreurs
            continue
        }
    }
}

CleanupClosedWindows() {
    global WindowPositions, LastStates, IgnoredWindows
    
    toDelete := []
    
    for hwnd, pos in WindowPositions {
        if !WinExist("ahk_id " hwnd)
            toDelete.Push(hwnd)
    }
    
    for hwnd in toDelete {
        WindowPositions.Delete(hwnd)
        if LastStates.Has(hwnd)
            LastStates.Delete(hwnd)
        if IgnoredWindows.Has(hwnd)
            IgnoredWindows.Delete(hwnd)
    }
    
    ; NOUVEAU: Nettoyage des fenêtres ignorées fermées
    toDeleteIgnored := []
    for hwnd, val in IgnoredWindows {
        if !WinExist("ahk_id " hwnd)
            toDeleteIgnored.Push(hwnd)
    }
    for hwnd in toDeleteIgnored {
        IgnoredWindows.Delete(hwnd)
    }
}

~LButton:: {
    global WindowPositions
    
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    
    monCount := MonitorGetCount()
    isTaskbar := false
    
    loop monCount {
        MonitorGetWorkArea(A_Index, &left, &top, &right, &bottom)
        MonitorGet(A_Index, &mLeft, &mTop, &mRight, &mBottom)
        
        if (mx >= mLeft && mx <= mRight && my >= bottom && my <= mBottom) {
            isTaskbar := true
            break
        }
    }
    
    if (isTaskbar) {
        Sleep(150)
        
        try {
            hwnd := WinGetID("A")
            if (hwnd && WindowPositions.Has(hwnd)) {
                pos := WindowPositions[hwnd]
                WinMove(pos.x, pos.y, pos.w, pos.h, "ahk_id " hwnd)
                WinMoveTop("ahk_id " hwnd)
            }
        }
    }
}

global ScriptEnabled := true

#F12:: {  ; MODIFIÉ: F12 au lieu de ` pour compatibilité AZERTY
    global ScriptEnabled
    ScriptEnabled := !ScriptEnabled
    
    if ScriptEnabled {
        SetTimer(CheckWindows, 250)
        TrayTip("Anti-Minimize", "ACTIVÉ", 1)
    } else {
        SetTimer(CheckWindows, 0)
        TrayTip("Anti-Minimize", "DÉSACTIVÉ", 1)
    }
}

#^r:: Reload()

TrayTip("Anti-Minimize", "Script actif!`nWin+F12 pour toggle", 1)