// -----------------------------------------------------------------------------
//    File: dmfi_i_events.nss
//  System: DMFI (events)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

#include "dmfi_i_util"
#include "dmfi_i_hooks"
#include "dmfi_i_const"
#include "dsutil_i_data"

#include "util_i_csvlists"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Module Events -----

int dmfi_InitializeCommands()
{
    return dmfi_InitializeSystem(DMFI_COMMAND_ITEMS_CSV,
                                 DMFI_COMMAND_ITEMS_LOADED_CSV,
                                 DMFI_COMMAND_ITEMS_PREFIX,
                                 DMFI_COMMAND_ITEMS_OBJECT_LIST,
                                 DMFI_COMMAND_ITEMS_INITIALIZED);
}

int dmfi_InitializeLanguages()
{
    return dmfi_InitializeSystem(DMFI_LANGUAGE_ITEMS_CSV,
                                 DMFI_LANGUAGE_ITEMS_LOADED_CSV,
                                 DMFI_LANGUAGE_ITEMS_PREFIX,
                                 DMFI_LANGUAGE_ITEMS_OBJECT_LIST,
                                 DMFI_LANGUAGE_ITEMS_INITIALIZED);
}

void dmfi_OnModuleLoad()
{    
    //TODO Voice tokens?  Otherwise, this function is pretty useless, just a switch flipper.
    // void initVoiceTokens in original dmfi_init_inc
    SetLocalInt(DMFI_DATA, DMFI_INITIALIZED, TRUE);
    Debug("DMFI :: Initialized for the module.");

    SetLocalInt(DMFI, DMFI_MODULE_LOCKED, FALSE);

    //TODO, load all command objects and language objects?
    //Let's initialize all the command items
    dmfi_InitializeCommands()
    dmfi_InitializeLanguages()
}

void dmfi_OnClientEnter()
{   
    object oPC = GetEnteringObject();
 
    if (!_GetIsPC(oPC))
        return;
 
    SetLocalObject(oPC, DMFI_TARGET_VOICE, OBJECT_INVALID);
    SetLocalObject(oPC, DMFI_TARGET_COMMAND, oPC);
    SetLocalInt(oPC, DMFI_INITIALIZED, TRUE);

    string sUserSettings = dmfi_PullSettings(oPC);
    
    //Set user settings on PC
    if (sUserSettings == "")
    {
        Debug("DMFI :: Loading default settings for " + GetName(oPC));
        dmfi_SetDefaultSettings(oPC, TRUE);
    }    
    else
    {
        Debug("DMFI :: Loading custom settings for " + GetName(oPC));
        SetLocalString(oPC, DMFI_USER_SETTINGS, sUserSettings);
    }

    //Set languages on PC
    string sLanguages = dmfi_PullKnownLanguages(oPC);

    if (sLanguages == "")
    {
        Debug("");
        dmfi_ResetKnownLanguages(oPC, TRUE);
    }
    else
    {
        Debug("");
        SetLocalString(oPC, DMFI_LANGUAGE_KNOWN, sLanguages);
        dmfi_AssignCurrentLanguage(oPC, DMFI_LANGUAGE_ITEM_COMMON);
    }

    //TODO informative logging information
    //TODO Set all the custom tokens or create the custom dialog
    //  see original dmfi_init_inc :: dmfiInitialize
    //According to the lexicon, custom tokens are universal/global, so
    //  see how that will affect the conversations.
    return TRUE;
}

void dmfi_HandleChatHook(int nHandle)
{
    //TODO how does the chathook get the chat string?
    struct DMFI_CHATHOOK ch = dmfi_GetChatHook(nHandle);
    if ((1 << GetPCChatVolume() & ch.nChannels) &&
            (ch.bListenAll || ch.oSpeaker == GetPCChatSpeaker()))
        ExecuteScript(ch.sScript, ch.oScriptRunner);

    if (ch.AutoRemove)
        dmfi_RemoveChatHook(ch.nHandle);
}

void dmfi_HandleListenerHook(int nHandle)
{
/*
    //This is a listener hook, brought in from the first part
    //  of RelayTextToEavesdropper() in dmfi_plychat_exe
    //TODO See if Type 1 and Type 2 listener hook logic can
    //  be combined, do we need a type 3?
    //  Seems like a really convoluted way to listen to the PC
    //  IF you want to eavesdrop on the PC, just send all of his
    //  chat to the DM., unless you want to listen to an entire
    //  conversation (both sides) 
    //TODO this is all whack.  Change the listening options:
    //  --List to anything a PC says (but not hears)
    //  --Eavesdrop on PC (everything he says or hears publicly)
    //  --Eavesdrop on NPC (everything NPC hears)
    //  --Eavesdrop on location (everthing heard at location)
    //TODO -- Create this message and color it
    struct DMFI_LISTENER_HOOK lh = dmfi_GetListenerHook(nHandle);

    // As long as the hook type is good, keep going, if not, clean
    //  up the mess.
    // TODO -- Change these to constants for easier understanding
    if (!lh.nType || lh.nType > 2);
    {
        dmfi_RemoveListenerHook(lh.nHandle);
        break;
    }

    if (GetIsObjectValid(lh.oCreature))
    {
        object oListener;
        location lListener, lPC = GetLocation(oPC);

        if (lh.nRange)
            oListener = GetFirstFactionMember(lh.oCreature, FALSE);
        else
            oListener = lh.oCreature;
        
        lListener = GetLocation(oListener);
        while (GetIsObjectValid(oListener))
        {
            fDistance = GetDistanceBetweenLocations(lPC, lListener);
            
            //TODO --- check validity of these constants ----..
            if ((oPC == oListener) || 
                ((nVolume == TALKVOLUME_WHISPER && fDistance <= WHISPER_DISTANCE) ||
                (nVolume != TALKVOLUME_WHISPER && fDistance <= TALK_DISTANCE)))
            {
                //TODO this is all whack.  Change the listening options:
                //  --List to anything a PC says (but not hears)
                //  --Eavesdrop on PC (everything he says or hears publicly)
                //  --Eavesdrop on NPC (everything NPC hears)
                //  --Eavesdrop on location (everthing heard at location)
                //TODO -- Create this message and color it
                //TODO -- check the break logic against original
                //TODO -- See about sending to all DMs
                //  probably need a subfunction for this.
                //  in dmfi_plychat_exe
                string sMessage = "";
                SendMessageToPC(lh.oOwner, sMessage);
                break;
            }
            if (!lh.nRange)
                break;

            oListener = GetNextFactionMember(lh.oCreature, FALSE);
        }
    }
    else
    {
        //Invalid, delete teh hook
        dmfi_RemoveListenerHook(lh.nHandle);
    }*/
}

struct DMFI_COMMAND_VARIABLES dmfi_SetCommandVariables()
{
    struct DMFI_COMMAND_VARIABLES cv;

    cv.oSpeaker = OBJECT_SELF;
    cv.oTarget = GetLocalObject(oSpeaker, TODO);
    cv.sArguments = GetLocalObject(oSpeaker, TODO);
    cv.sModifiedMessge = GetLocalString(oSpeaker, TODO);

    return cv;
} 

