Scriptname UD_OrgasmManagerPlayer extends UD_OrgasmManager conditional

import UnforgivingDevicesMain
import UD_Native

bool    _crit               = false
bool    _specialButtonOn    = false
string  _crit_meter         = "UDmain.Error"

Function RegisterModEvents()
    _OrgasmEventName = "UD_OrgasmPlayer"
    _UpdateBaseOrgasmValEventName = "UD_UpdateBaseOrgasmValPlayer"
    RegisterForModEvent("UD_CritUpdateLoopStart_OrgasmResist","CritLoopOrgasmResist")
    RegisterForModEvent(_UpdateBaseOrgasmValEventName, "Receive_UpdateBaseOrgasmVals")
    RegisterForModEvent(_OrgasmEventName,"Orgasm")
EndFunction

;///////////////////////////////////////
;=======================================
;ORGASM RESIST MINIGAME
;=======================================
;//////////////////////////////////////;

;=======================================
;ORGASM _crit FUNCTIONS
;=======================================

bool _PlayerOrgasmResist_MinigameOn = false
Function sendOrgasmResistCritUpdateLoop(Int aiChance,Float afDifficulty)
    int handle = ModEvent.Create("UD_CritUpdateLoopStart_OrgasmResist")
    if (handle)
        ModEvent.PushInt(handle,aiChance)
        ModEvent.PushFloat(handle,afDifficulty)
        ModEvent.Send(handle)
    endif
EndFunction

Function CritLoopOrgasmResist(Int aiChance,Float afDifficulty)
    string loc_meter = "none"
    bool loc_sendCrit = false
    while _PlayerOrgasmResist_MinigameOn
        if RandomInt(1,100) <= aiChance
            if !UDCDmain.UD_AutoCrit
                if RandomInt(0,1)
                    loc_meter = "S"
                else
                    loc_meter = "M"
                endif
                loc_sendCrit = true
            else ;auto crits
                if RandomInt() <= UDCDmain.UD_AutoCritChance
                    OnCritSuccesOrgasmResist()
                else
                    OnCritFailureOrgasmResist()
                endif
                return
            endif
        endif    
        if loc_sendCrit
            _crit = True
            _crit_meter = loc_meter
            if (loc_meter == "S")
                if UDCDmain.UD_CritEffect == 2 || UDCDmain.UD_CritEffect == 1
                    UDlibs.GreenCrit.RemoteCast(UDmain.Player,UDmain.Player,UDmain.Player)
                endif
                if UDCDmain.UD_CritEffect == 2 || UDCDmain.UD_CritEffect == 0
                    UI.Invoke("HUD Menu", "_root.HUDMovieBaseInstance.StartStaminaBlinking")
                endif
            elseif (loc_meter == "M")
                if UDCDmain.UD_CritEffect == 2 || UDCDmain.UD_CritEffect == 1
                    UDlibs.BlueCrit.RemoteCast(UDmain.Player,UDmain.Player,UDmain.Player)
                endif
                if UDCDmain.UD_CritEffect == 2 || UDCDmain.UD_CritEffect == 0
                    UI.Invoke("HUD Menu", "_root.HUDMovieBaseInstance.StartMagickaBlinking")
                endif
            elseif (loc_meter == "R")
                if UDCDmain.UD_CritEffect == 2 || UDCDmain.UD_CritEffect == 1
                    UDlibs.RedCrit.RemoteCast(UDmain.Player,UDmain.Player,UDmain.Player)
                endif
            endif
            
            Utility.wait(fRange(afDifficulty + UDCDMain.UD_CritDurationAdjust,0.7,2.0))
            _crit = False
            loc_meter = "none"
            _crit_meter = "none"
            loc_sendCrit = false
        endif
        Utility.wait(1.0)
    endwhile
EndFunction

Function OnCritSuccesOrgasmResist()
    if UDmain.TraceAllowed()
        UDmain.Log("OnCritSuccesOrgasmResist() callled!")
    endif
    UDmain.Player.restoreAV("Stamina", 10)
    OrgasmSystem.AddOrgasmChange(UDmain.Player,"OrgasmResist.CritS",0x30024,0x00000200,afOrgasmResistenceMult = 5.0)
