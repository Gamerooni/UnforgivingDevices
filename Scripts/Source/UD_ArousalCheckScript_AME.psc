Scriptname UD_ArousalCheckScript_AME extends activemagiceffect 

import UnforgivingDevicesMain

UDCustomDeviceMain      Property UDCDmain auto
UnforgivingDevicesMain  Property UDmain     auto
UD_OrgasmManager        Property UDOM       auto
UD_ExpressionManager    Property UDEM       auto
zadlibs                 Property libs       auto

Actor       akActor         = none
bool        _finished       = false
Bool        loc_isplayer    = false
float       loc_updateTime  = 1.0
Float       loc_arousalRate = 0.0
Int         loc_arousal     = 0      ;how much is arousal increased/decreased
MagicEffect _MagickEffect   = none

Event OnEffectStart(Actor akTarget, Actor akCaster)
    _MagickEffect = GetBaseObject()
    akActor = akTarget
    akActor.AddToFaction(UDOM.ArousalCheckLoopFaction)
    if UDmain.TraceAllowed()
        UDCDmain.Log("UD_ArousalCheckScript_AME("+getActorName(akActor)+") - OnEffectStart()")
    endif
    registerForSingleUpdate(0.1)
EndEvent

Event OnPlayerLoadGame()
    Utility.wait(1.0)
    if IsRunning()
        akActor.AddToFaction(UDOM.ArousalCheckLoopFaction)
    endif
    if !UDOM
        UDOM    = UDCDmain.UDOM
    endif
    if !UDEM
        UDEM    = UDCDmain.UDEM
    endif
    if !UDmain
        UDmain  = UDCDmain.UDmain
    endif
    loc_isplayer = UDmain.ActorIsPlayer(akActor)
EndEvent

Int _UpdateTime = 1
Event OnUpdate()
    if IsRunning()
        loc_arousalRate = UDOM.getArousalRateM(akActor)         ;arousal rate
        loc_arousal     = Round(loc_arousalRate)*_UpdateTime    ;how much will be arousal increased
        
        if loc_arousal != 0
            akActor.SetFactionRank(UDOM.ArousalCheckLoopFaction,UDOM.UpdateArousal(akActor ,loc_arousal))
        else
            akActor.SetFactionRank(UDOM.ArousalCheckLoopFaction,UDOM.getActorArousal(akActor))
        endif

        if IsRunning()
            if loc_isplayer
                _UpdateTime = 1 ;update once per 1 seconds
            else
                _UpdateTime = 2 ;update once per 2 seconds
            endif
            registerForSingleUpdate(_UpdateTime) 
        endif
    endif
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    _finished = true
    if UDmain.TraceAllowed()    
        UDCDmain.Log("UD_ArousalCheckScript_AME("+getActorName(akActor)+") - OnEffectFinish()",1)
    endif
    akActor.RemoveFromFaction(UDOM.ArousalCheckLoopFaction)
EndEvent

bool Function IsRunning()
    return !_finished
EndFunction