void dmfi_c_target()
{   //.tar, .vtar
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sName, sType = GetListItem(cv.sArguments, 0);
    object oTarget = GetLocalObject(cv.oSpeak, DMFI_TARGET_XXX_TODO);

    //TODO modify this to use the target created by using the wand.
    //  when used, the wand should save the target to the ospeaker,
    //  if a target exists, otherwise, can it just save the location?
    //TODO so if there's a target on the wand, set it as the primary
    //  action target, if not, if there's an argument, see if we can
    //  find that object
    //TODO probably need a speical function in case npc/pc names
    //  have spaces, need to be able to search the list for that.
    if (HasListItem("tar,target", sType))
    {
        if (GetIsObjectValid(oTarget))
        {
            SetLocalObject(cv.oSpeaker, DMFI_UNIV_TARGET_XXX_TODO)
        }
    }
    //TODO lots of work here to figure out what they're trying to accomplish
    //  I tink it's targeting by name, which seems really inaccurate, one
    //  mispelling tosses the whole thing.

}

void dmfi_c_faction()
{   //.fac
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    int nFaction;

    if (HasListItem(cv.sArguments, "hostile"))
        nFaction = STANDARD_FACTION_HOSTILE;
    else if (HasListItem(cv.sArguments, "commoner"))
        nFaction = STANDARD_FACTION_COMMONER;
    else if (HasListItem(cv.sArguments, "defender"))
        nFaction = STANDARD_FACTION_DEFENDER;
    else if (HasListItem(cv.sArguments, "merchant"))
        nFaction = STANDARD_FACTION_MERCHANT;
    else
        return;  //TODO Fail message

    ChangeToStandardFaction(cv.oTarget, nFaction);

    if (GetIsImmune(cv.oTarget, IMMUNITY_TYPE_BLINDNESS))
        //DMFISendMessageToPC(oCommander, "Targeted creature is blind immune - no attack will occur until new perception event is fired", FALSE, DMFI_MESSAGE_COLOR_ALERT);
    else
    {
        effect e = EffectBlindness();
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, e, cv. oTarget, 6.1);
        //DMFISendMessageToPC(oCommander, "Faction Adjusted - will take effect in 6 seconds", FALSE, DMFI_MESSAGE_COLOR_STATUS);
    }
}

void dmfi_c_vfx()
{   //.vfx  TODO for all these that have loops for numbers, apply more than one?
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sVFX;
    int i, nVFX, nCount = CountList(cv.sArguments);

    for (i = 0; i < nCount; i++)
    {
        sDamage = GetListItem(cv.sArguments, i);

        if (TestStringAgainstPattern("*n", sDamage))
        {   //TODO constant for "dmfi_voice" and how is it set?
            if (GetTag(cv.oTarget) == "dmfi_voice")
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(nEffect), GetLocation(cv.oTarget), 10.0f);
            else
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nEffect), cv.oTarget, 10.0f);
            
            return;
        }
    }
}

void dmfi_c_get()
{   //.get, .got
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sAction = GetListItem(cv.Arguments, 0);
    string sCharacter = GetListItem(cv.Arguments, 1);
    object oNPC;

    oNPC = GetLocalObject(cv.oSpeaker, DMFI_COMMAND_SET + sCharacter);
    if (GetIsObjectValid(oNPC))
    {
        if (sAction == "get")
        {
            AssignCommand(oNPC, ClearAllActions());
            AssignCommand(oNPC, ActionJumpToLocation(cv.oSpeaker));
        }
        else if (sAction = "got")
        {
            AssignCommand(cv.oSpeaker, ClearAllActions());
            AssignCommand(cv.oSpeaker, ActionJumpToLocation(GetLocation(oNPC)));
        }
    }
    //TODO fail message
}

void dmfi_c_set()
{   //.set  TODO
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sCharacter = GetListItem(cv.Arguments, 1);

    if (!HasListItem(DMFI_COMMAND_SET_CHARACTERS), sCharacter);
    {
        //TODO send message
        return;
    }
    
    SetLocalObject(cv.oSpeaker, DMFI_COMMAND_SET + sCharacter, cv.oTarget);
    // TODO Message
}

void dmfi_c_dmtool()
{   //.dmt?  What else does dm do? TODO .dms? dm spy?
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    if (HasListItem(cv.sArguments, "lock"))
    {
        SetLocalInt(DMFI), DMFI_MODULE_LOCKED, TRUE)
        return;
    }

    if (HasListItem(cv.sArguments, "unlock"))
        SetLocalInt(DMFI), DMFI_MODULE_LOCKED, FALSE)
}

void dmfi_c_mute()
{   //.mut, .unm
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    int nMuted = GetLocalString(cv.oTarget, DMFI_MUTED);

    if (nMuted)
        DeleteLocalInt(cv.oTarget, DMFI_MUTED, FALSE);
    else
        SetLocalInt(cv.oTarget, DMFI_MUTED, TRUE);
}

void dmfi_c_freeze()
{   //.fre, .unf  TODO messaging
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    AssignCommand(cv.oTarget, ClearAllActions);

    if (GetCommandable(cv.oTarget))
        DelayCommand(0.2f, SetCommandable(FALSE, cv.oTarget));
    else
        DelayCommand(0.2f, SetCommandable(TRUE, cv.oTarget));
}

void dmfi_c_openinventory()
{   //.inv
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    OpenInventory(cv.oTarget, cv.oSpeaker);
}

void dmfi_c_follow()
{   //.fol
    //TODO message when stop following
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sDuration;
    int i, nDuration, nCount = CountList(cv.sArguments);

    for (i = 0; i < nCount; i++)
    {
        sDuration = GetListItem(cv.sArguments, i);

        if (TestStringAgainstPattern("*n", sDuration))
        {
            nDuration = StringToInt(sDuration))
            AssignCommand(cv.oTarget, ClearAllActions(TRUE));
            AssignCommand(cv.oTarget, ActionForceMoveToObject(cv.oSpeaker, TRUE, 1.0f, IntToFloat(nDuration)));
            return;
        }
    }
}

void dmfi_c_cleareffects()
{   //.rem      TODO not sure this really works, check well system on DM scripts
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables(); 

    effect e = GetFirstEffect(cv.oTarget);

    while (GetIsEffectValid(e))
    {
        RemoveEffect(cv.oTarget, e);
        e = GetNextEffect(cv.oTarget);
    }  
}

void dmfi_c_createobject()
{   //.ite, .pla, .npc
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sObject = GetListItem(cv.sArguments, 1);
    string sType = GetListItem(cv.sArguments, 0);
    int nObjectType = -1;
    object oObject;

    //TODO need a way to enumerate the possible values for item/placeable/etc.
    if (HasListItem("ite,item", sType)
    {
        oObject = CreateItemOnObject(sObject, cv.oTarget, 1);
        return;
    }
    else 
    {
        if (HasListItem("pla,placeable,place", sType))
            nObjectType = OBJECT_TYPE_PLACEABLE;
        else if (HasListItem("npc", sType)
            nObjectType = OBJECT_TYPE_CREATURE;

        if (nObjectType != -1)
            CreateObject(nObjectType, sObject, GetLocation(cv.oTarget))
    }
}

void dmfi_c_destroyobject()
{   //.dism
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    DestroyObject(cv.oTarget);
    //FloatingTextStringOnCreature(GetName(oTarget) + " dismissed", oCommander, FALSE); return;
}

void dmfi_c_disappear()
{    //.fly
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDisappear(), cv.oTarget);
}

void dmfi_c_flee()
{   //.fle
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    AssignCommand(cv.oTarget, ClearAllActions(TRUE));
    AssignCommand(cv.oTarget, ActionMoveAwayFromObject(cv.oSpeaker, TRUE));
}

void dmfi_c_setname()
{   //.name
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sName;

        // object oTgt = GetLocalObject(oCommander, "dmfi_univ_target");
    if (GetIsObjectValid(cv.oTarget))
    {
        if (HasListItem(cv.sArguments, "."))
            SetName(cv.oTarget);
        else
        {
            sName = StringParse(cv.oModifiedMessage, " ");
            sName = StringRemoveParsed(cv.oModifiedMessage, sName, " ");
            SetName(cv.oTarget, sName);
        }
    }
}

void dmfi_c_setdescription()
{   //.desc
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sDescription;

    if (GetIsObjectValid(cv.oTarget))
    {
        if (HasListItem(cv.sArguments, "."))
            SetDescription(cv.oTarget);
        else
        {
            sDescription = StringParse(cv.oModifiedMessage, " ");
            sDescription = StringRemoveParsed(cv.oModifiedMessage, sDescription, " ");
            SetDescription(cv.oTarget, sDescription);
        }
    }
}

void dmfi_c_playanimation()
{   //.ani -- does this for hours on end?  TODO
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sAnimation;
    int i, nAnimation, nCount = CountList(cv.sArguments);

    for (i = 0; i < nCount; i++)
    {
        sAnimation = GetListItem(cv.sArguments, i);

        if (TestStringAgainstPattern("*n", sAnimation))
        {
            nAnimation = StringToInt(sAnimation))
            AssignCommand(cv.oTarget, ClearAllActions(TRUE));
            AssignCommand(cv.oTarget, ActionPlayAnimation(nAnimation, 1.0, 99999.0f));
            return;
        }
    }
}