EndFunction

Function OnCritFailureOrgasmResist()
    if UDmain.TraceAllowed()    
        UDmain.Log("OnCritFailureOrgasmResist() callled!")
    endif
    OrgasmSystem.AddOrgasmChange(UDmain.Player,"OrgasmResist.CritF",0x30024,0x00000200,afOrgasmRateMult = 2.0)
EndFunction

Event MinigameKeysRegister()
    if UDmain.TraceAllowed()
        UDmain.Log("UD_OrgasmManager MinigameKeysRegister called",1)
    endif
    RegisterForKey(UDCDMain.Stamina_meter_Keycode)
    RegisterForKey(UDCDMain.SpecialKey_Keycode)
    RegisterForKey(UDCDMain.Magicka_meter_Keycode)
    RegisterForKey(UDCDMain.ActionKey_Keycode)
    _specialButtonOn = false
EndEvent

Event MinigameKeysUnregister()
    if UDmain.TraceAllowed()    
        UDmain.Log("UD_OrgasmManager MinigameKeysUnregister called",1)
    endif
    UnregisterForKey(UDCDMain.Stamina_meter_Keycode)
    UnregisterForKey(UDCDMain.SpecialKey_Keycode)
    UnregisterForKey(UDCDMain.Magicka_meter_Keycode)
    UnregisterForKey(UDCDMain.ActionKey_Keycode)
    _specialButtonOn = false
EndEvent

Event OnKeyDown(Int KeyCode)
    if !UDmain.IsMenuOpen() ;only if player is not in menu
        bool   loc_crit     = _crit ;help variable to reduce lag
        string loc_meter    = _crit_meter
        if _PlayerOrgasmResist_MinigameOn
            if KeyCode == UDCDmain.SpecialKey_Keycode
                _specialButtonOn = true
                return
            endif
            if (loc_crit) && !UDCDmain.UD_AutoCrit
                if (loc_meter == "S") && (KeyCode == UDCDmain.Stamina_meter_Keycode)
                    _crit = False
                    _crit_meter = "none"
                    OnCritSuccesOrgasmResist()
                    return
                elseif (loc_meter == "M") && (KeyCode == UDCDmain.Magicka_meter_Keycode)
                    _crit = False
                    _crit_meter = "none"
                    OnCritSuccesOrgasmResist()
                    return
                elseif (KeyCode == UDCDmain.Magicka_meter_Keycode) || (KeyCode == UDCDmain.Stamina_meter_Keycode)
                    _crit = False
                    _crit_meter = "none"
                    OnCritFailureOrgasmResist()
                    return
                elseif KeyCode == UDCDmain.ActionKey_Keycode
                    UDmain.Player.removeFromFaction(OrgasmResistFaction)
                    _crit = false
                    _crit_meter = "none"
                    return 
                endif
            endif
            if KeyCode == UDCDmain.ActionKey_Keycode
                UDmain.Player.removeFromFaction(OrgasmResistFaction)
                _crit = false
                _crit_meter = "none"
                return
            elseif (KeyCode == UDCDmain.Stamina_meter_Keycode || KeyCode == UDCDmain.Magicka_meter_Keycode) && !UDCDmain.UD_AutoCrit
                _crit = False
                _crit_meter = "none"
                OnCritFailureOrgasmResist()
                return
            endif
        endif
    endif
EndEvent

Event OnKeyUp(Int KeyCode, Float HoldTime)
    if KeyCode == UDCDmain.SpecialKey_Keycode
        if _PlayerOrgasmResist_MinigameOn
            _specialButtonOn = false
        endif
        return
    endif
EndEvent

String[] _HornyAnimDefs
Int _ActorConstraints = -1