void dmfi_c_damage()
{
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sDamage;
    int i, nDamage, nCount = CountList(cv.sArguments);

    for (i = 0; i < nCount; i++)
    {
        sDamage = GetListItem(cv.sArguments, i);

        if (TestStringAgainstPattern("*n", sDamage))
        {
            nDamage = StringToInt(sDamage);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(iArg, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_NORMAL), cv.oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_BLOOD_LRG_RED), cv.oTarget);
            //TODO message about this;
            return;
        }
    }
}

void dmfi_c_heal()
{
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    string sDamage;
    int i, nDamage, nCount = CountList(cv.sArguments);

    for (i = 0; i < nCount; i++)
    {
        sDamage = GetListItem(cv.sArguments, i);

        if (TestStringAgainstPattern("*n", sDamage))
        {
            nDamage = StringToInt(sDamage);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(iArg), cv.oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEALING_M), cv.oTarget);
            //TODO message about this;
            return;
        }
    }
}

void dmfi_c_buff()
{
    struct DMFI_COMMAND_VARIABLES cv = dmfi_SetCommandVariables();

    int nParty = HasListItem(cv.sArguments, "party"));
    int nNPC = HasListItem(cv.sArguments, "npc:false"));
    //TODO there's gotta be a better way to do this.  Can I create an effect "set" to apply or, possibly
    //  a custom effect set applied in the DM only area?  Effects can only get tagged when they already
    //  exist somewhere, so might have to buff a dummy to do this.

    if (nParty)
        oPartyMember = GetFirstFactionMember(cv.oTarget, nNPC);
    else
        oPartyMember = oTarget;

    while (GetIsObjectValid(oPartyMember))
    {
        if (HasListItem(cv.sArguments, "immortal"))
        {
            SetImmortal(cv.oTarget, TRUE);
            //FloatingTextStringOnCreature("The target is set to Immortal (cannot die).", oSpeaker, FALSE);  
            
            if (nParty)
            {
                oPartyMember = GetNextFactionMember(cv.oTarget, nNPC);
                continue;
            }
            else
                return;
        }
        else if (HasListItem(cv.sArguments, "mortal"))
        {
            SetImmortal(cv.oTarget, TRUE);
            //FloatingTextStringOnCreature("The target is set to Mortal (can die).", oCommander, FALSE);
        }

        //TODO fix up all these messages, create messaging/logging system
        if (HasListItem(cv.sArguments, "plot") && !GetImmortal(cv.oTarget))
        {
            SetPlotFlag(cv.oTarget, TRUE);
            //FloatingTextStringOnCreature("The target is set to Plot.", oCommander, FALSE);
            
            if (nParty)
            {
                oPartyMember = GetNextFactionMember(cv.oTarget, nNPC);
                continue;
            }
            else
                return;
        }
        else if (HasListItem(cv.sArguments, "unplot"))
        {
            SetPlotFlag(cv.oTarget, FALSE);
            //FloatingTextStringOnCreature("The target is set to non-Plot.", cv.oSpeaker, FALSE);
        }

        //If immortal or plot at this point, the rest doesn't matter, save the processing power.
        if (GetImmortal(cv.oTarget) || GetPlotFlag(cv.oTarget))
        {
            if (nParty)
            {
                oPartyMember = GetNextFactionMember(cv.oTarget, nNPC);
                continue;
            }
            else
                return;
        }        

        //TODO find a better way to do list.  Can I create an effect "set"?
        if (HasListItem(cv.sArguments, "low"))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectACIncrease(3, AC_NATURAL_BONUS), cv.oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_PROT_BARKSKIN), cv.oTarget, 3600.0f);
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_RESISTANCE, cv.oTarget, METAMAGIC_ANY, TRUE, 5, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_GHOSTLY_VISAGE, cv.oTarget, METAMAGIC_ANY, TRUE, 5, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_CLARITY,  cv.oTarget,METAMAGIC_ANY, TRUE, 5, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            //FloatingTextStringOnCreature("Low Buff applied: " + GetName(cv.oTarget), cv.oSpeaker);   return;
        }
        else if (HasListItem(cv.sArguments, "mid"))
        {
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_LESSER_SPELL_MANTLE, cv.oTarget, METAMAGIC_ANY, TRUE, 10, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_STONESKIN, cv.oTarget, METAMAGIC_ANY, TRUE, 10, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_ELEMENTAL_SHIELD,  cv.oTarget,METAMAGIC_ANY, TRUE, 10, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            //FloatingTextStringOnCreature("Mid Buff applied: " + GetName(cv.oTarget), oCommander);  return;
        }
        else if (HasListItem(cv.sArguments, "high"))
        {
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_SPELL_MANTLE, cv.oTarget, METAMAGIC_ANY, TRUE, 15, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_STONESKIN, cv.oTarget, METAMAGIC_ANY, TRUE,15, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_SHADOW_SHIELD,  cv.oTarget,METAMAGIC_ANY, TRUE, 15, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            //FloatingTextStringOnCreature("High Buff applied: " + GetName(cv.oTarget), oCommander);  return;
        }
        else if (HasListItem(cv.sArguments, "epic"))
        {
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_GREATER_SPELL_MANTLE, cv.oTarget, METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_SPELL_RESISTANCE, cv.oTarget, METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_SHADOW_SHIELD,  cv.oTarget,METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            AssignCommand(cv.oTarget, ActionCastSpellAtObject(SPELL_CLARITY,  cv.oTarget,METAMAGIC_ANY, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            //FloatingTextStringOnCreature("Epic Buff applied: " + GetName(cv.oTarget), oCommander);  return;
        }

        //Take these out of the "else" loop and we can do more than one at a time.
        if (HasListItem(cv.sArguments, "barkskin"))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectACIncrease(3, AC_NATURAL_BONUS), cv.oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_PROT_BARKSKIN), cv.oTarget, 3600.0f);  return;
        }

        if (HasListItem(cv.sArguments, "elements"))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_COLD, 20, 40), cv.oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_FIRE, 20, 40), cv.oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_ACID, 20, 40), cv.oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_SONIC, 20, 40), cv.oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, 20, 40), cv.oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS), cv.oTarget, 3600.0f);  return;
        }

        if (HasListItem(cv.sArguments, "haste"))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectHaste(), cv.oTarget, 3600.0f);  return;
        }

        if (HasListItem(cv.sArguments, "invis"))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectInvisibility(INVISIBILITY_TYPE_NORMAL), cv.oTarget, 3600.0f);   return;
        }

        if (HasListItem(cv.sArguments, "stoneskin"))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDamageReduction(10, DAMAGE_POWER_PLUS_THREE, 100), cv.oTarget, 3600.0f);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_PROT_GREATER_STONESKIN), cv.oTarget, 3600.0f); return;
        }

        if (HasListItem(cv.sArguments, "trues"))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectTrueSeeing(), cv.oTarget, 3600.0f); return;
        }

        if (nParty)
            oPartyMember = GetNextFactionMember(cv.oTarget, nNPC);
        else
            return;
    }
}

string dmfi_TranslatePhrase(string sLanguage, string sPhrase))
{
    if(!GetLocalInt(DMFI, DMFI_LANGUAGE_INITIALIZED))
        dmfi_InitializeLanguages();
    
    int i, nIndex, nCount;
    string sCharacter, sRepeat, sTranslation;

    struct DMFI_LANGUAGE_ITEM liTranslateFrom, liTranslateTo;

    //Load common language.
    if (nIndex = FindListItem(DMFI_LANGUAGE_LOADED_CSV, DMFI_LANGUAGE_COMMON)
        liTranslateFrom = dmfi_GetLanguage(nIndex);
    else
    {
        Debug("DMFI: Unable to find common language.  Translation aborted.");
        return "";
    }

    //Get the language to translate to
    if(nIndex = FindListItem(DMFI_LANGUAGE_LOADED_CSV, sLanguage));
        liTranslateTo = dmfi_GetLanguage(nIndex);
    else
    {
        Debug("DMFI: Unable to find desired translation language.  Translation aborted.");
        return "";
    }

    select (liTranslateTo.nMode)
    {
        case DMFI_LANGUAGE_TRANSLATION_MODE_LETTER:
            if (nCount = GetStringLength(sPhrase))
            {
                for (i = 0; i < nCount; i++)
                {
                    sCharacter = GetSubString(sPhrase, i, 1);
                    nIndex = FindListItem(liTranslateFrom.sAlphabet, sCharacter);

                    if (nIndex != -1)
                        sTranslation += GetListItem(liTranslateTo.sAlphabet, nIndex);
                    else
                        sTranslation += sCharacter;
                }
            }

            return sTranslation;
        case DMFI_LANGUAGE_TRANSLATION_MODE_WORD:
            if (GetStringLength(sPhrase) && (nCount = dmfi_GetWordCount(sPhrase)))
            {
                //TODO add util_i_math include
                nCount = min(nCount, CountList(liTranslateTo.sAlphabet));

                for (i = 0; i < nCount; i++)
                {
                    sTranslation += GetListItem(liTranslateTo.sAlphabet, Random(nCount));)
                }

                return sTranslation;
            }
            else
            {
                Debug("DMFI, Invalid translation phrase length or word count.  Translation aborted.");
                return "";
            }
        case DMFI_LANGUAGE_TRANSLATION_MODE_REPEAT:
            if (nCount = GetStringLength(sPhrase))
            {
                if(CountList(liTranslateTo.sAlphabet))
                    sRepeat = GetListItem(liTranslateTo.sAlphabet, 0);
                else
                {
                    Debug("DMFI:  Valid character not found for requested translation mode.");
                    return "";
                }

                for (i = 0; i < nCount; i++)
                {
                    sCharacter = GetSubString(sPhrase, i);
                    
                    if (FindListItem(liTranslateFrom.sAlphabet, sCharacter))
                        sTranslation += sRepeat;
                    else
                        sTranslation += sCharacter;
                }
            }

            return sTranslation;
        default:
            Debug("Valid translation mode not found.  Translation aborted.");
            return "";
    }
}