;=======================================
;ORGASM RESIST LOOP
;=======================================
Function FocusOrgasmResistMinigame(Actor akActor)
    if getCurrentActorValuePerc(akActor,"Stamina") < 0.75
        if IsPlayer(akActor)
            UDmain.Print("You are too exhausted!")
        endif
        return
    endif
    
    if UDCDMain.actorInMinigame(akActor) || UDmain.UDAM.isAnimating(akActor)
        if akActor == UDmain.Player
            UDmain.Print("You are already busy!")
        endif
        return
    endif
    
    if (OrgasmSystem.GetOrgasmVariable(akActor,1)*OrgasmSystem.GetOrgasmVariable(akActor,2) <= 0.0)
        return
    endif
    
    akActor.AddToFaction(UDCDmain.MinigameFaction)
    akActor.AddToFaction(OrgasmResistFaction)
    
    float loc_staminaRate     = akActor.getBaseAV("StaminaRate")
    akActor.setAV("StaminaRate", 0.0)
    
    OrgasmSystem.AddOrgasmChange(akActor,"OrgasmResistMinigame",0,0x00020000,0.0,afOrgasmResistence = 2.5, afOrgasmResistenceMult = 0.75)

    UDCDMain.StartMinigameDisable(akActor)
    Int loc_constraints = UDmain.UDAM.GetActorConstraintsInt(akActor, abUseCache = False)
    If _ActorConstraints != loc_constraints
        _ActorConstraints = loc_constraints
        _HornyAnimDefs = UDmain.UDAM.GetHornyAnimDefs(akActor)
    EndIf
    If _HornyAnimDefs.Length > 0
        Actor[] loc_actors = new Actor[1]
        loc_actors[0] = akActor
        UDmain.UDAM.PlayAnimationByDef(_HornyAnimDefs[RandomInt(0, _HornyAnimDefs.Length - 1)], loc_actors)
    Else
        UDmain.Warning("UD_OrgasmManagerPlayer::FocusOrgasmResistMinigame() Can't find animations for the horny actor")
    EndIf

    UDCDMain.sendHUDUpdateEvent(true,true,true,true)
    
    UDmain.UDUI.GoToState("UIDisabled")
    MinigameKeysRegister()
    
    UDmain.UDWC.Meter_SetVisible("player-orgasm", True)
    if IsPlayer(akActor)
        _PlayerOrgasmResist_MinigameOn = true
        sendOrgasmResistCritUpdateLoop(15,0.9)
    endif
    
    float loc_baseDrain = 5.0 + getMaxActorValue(akActor,"Stamina",0.04)
    if akActor.wornhaskeyword(libs.zad_deviousheavybondage)
        loc_baseDrain += getMaxActorValue(akActor,"Stamina",0.03)
    endif
    
    float   loc_currentOrgasmRate           = OrgasmSystem.GetOrgasmVariable(akActor,1)
    bool    loc_cycleON                     = true
    int     loc_tick                        = 0
    float   loc_StaminaRateMult             = 1.0
    float   loc_orgasmResistence            = OrgasmSystem.GetOrgasmVariable(akActor,3)
    int     loc_HightSpiritMode_Duration    = -2*Round(1/UDmain.UD_baseUpdateTime)
    int     loc_HightSpiritMode_Type        = 1

    UD_Native.StartMinigameEffect(akActor,fRange((loc_currentOrgasmRate/loc_orgasmResistence),0.5,3.5), loc_baseDrain, 0.0, 0.0, true)
    
    while loc_cycleON
        if !akActor.isInFaction(OrgasmResistFaction)
            loc_cycleON = false
        endif
        
        if loc_cycleON
            loc_cycleON = UD_Native.MinigameStatsCheck(akActor,true,false,false)
        endif
        
        if loc_cycleON
            if _specialButtonOn
                if loc_HightSpiritMode_Duration > 0
                    if loc_HightSpiritMode_Type == 1
                        loc_StaminaRateMult = 0.5
                    elseif loc_HightSpiritMode_Type == 2
                        loc_StaminaRateMult = 1.25
                        OrgasmSystem.UpdateOrgasmChangeVar(akActor,"OrgasmResistMinigame",3,5.0,2)
                    elseif loc_HightSpiritMode_Type == 3
                        loc_StaminaRateMult = 1.5
                        OrgasmSystem.UpdateOrgasmChangeVar(akActor,"OrgasmResistMinigame",9,-6.0,1)
                    endif
                else
                    loc_StaminaRateMult = 2.0
                endif
            else
                loc_StaminaRateMult = 1.0
                OrgasmSystem.UpdateOrgasmChangeVar(akActor,"OrgasmResistMinigame",9,0.0,1)
                OrgasmSystem.UpdateOrgasmChangeVar(akActor,"OrgasmResistMinigame",3,2.5,1)
            endif
        endif
        
        if loc_tick*UDmain.UD_baseUpdateTime >= 1.0 && loc_cycleON
            loc_currentOrgasmRate       = OrgasmSystem.GetOrgasmVariable(akActor,1)
            loc_orgasmResistence        = OrgasmSystem.GetOrgasmVariable(akActor,3)
            if loc_HightSpiritMode_Duration == 0
                if RandomInt() <= 40 
                    loc_HightSpiritMode_Type = RandomInt(1,3)
                    if loc_HightSpiritMode_Type == 1 ;RED
                        UDmain.UDWC.Meter_SetColor("player-orgasm", 0xff0000, 0xff00d8, 0xFF00BC)
                    elseif loc_HightSpiritMode_Type == 2 ;GREEN
                        UDmain.UDWC.Meter_SetColor("player-orgasm", 0x00ff68, 0x00ff68, 0xFF00BC)
                    elseif loc_HightSpiritMode_Type == 3 ;BLUE
                        UDmain.UDWC.Meter_SetColor("player-orgasm", 0x2e40d8, 0x2e40d8, 0xFF00BC)
                    endif
                    loc_HightSpiritMode_Duration += RandomInt(3,6)*Round(1/UDmain.UD_baseUpdateTime)
                endif
            endif
            loc_tick = 0
            UDCDmain.sendHUDUpdateEvent(true,true,true,true)
            UDCDMain.UpdateMinigameDisable(akActor)
        endif
        
        if loc_cycleON
            float loc_mult = loc_StaminaRateMult*fRange((loc_currentOrgasmRate/loc_orgasmResistence),0.5,3.5)
            UD_Native.UpdateMinigameEffectMult(akActor,loc_mult)
        endif
        
        if loc_HightSpiritMode_Duration > 0 && loc_cycleON
            loc_HightSpiritMode_Duration -= 1
            if loc_HightSpiritMode_Duration == 0
                UDmain.UDWC.Meter_SetColor("player-orgasm", 0xE727F5, 0xF775FF,0xFF00BC)
                loc_HightSpiritMode_Duration -= RandomInt(3,4)*Round(1/UDmain.UD_baseUpdateTime)
            endif
        elseif loc_HightSpiritMode_Duration < 0
            loc_HightSpiritMode_Duration += 1
        endif
        
        if loc_cycleON
            Utility.wait(UDmain.UD_baseUpdateTime)
            loc_tick += 1
        endif
    endwhile
    
    UD_Native.EndMinigameEffect(akActor)
    
    akActor.setAV("StaminaRate", loc_staminaRate)
    
    OrgasmSystem.RemoveOrgasmChange(akActor,"OrgasmResistMinigame")
    
    if IsPlayer(akActor)
        _PlayerOrgasmResist_MinigameOn = false
    endif

    Int loc_toggle  = 0x0
    if !GetOrgasmInMinigame(akActor)
        ;wearer is not orgasming, stop animation
        loc_toggle += 0x1
    endif
    if loc_toggle
        UDmain.UDAM.StopAnimation(akActor, none, abEnableActors = False, aiToggle = loc_toggle)
    endif
    
    akActor.RemoveFromFaction(UDCDmain.MinigameFaction)
    
    UDCDMain.EndMinigameDisable(akActor)
    
    UDmain.UDUI.GoToState("")
    MinigameKeysUnregister()
    
    UDmain.UDWC.Meter_SetColor("player-orgasm", 0xE727F5, 0xF775FF, 0xFF00BC)
    
    akActor.RemoveFromFaction(OrgasmResistFaction)
    
    UDlibs.StruggleExhaustionSpell.SetNthEffectMagnitude(0, 40)
    UDlibs.StruggleExhaustionSpell.SetNthEffectDuration(0, 15)
    Utility.wait(0.1)
    UDlibs.StruggleExhaustionSpell.cast(akActor)
EndFunction