void ParseEmote(string sEmote, object sSpeaker)
{
    //Check for muted emotes.
    //TODO check this before calling this procedure

    if (GetLocalInt(MODULE, "DMFI_SUPPRESS_EMOTES") ||
        GetLocalInt(oPC, "hls_emotemute"))
        return;

    DeleteLocalInt(oPC, "dmfi_univ_int");
    
    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
    object oLeftHand =  GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);

    if (GetStringLeft(sEmote, 1) == "*")
        sEmote = StringParse(sEmote, "*", TRUE);

    //Replace the long-ass list of emotes with a CSV.
    string sLCEmote = GetStringLowerCase(sEmote);

    //TODO find a way to do the emote rolls?
    //TODO can I give all these emotes the "item" treatmetn like languages
    //  and chat commands?  Makes it easy to add a new one or remove one?
    /*
    int i, nCount = CountList(DMFI_PC_CHECKS);
    for (i = 0; i < nCount; i++
    {
        if (FindSubString(sLCEmote, GetListItem(DMFI_PC_CHECKS, i)) != 1)
        {
            SetLocalInt(oPC, "dmfi_univ_int", 60 + i + (i/10));
            break;
        }
        
        if ((FindSubString(sLCEmote, "ride") != -1))
            SetLocalInt(oPC, "dmfi_univ_int", 90);
    }
    
    if (GetLocalInt(oPC, "dmfi_univ_int"))
    {
        SetLocalString(oPC, "dmfi_univ_conv", "pc_dicebag");
        ExecuteScript("dmfi_execute", oPC);
        return;
    }*/

    //*emote*  TODO replace oPC with oSpeaker
    if (HasListItem("bow,bows,curtsey", sEmote)
    {
        AssignCommand(oSpeaker, PlayAnimation(ANIMATION_FIREFORGET_BOW, 1.0));
        return;
    }

    if (HasListItem("drink,sips", sEmote)
    {
        AssignCommand(oSpeaker, PlayAnimation(ANIMATION_FIREFORGET_DRINK, 1.0));
        return;
    }
    

    if (HasListItem("drinks", sEmote)
    {
        AssignCommand(oSpeaker, ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0f));
        DelayCommand(1.0f, AssignCommand(oSpeaker, PlayAnimation(ANIMATION_FIREFORGET_DRINK, 1.0)));
        DelayCommand(3.0f, AssignCommand(oSpeaker, PlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0)));
        return;
    }       

    if (HasListItem("reads,sits", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation( ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0f));
        DelayCommand(1.0f, AssignCommand(oPC, PlayAnimation( ANIMATION_FIREFORGET_READ, 1.0)));
        DelayCommand(3.0f, AssignCommand(oPC, PlayAnimation( ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0)));
        return;
    }    

    if (HasListItem("sit"), sEmote)
    {
        AssignCommand(oSpeaker, ActionPlayAnimation( ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0f));
        return;
    }
    

    if (HasListItem("greet,wave,waves,greets", sEmote))
    {
        AssignCommand(oSpeaker, PlayAnimation(ANIMATION_FIREFORGET_GREETING, 1.0));
        return;
    }
    
    
    if (HasListItem("yawn,yawns,stretch,stretches,bored", sEmote))
    {
        AssignCommand(oSpeaker, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_BORED, 1.0));
        return;
    }
    

    if (HasListItem("scratch,scratches", sEmote))
    {
        AssignCommand(oPC,ActionUnequipItem(oRightHand));
        AssignCommand(oPC,ActionUnequipItem(oLeftHand));
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD, 1.0));
        return;
    }    

    if (HasListItem("read,reads", sEmote))
    {
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_READ, 1.0));    
        return;
    }
    

    if (HasListItem("salute", sEmote))
    {
        AssignCommand(oPC,ActionUnequipItem(oRightHand));
        AssignCommand(oPC,ActionUnequipItem(oLeftHand));
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_SALUTE, 1.0));
        return;
    }

    if (HasListItem("steal,swipe,steals,swipes"), sEmote)
    {
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_STEAL, 1.0));
        return;
    }
    

    if (HasListItem("taunt,taunts,mock,mocks", sEmote))
    {
        PlayVoiceChat(VOICE_CHAT_TAUNT, oPC);
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_TAUNT, 1.0));
        return;
    }    

    if (HasListItem("smokes,smoke", sEmote))
    {
        SmokePipe(oPC);        
        return;
    }
    
    if (HasListItem("cheers,cheers", sEmote))
    {
        PlayVoiceChat(VOICE_CHAT_CHEER, oPC);
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_VICTORY1, 1.0));
        return;
    }

    if (HasListItem("hooray", sEmote))
    {
        PlayVoiceChat(VOICE_CHAT_CHEER, oPC);
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_VICTORY2, 1.0));
        return;
    }

    if (HasListItem("celebrate,celebrates", sEmote))
    {
        PlayVoiceChat(VOICE_CHAT_CHEER, oPC);
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_VICTORY3, 1.0));
        return;
    }

    if (HasListItem("giggle,giggles", sEmote) && GetGender(oSpeaker) == GENDER_FEMALE)
    {
        AssignCommand(oPC, PlaySound("vs_fshaldrf_haha"));
        return;
    }
    

    if (HasListItem("flop,flopped,flops,giggles", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 99999.0));
        return;
    }
    

    if (HasListItem("bends,stoops", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW, 1.0, 99999.0));
        return;
    }
    

    if (HasListItem("fiddles,fiddles", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 5.0));
        return;
    }
    

    if (HasListItem("nods,nods,agree,agrees", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_LISTEN, 1.0, 4.0));
        return;
    }
    

    if (HasListItem("peer,peers,scan,scans,look,looks,search,searches", sEmote))
    {
        AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_LOOK_FAR, 1.0, 99999.0));
        return;
    }
    

    if (HasListItem("pray,prays,meditate,meditates", sEmote))
    {
        AssignCommand(oPC,ActionUnequipItem(oRightHand));
        AssignCommand(oPC,ActionUnequipItem(oLeftHand));
        AssignCommand(oPC,ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0, 99999.0));
        return;
    }

    if (HasListItem("drunk,woozy", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK, 1.0, 99999.0));
        return;
    }
    

    if (HasListItem("tired,fatigued,exhausted", sEmote))
    {
        PlayVoiceChat(VOICE_CHAT_REST, oPC);
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_TIRED, 1.0, 3.0));
        return;
    }

    if (HasListItem("fidget,fidgets,shifts", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE2, 1.0, 99999.0));
        return;
    }
    

    if (HasListItem("sits,floor,ground", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, 99999.0));
        return;
    }
    

    if (HasListItem("demand,demands,threaten,threatens", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_FORCEFUL, 1.0, 99999.0));
        return;
    }
    

    if (HasListItem("laugh,laughs,chuckle,chuckels", sEmote))
    {
        PlayVoiceChat(VOICE_CHAT_LAUGH, oPC);
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING, 1.0, 2.0));
        return;
    }

    if (HasListItem("beg,begs,plead,pleads", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_PLEADING, 1.0, 99999.0));
        return;
    }
    
    if (HasListItem("worship,worships", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_WORSHIP, 1.0, 99999.0));
         return;
    }
    
    if (HasListItem("snore,snores,nap,naps", sEmote))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLEEP), oPC);
        return;
    }
    
    if (HasListItem("sing,sings,hum,hums", sEmote))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_BARD_SONG), oPC, 6.0f);
        return;
    }
    
    if (HasListItem("whistles", sEmote))
    {
        AssignCommand(oPC, PlaySound("as_pl_whistle2"));
        return;
    }
    
    if (HasListItem("talks,chat,chats", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_NORMAL, 1.0, 99999.0));
        return;
    }
    
    if (HasListItem("shakes head", sEmote))   //TODO !! values with spaces
    {
        AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 1.0, 0.25f));
        DelayCommand(0.15f, AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, 1.0, 0.25f)));
        DelayCommand(0.40f, AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 1.0, 0.25f)));
        DelayCommand(0.65f, AssignCommand(oPC, PlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, 1.0, 0.25f)));
        return;
    }

    if (HasListItem("duck,ducks", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_DODGE_DUCK, 1.0, 99999.0));
        return;
    }
    
    if (HasListItem("dodge,dodges", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_DODGE_SIDE, 1.0, 99999.0));
        return;
    }
    
    if (HasListItem("cantrip", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE1, 1.0, 99999.0));
        return;
    }
    
    if (HasListItem("spellcast", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE2, 1.0, 99999.0));
        return;
    }
    
    if (HasListItem("fall,falls,back", sEmote))
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 99999.0));
        return;
    }
    
    if (HasListItem("spasm", sEmote))
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_SPASM, 1.0, 99999.0));
}

// TODO apply DM-visual only effect on a PC when that NPC is the target for action or voice?


void ParseCommand(object oTarget, object oSpeaker, string sModifiedMessage, string sArguments)
{
// :: 2008.07.31 morderon / tsunami282 - allow certain . commands for
// ::     PCs as well as DM's; allow shortcut targeting of henchies/pets

    //int iOffset=0;
    if (_GetIsDM(oTarget) && (oTarget != oSpeaker)) 
        return; //DMs can only be affected by their own .commands

    //TODO see if this is checked for before parsecommand is called.
    if (!GetIsObjectValid(oTarget));
    {
        DMFISendMessageToPC(oCommander, "No current command target - no commands will function.", FALSE, DMFI_MESSAGE_COLOR_ALERT);
        return;
    }

    string sScript, sCommand = GetListItem(sArguments, 0);
    if ((nIndex = FindListString(DMFI, sCommand, CHAT_COMMAND_LIST)) != -1)
    {
        sScript = GetListString(DMFI, nIndex, CHAT_SCRIPT_LIST);

        //set up variables
        SetLocalString(oSpeaker, TODO, sArguments);
        SetLocalString(oSpeaker, TODO, GetStringLowerCase(sModifiedMessage));
        SetLocalObject(oSpeaker, TODO, oTarget);

        ExecuteScript(sScript, oSpeaker);

        // Cleanup
        DeleteLocalString(oSpeaker, TODO);
        DeleteLocalString(oSpeaker, TODO);
        DeleteLocalObject(oSpeaker, TODO);
    }

    //That's it for this portion.  Inidividual item scripts and functions should check
    //  for DM status as required.  We're not going to do it at this level.
    // TODO create a template function for building new command functions.
    //Still need to incorporate the following into individual functions.

    else if (GetStringLeft(sCom, 4) == ".say")
    {
        int iArg = StringToInt(sArgs);
        if (GetDMFIPersistentString("dmfi", "hls206" + IntToString(iArg)) != "")
        {
            AssignCommand(oTarget, SpeakString(GetDMFIPersistentString("dmfi", "hls206" + IntToString(iArg))));
        }
        return;
    }
    else if (GetStringLeft(sCom, 4) == ".tar")
    {
        object oGet = GetFirstObjectInArea(GetArea(oCommander));
        while (GetIsObjectValid(oGet))
        {
            if (FindSubString(GetName(oGet), sArgs) != -1)
            {
                // SetLocalObject(oCommander, "dmfi_VoiceTarget", oGet);
                SetLocalObject(oCommander, "dmfi_univ_target", oGet);
                FloatingTextStringOnCreature("You have targeted " + GetName(oGet) + " with the DMFI Targeting Widget", oCommander, FALSE);
                return;
            }
            oGet = GetNextObjectInArea(GetArea(oCommander));
        }
        FloatingTextStringOnCreature("Target not found.", oCommander, FALSE);
        return;
    }



    else if (GetStringLeft(sCom, 5) == ".vtar")
    {
        object oGet = GetFirstObjectInArea(GetArea(oCommander));
        while (GetIsObjectValid(oGet))
        {
            if (FindSubString(GetName(oGet), sArgs) != -1)
            {
                SetLocalObject(oCommander, "dmfi_VoiceTarget", oGet);
                FloatingTextStringOnCreature("You have targeted " + GetName(oGet) + " with the Voice Widget", oCommander, FALSE);
                return;
            }
            oGet = GetNextObjectInArea(GetArea(oCommander));
        }
        FloatingTextStringOnCreature("Target not found.", oCommander, FALSE);
        return;
    }
}

void dmfi_OnPlayerChat()
{
    object oVoiceTarget, oActionTarget, oTarget, oSpeaker = GetPCChatSpeaker();
    string sCommand, sVoiceCommand, sActionCommand, sSpeakerHooks = GetLocalString(oSpeaker, DMFI_HOOK);
    string sArguments, sModifiedMessage, sOriginalMessage = GetPCChatMessage();
    int i, nCount, nArguments, nHandle, nChannel = GetPCChatVolume();
    float fDistance;
    
    //This loops through the hooks assigned to the chatting pc to determine
    //  if there are any hooks to be satisfied.  If there are any assigned
    //  hooks, they are executed as required.  If not, the section is skipped
    //  for performance reasons.
    if (nCount = CountList(sSpeakerHooks))
    {
        //Loop the PC's list and grab those specific hooks to be satisfied.
        for (i = 0; i < nCount; i++)
        {
            nHandle = StringToInt(GetListItem(sSpeakerHooks, i));
            if nHandle <= DMFI_HOOK_HANDLE_SPLIT
                dmfi_HandleChatHook(nHandle); 
            else
                dmfi_HandleListenerHook(nHandle);
        }
    }

    //Let's pause for a moment.  There is A LOT of code after this, so let's do
    //  some quick checks to see if we need to run any of it.
    // we only want to continue if we have this:
    sModifiedMessage = TrimString(sOriginalMessage);
    sCommand = GetStringLeft(sModifiedMessage, 2);

    //Need to check for custom setting (!@#$, etc.)
    if (!dmfi_IsCommand(sCommand))
        return;
    else if (dmfi_IsEmoteCommand(sCommand) && 
                (DMFI_MODULE_EMOTES_MUTED || 
                 dmfi_GetSetting(oSpeaker, DMFI_SETTING_EMOTES_MUTED)) 
    {
        if (DMFI_MODULE_EMOTED_MUTED)
            //Message to PC - module emotes are muted TODO
        else
            //Message to PC - your emotes are muted, to change type .emoy in the chat bar

        return;
    }

    //Let's take a minute to figure out what type of commands we have
    if (dmfi_IsVoiceActionPair(sCommand))
    {
        sVoiceCommand = GetStringLeft(sCommand, 1);
        sActionCommand = GetStringRight(sCommand, 1);
    }
    else if (dmfi_IsVoiceCommand(sCommand))
    {
        sVoiceCommand = GetStringLeft(sCommand, 1);
        sCommand = sVoiceCommand;
        sActionCommand = "";
    }
    else if (dmif_IsActionCommand(sCommand))
    {
        sVoiceCommand = "";
        sActionCommand = GetStringLeft(sCommand, 1);
        sCommand = sActionCommand;
    }

    //Remove all dmfi commands from the message so we have raw arguments to work with
    sModifiedMessage = StringRemoveParsed(sModifiedMessage, sCommand, sCommand);
    sModifiedMessage = TrimString(sModifiedMessage);
    sArguments = dmfi_GetArgumentsList(sModifiedMessage, " ");
    nArguments = CountList(sArguments);  //TODO am i using this for anything?
    //Ok, so now we have the command character(s), a CSV of all the arguments, the original
    //  message, the modified message.  I think that's everything we need.

     // pass on any heard text to registered listeners
    // since listeners are set by DM's, pass the raw unprocessed command text to them
    // TODO Thisis the old send to eavesdropper function.  Integrate.

    //TODO See if i'm splitting or jointing lists anywhere and use SM's
    //  functions instead.

    //TODO channel shouldn't matter, right?  If the PC is trying to use a command,
    //  we want it to work no matter what channel they're typing it on.  We can't
    //  intercept Tells anyway, so why worry about the channel for PC usage?
    //  Understandable for listening for specific into

    // now see if we have a command to parse
    // special chars:
    //     [ = speak in alternate language
    //     * = perform emote
    //     : = throw voice to last designated target
    //     ; = throw voice to master / animal companion / familiar / henchman / summon
    //     , = throw voice summon / henchman / familiar / animal companion / master
    //     . = command to execute

    // TODO - check includes.
    
    //Find the right target for the command ...
    // TODO - use wand to set voice or action target?

    if (sVoiceCommand != "")
    {
        int i = ASSOCIATE_TYPE_HENCHMAN;
        
        if (sVoiceCommand == ":")  //TODO is this a DM only command?
            oVoiceTarget = _GetIsDM(oSpeaker) ? GetLocalObject(oSpeaker, DMFI_TARGET_VOICE) : oSpeaker;

        if (sVoiceCommand == ";")
        {
            oVoiceTarget = GetMaster(oSpeaker);

            while (!GetIsObjectValid(oVoiceTarget) && i <= ASSOCIATE_TYPE_DOMINATED)
            {
                oVoiceTarget = GetAssociate(i, oSpeaker);
                i++;
            }
        }

        if (sVoiceCommand == ",")
        {
            i = ASSOCIATE_TYPE_DOMINATED;
            while (!GetIsObjectValid(oVoiceTarget) && i >= ASSOCIATE_TYPE_HENCHMAN)
            {
                oVoiceTarget = GetAssociate(i, oSpeaker);
                i--;
            }

            if (!GetIsObjectValid(oVoiceTarget))
                oVoiceObject = GetMaster(oSpeaker);
        }
    }

    // ok, now we *might* have a voice target, how's about an action target?
    // if we have a target and there's not a command, just send the rest of the
    //  text to the target.  If we have a target and there's is a command, let's
    //  press to make that command happen.
    if (sActionCommand == "" && GetIsObjectValid(oVoiceTarget))
    {
        //Ok, there's no action to be taken, just send the text and be done with it.
        AssignCommand(oVoiceTarget, SpeakString(sModifiedMessage, nChannel))
        return;
    }    
    else {}
            //TODO warn of no voice target

    //If we're here, we either have voice target (or not), but we do have a
    //  command to accomplish.
    //TODO figure out this targeting stuff.
    if (!GetIsTargetValid(oTarget))
    {
        if (sActionCommand == DMFI_ACTION_EMOTE || sActionCommand == DMFI_ACTION_LANGUAGE)
            oTarget = oSpeaker;
    }

    // We could still have an invalid target here, say for a PC using a .
    //  that hasn't targeted anyone yet.
    if (!GetIsTargetvalid(oTarget))
    {
        Warning("Warning - No target, command aborted");
        return;
    }

    if (sActionCommand == DMFI_ACTION_COMMAND)
    {   //Command
        //TODO ParseCommand rewrite
        ParseCommand(oTarget, oSpeaker, sModifiedMessage, sArguments);
    }
    else if (sActionCommand == DMFI_ACTION_EMOTE)
    {   //Emote
        //TODO Pareseemote rewrite
        ParseEmote(sMessage, oTarget);
    }   
    else if (sActionCommand == DMFI_ACTION_LANGUAGE)
    {   //Language
        //TODO go through this function and change out how languages
        //  are assigned and kept.  Probably need to keep in the database
        //  like the settings.
        //TODO pull/push languages known on login/logout.
        sModifiedMessage = TranslateToLanguage(sModifiedMessage, oTarget, nChannel, oSpeaker);
        AssignCommand(oTarget, SpeakString(sModifiedMessage, nChannel));
    }

    // TODO work through this constant, it isn't mine.
    if (DMFI_LOG_CONVERSATION)
        //Send this message somehwere.  Currently goes to log file with no stamp.
        Debug("<DMFI Conversation Log Entry>" +
            "\n  Speaker (" + _GetIsDM(oSpeaker) ? "DM" : "PC") + "): " + GetName(oSpeaker) +
            "\n  Area: " + GetName(GetArea(oSpeaker)) +
            "\n  Original Message: " + sOriginalMessage +
            "\n  Modified Messsage: " + sModifiedMessage == "" ? "(empty string)" : sModifiedMessage);

    SetPCChatMessage();
}

// ----- Tag-based scripting -----

//::///////////////////////////////////////////////
//:: DMFI - widget activation processor
//:: dmfi_activate
//:://////////////////////////////////////////////
/*
  Functions to respond and process DMFI item activations.
*/
//:://////////////////////////////////////////////
//:: Created By: The DMFI Team
//:: Created On:
//:://////////////////////////////////////////////
//:: 2008.05.25 tsunami282 - changes to invisible listeners to work with
//::                         OnPlayerChat methods.
//:: 2008.07.10 tsunami282 - add Naming Wand to the exploder.
//:: 2008.08.15 tsunami282 - move init logic to new include.

#include "util_i_debug"
#include "dmfi_init_inc"

////////////////////////////////////////////////////////////////////////
void dmw_CleanUp(object oMySpeaker)
{
   int nCount;
   int nCache;
   DeleteLocalObject(oMySpeaker, "dmfi_univ_target");
   DeleteLocalLocation(oMySpeaker, "dmfi_univ_location");
   DeleteLocalObject(oMySpeaker, "dmw_item");
   DeleteLocalString(oMySpeaker, "dmw_repamt");
   DeleteLocalString(oMySpeaker, "dmw_repargs");
   nCache = GetLocalInt(oMySpeaker, "dmw_playercache");
   
   for(nCount = 1; nCount <= nCache; nCount++)
   {
      DeleteLocalObject(oMySpeaker, "dmw_playercache" + IntToString(nCount));
   }
   DeleteLocalInt(oMySpeaker, "dmw_playercache");
   
   nCache = GetLocalInt(oMySpeaker, "dmw_itemcache");
   for(nCount = 1; nCount <= nCache; nCount++)
   {
      DeleteLocalObject(oMySpeaker, "dmw_itemcache" + IntToString(nCount));
   }
   DeleteLocalInt(oMySpeaker, "dmw_itemcache");
   
   for(nCount = 1; nCount <= 10; nCount++)
   {
      DeleteLocalString(oMySpeaker, "dmw_dialog" + IntToString(nCount));
      DeleteLocalString(oMySpeaker, "dmw_function" + IntToString(nCount));
      DeleteLocalString(oMySpeaker, "dmw_params" + IntToString(nCount));
   }
   DeleteLocalString(oMySpeaker, "dmw_playerfunc");
   DeleteLocalInt(oMySpeaker, "dmw_started");
}

void main()
{
    object oUser = OBJECT_SELF;
    object oItem = GetLocalObject(oUser, "dmfi_item");
    object oOther = GetLocalObject(oUser, "dmfi_target");
    location lLocation = GetLocalLocation(oUser, "dmfi_location");
    string sItemTag = GetTag(oItem);

    //This is done OML and OCE, why call this again here?
    //dmfiInitialize(oUser);

    dmw_CleanUp(oUser);

    if (GetStringLeft(sItemTag, 8) == "hlslang_")
    {
        // Remove voice stuff
        string ssLanguage = GetStringRight(sItemTag, GetStringLength(sItemTag) - 8);
        SetLocalInt(oUser, "hls_MyLanguage", StringToInt(ssLanguage));
        SetLocalString(oUser, "hls_MyLanguageName", GetName(oItem));
        DelayCommand(1.0f, FloatingTextStringOnCreature("You are speaking " + GetName(oItem) + ". Type [(what you want to say in brackets)]", oUser, FALSE));
        return;
    }
}

//TODO - figure out this rest thing and get rid of it?
void dmfi_wand_pc_rest()
{
    CreateObject(OBJECT_TYPE_PLACEABLE, "dmfi_rest" + GetStringRight(sItemTag, 3), GetLocation(oUser));
    return;
}

//TODO - this thing
void dmfi_wand_pc_follow()  
{
    if (GetIsObjectValid(oOther))
    {
        FloatingTextStringOnCreature("Now following "+ GetName(oOther), oUser, FALSE);
        DelayCommand(2.0f, AssignCommand(oUser, ActionForceFollowObject(oOther, 2.0f)));
    }
    return;
}

//TODO remove exploder functionality.  Just use the two wands (targeting/voice)
//  or one wand if we can manage it.
/*void dmfi_wand_exploder()
{
    if(!_GetIsDM(oUser))
        return;

    //Ensure the DM has all of the wands in his inventory.
    int i, nCount = CountList(DMFI_DM_ITEM_INVENTORY);

    for (i = 0; i < nCount; i++)
    {
        sWand = DMFI_WAND_ITEM_PREFIX + GetListItem(DMFI_DM_WAND_INVENTORY, i);
        if(!GetIsObjectValid(GetItemPossessedBy(oOther), sWand))
            CreateItemOnObject(sWand, oOther);
    }

    nCount = CountList(DMFI_WAND_REMOVE)

    for (i = 0; i < nCount; i++)
    {
        sWand = GetListItem(DMFI_WAND_REMOVE, i);
        object oWand = GetItemPossessedBy(oOther, sWand);
        if(GetIsObjectValid(oWand))
            DestroyObject(oWand);
    }
    return;
}*/

void dmfi_wand_peace()
{   //This widget sets all creatures in the area to a neutral stance and clears combat.
    object oPC, oArea = GetArea(oUser);
    object oObject = GetFirstObjectInArea(oArea);

    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !_GetIsPC(oObject))
        {
            AssignCommand(oObject, ClearAllActions());
            oPC = GetFirstPC();
            while (GetIsObjectValid(oPC))
            {
                if (GetArea(oPC) == GetArea(oObject))
                {
                    ClearPersonalReputation(oObject, oPC);
                    SetStandardFactionReputation(STANDARD_FACTION_HOSTILE, 25, oPC);
                    SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 91, oPC);
                    SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 91, oPC);
                    SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 91, oPC);
                }
                oPC = GetNextPC();
            }
            AssignCommand(oObject, ClearAllActions());
        }
        oObject = GetNextObjectInArea(oArea);
    }
}

void dmfi_wand_voice()
{
    object oVoice;
    if (GetIsObjectValid(oOther)) // do we have a valid target creature?
    {
        // 2008.05.29 tsunami282 - we don't use creature listen stuff anymore
        SetLocalObject(oUser, "dmfi_VoiceTarget", oOther);

        FloatingTextStringOnCreature("You have targeted " + GetName(oOther) + " with the Voice Widget", oUser, FALSE);

        if (GetLocalInt(GetModule(), "dmfi_voice_initial")!=1)
        {
            SetLocalInt(GetModule(), "dmfi_voice_initial", 1);
            SendMessageToAllDMs("Listening Initialized:  .commands, .skill checks, and much more now available.");
            DelayCommand(4.0, FloatingTextStringOnCreature("Listening Initialized:  .commands, .skill checks, and more available", oUser));
        }
        return;
    }
    else // no valid target of voice wand
    {
        //Jump any existing Voice attached to the user
        if (GetIsObjectValid(GetLocalObject(oUser, "dmfi_StaticVoice")))
        {
            DestroyObject(GetLocalObject(oUser, "dmfi_StaticVoice"));
        }
        //Create the StationaryVoice
        object oStaticVoice = CreateObject(OBJECT_TYPE_CREATURE, "dmfi_voice", GetLocation(oUser));
        //Set Ownership of the Voice to the User
        SetLocalObject(oUser, "dmfi_StaticVoice", oVoice);
        SetLocalObject(oUser, "dmfi_VoiceTarget", oStaticVoice);
        DelayCommand(1.0f, FloatingTextStringOnCreature("A Stationary Voice has been created.", oUser, FALSE));
        return;
    }
    return;
}

void dmfi_wand_mute()
{
    SetLocalObject(oUser, "dmfi_univ_target", oUser);
    SetLocalString(oUser, "dmfi_univ_conv", "voice");
    SetLocalInt(oUser, "dmfi_univ_int", 8);
    ExecuteScript("dmfi_execute", oUser);
    return;
}

void dmfi_wand_encounter_ditto()
{
    SetLocalObject(oUser, "dmfi_univ_target", oOther);
    SetLocalLocation(oUser, "dmfi_univ_location", lLocation);
    SetLocalString(oUser, "dmfi_univ_conv", "encounter");
    SetLocalInt(oUser, "dmfi_univ_int", GetLocalInt(oUser, "EncounterType"));
    ExecuteScript("dmfi_execute", oUser);
    return;
}

void dmfi_wand_target()
{
    SetLocalObject(oUser, "dmfi_univ_target", oOther);
    FloatingTextStringOnCreature("DMFI Target set to " + GetName(oOther),oUser);
}

void dmfi_wand_remove()
{
    object oKillMe;
    //Targeting Self
    if (oUser == oOther)
    {
        oKillMe = GetNearestObject(OBJECT_TYPE_PLACEABLE, oUser);
        FloatingTextStringOnCreature("Destroyed " + GetName(oKillMe) + "(" + GetTag(oKillMe) + ")", oUser, FALSE);
        DelayCommand(0.1f, DestroyObject(oKillMe));
    }
    else if (GetIsObjectValid(oOther)) //Targeting something else
    {
        FloatingTextStringOnCreature("Destroyed " + GetName(oOther) + "(" + GetTag(oOther) + ")", oUser, FALSE);
        DelayCommand(0.1f, DestroyObject(oOther));
    }
    else //Targeting the ground
    {
        int iReport = 0;
        oKillMe = GetFirstObjectInShape(SHAPE_SPHERE, 2.0f, lLocation, FALSE, OBJECT_TYPE_ALL);
        while (GetIsObjectValid(oKillMe))
        {
            iReport++;
            DestroyObject(oKillMe);
            oKillMe = GetNextObjectInShape(SHAPE_SPHERE, 2.0f, lLocation, FALSE, OBJECT_TYPE_ALL);
        }
        FloatingTextStringOnCreature("Destroyed " + IntToString(iReport) + " objects.", oUser, FALSE);
    }
    return;
}

void dmfi_wand_500xp()
{
    SetLocalObject(oUser, "dmfi_univ_target", oOther);
    SetLocalLocation(oUser, "dmfi_univ_location", lLocation);
    SetLocalString(oUser, "dmfi_univ_conv", "xp");
    SetLocalInt(oUser, "dmfi_univ_int", 53);
    ExecuteScript("dmfi_execute", oUser);
    return;
}

void dmfi_wand_jail()
{
    if (GetIsObjectValid(oOther) && !_GetIsDM(oOther) && oOther != oUser)
    {
        object oJail = GetObjectByTag("dmfi_jail");
        if (!GetIsObjectValid(oJail))
            oJail = GetObjectByTag("dmfi_jail_default");
        AssignCommand(oOther, ClearAllActions());
        AssignCommand(oOther, JumpToObject(oJail));
        SendMessageToPC(oUser, GetName(oOther) + " (" + GetPCPublicCDKey(oOther) + ")/IP: " + GetPCIPAddress(oOther) + " - has been sent to Jail.");
    }
    return;
}

void dmfi_wand_encounter()
{

    if (GetIsObjectValid(GetWaypointByTag("DMFI_E1")))
        SetCustomToken(20771, GetName(GetWaypointByTag("DMFI_E1")));
    else
        SetCustomToken(20771, "Encounter Invalid");
    if (GetIsObjectValid(GetWaypointByTag("DMFI_E2")))
        SetCustomToken(20772, GetName(GetWaypointByTag("DMFI_E2")));
    else
        SetCustomToken(20772, "Encounter Invalid");
    if (GetIsObjectValid(GetWaypointByTag("DMFI_E3")))
        SetCustomToken(20773, GetName(GetWaypointByTag("DMFI_E3")));
    else
        SetCustomToken(20773, "Encounter Invalid");
    if (GetIsObjectValid(GetWaypointByTag("DMFI_E4")))
        SetCustomToken(20774, GetName(GetWaypointByTag("DMFI_E4")));
    else
        SetCustomToken(20774, "Encounter Invalid");
    if (GetIsObjectValid(GetWaypointByTag("DMFI_E5")))
        SetCustomToken(20775, GetName(GetWaypointByTag("DMFI_E5")));
    else
        SetCustomToken(20775, "Encounter Invalid");
    if (GetIsObjectValid(GetWaypointByTag("DMFI_E6")))
        SetCustomToken(20776, GetName(GetWaypointByTag("DMFI_E6")));
    else
        SetCustomToken(20776, "Encounter Invalid");
    if (GetIsObjectValid(GetWaypointByTag("DMFI_E7")))
        SetCustomToken(20777, GetName(GetWaypointByTag("DMFI_E7")));
    else
        SetCustomToken(20777, "Encounter Invalid");
    if (GetIsObjectValid(GetWaypointByTag("DMFI_E8")))
        SetCustomToken(20778, GetName(GetWaypointByTag("DMFI_E8")));
    else
        SetCustomToken(20778, "Encounter Invalid");
    if (GetIsObjectValid(GetWaypointByTag("DMFI_E9")))
        SetCustomToken(20779, GetName(GetWaypointByTag("DMFI_E9")));
    else
        SetCustomToken(20779, "Encounter Invalid");
}

void dmfi_wand_afflict()
{
    int nDNum;

    nDNum = GetLocalInt(oUser, "dmfi_damagemodifier");
    SetCustomToken(20780, IntToString(nDNum));
}

/*
SetLocalObject(oUser, "dmfi_univ_target", oOther);
SetLocalLocation(oUser, "dmfi_univ_location", lLocation);
SetLocalString(oUser, "dmfi_univ_conv", GetStringRight(sItemTag, GetStringLength(sItemTag) - 5));
AssignCommand(oUser, ClearAllActions());
AssignCommand(oUser, ActionStartConversation(OBJECT_SELF, "dmfi_universal", TRUE, FALSE));
}*/
