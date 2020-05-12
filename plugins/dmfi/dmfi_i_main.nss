//::///////////////////////////////////////////////
//:: DMFI - OnPlayerChat functions processor
//:: dmfi_plychat_exe
//:://////////////////////////////////////////////
/*
  Processor for the OnPlayerChat-triggered DMFI functions.
*/
//:://////////////////////////////////////////////
//:: Created By: The DMFI Team
//:: Created On:
//:://////////////////////////////////////////////
//:: 2007.12.12 Merle
//::    - revisions for NWN patch 1.69
//:: 2008.03.24 tsunami282
//::    - renamed from dmfi_voice_exe, updated to work with event hooking system
//:: 2008.06.23 Prince Demetri & Night Journey
//::    - added languages: Sylvan, Mulhorandi, Rashemi
//:: 2008.07.30 morderon
//::    - better emote processing, allow certain dot commands for PC's

#include "x2_inc_switches"
#include "x0_i0_stringlib"
#include "dmfi_string_inc"
#include "dmfi_plchlishk_i"
#include "dmfi_db_inc"

#include "x3_inc_string"
#include "dmfi_i_util"

const int DMFI_LOG_CONVERSATION = TRUE; // turn on or off logging of conversation text

////////////////////////////////////////////////////////////////////////
void dmw_CleanUp(object oMySpeaker)
{
    int nCount;
    int nCache;
    //_DeleteLocalObject(oMySpeaker, "dmfi_univ_target");
    _DeleteLocalLocation(oMySpeaker, "dmfi_univ_location");
    _DeleteLocalObject(oMySpeaker, "dmw_item");
    _DeleteLocalString(oMySpeaker, "dmw_repamt");
    _DeleteLocalString(oMySpeaker, "dmw_repargs");
    nCache = _GetLocalInt(oMySpeaker, "dmw_playercache");
    for (nCount = 1; nCount <= nCache; nCount++)
    {
        _DeleteLocalObject(oMySpeaker, "dmw_playercache" + IntToString(nCount));
    }
    _DeleteLocalInt(oMySpeaker, "dmw_playercache");
    nCache = _GetLocalInt(oMySpeaker, "dmw_itemcache");
    for (nCount = 1; nCount <= nCache; nCount++)
    {
        _DeleteLocalObject(oMySpeaker, "dmw_itemcache" + IntToString(nCount));
    }
    _DeleteLocalInt(oMySpeaker, "dmw_itemcache");
    for (nCount = 1; nCount <= 10; nCount++)
    {
        _DeleteLocalString(oMySpeaker, "dmw_dialog" + IntToString(nCount));
        _DeleteLocalString(oMySpeaker, "dmw_function" + IntToString(nCount));
        _DeleteLocalString(oMySpeaker, "dmw_params" + IntToString(nCount));
    }
    _DeleteLocalString(oMySpeaker, "dmw_playerfunc");
    _DeleteLocalInt(oMySpeaker, "dmw_started");
}

////////////////////////////////////////////////////////////////////////
//Smoking Function by Jason Robinson
location GetLocationAboveAndInFrontOf(object oPC, float fDist, float fHeight)
{
    float fDistance = -fDist;
    object oTarget = (oPC);
    object oArea = GetArea(oTarget);
    vector vPosition = GetPosition(oTarget);
    vPosition.z += fHeight;
    float fOrientation = GetFacing(oTarget);
    vector vNewPos = AngleToVector(fOrientation);
    float vZ = vPosition.z;
    float vX = vPosition.x - fDistance * vNewPos.x;
    float vY = vPosition.y - fDistance * vNewPos.y;
    fOrientation = GetFacing(oTarget);
    vX = vPosition.x - fDistance * vNewPos.x;
    vY = vPosition.y - fDistance * vNewPos.y;
    vNewPos = AngleToVector(fOrientation);
    vZ = vPosition.z;
    vNewPos = Vector(vX, vY, vZ);
    return Location(oArea, vNewPos, fOrientation);
}

////////////////////////////////////////////////////////////////////////
//Smoking Function by Jason Robinson
void SmokePipe(object oActivator)
{
    string sEmote1 = "*puffs on a pipe*";
    string sEmote2 = "*inhales from a pipe*";
    string sEmote3 = "*pulls a mouthful of smoke from a pipe*";
    float fHeight = 1.7;
    float fDistance = 0.1;
    // Set height based on race and gender
    if (GetGender(oActivator) == GENDER_MALE)
    {
        switch (GetRacialType(oActivator))
        {
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HALFELF: fHeight = 1.7; fDistance = 0.12; break;
        case RACIAL_TYPE_ELF: fHeight = 1.55; fDistance = 0.08; break;
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING: fHeight = 1.15; fDistance = 0.12; break;
        case RACIAL_TYPE_DWARF: fHeight = 1.2; fDistance = 0.12; break;
        case RACIAL_TYPE_HALFORC: fHeight = 1.9; fDistance = 0.2; break;
        }
    }
    else
    {
        // FEMALES
        switch (GetRacialType(oActivator))
        {
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HALFELF: fHeight = 1.6; fDistance = 0.12; break;
        case RACIAL_TYPE_ELF: fHeight = 1.45; fDistance = 0.12; break;
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING: fHeight = 1.1; fDistance = 0.075; break;
        case RACIAL_TYPE_DWARF: fHeight = 1.2; fDistance = 0.1; break;
        case RACIAL_TYPE_HALFORC: fHeight = 1.8; fDistance = 0.13; break;
        }
    }
    location lAboveHead = GetLocationAboveAndInFrontOf(oActivator, fDistance, fHeight);
    // emotes
    switch (d3())
    {
    case 1: AssignCommand(oActivator, ActionSpeakString(sEmote1)); break;
    case 2: AssignCommand(oActivator, ActionSpeakString(sEmote2)); break;
    case 3: AssignCommand(oActivator, ActionSpeakString(sEmote3)); break;
    }
    // glow red
    AssignCommand(oActivator, ActionDoCommand(ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_LIGHT_RED_5), oActivator, 0.15)));
    // wait a moment
    AssignCommand(oActivator, ActionWait(3.0));
    // puff of smoke above and in front of head
    AssignCommand(oActivator, ActionDoCommand(ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), lAboveHead)));
    // if female, turn head to left
    if ((GetGender(oActivator) == GENDER_FEMALE) && (GetRacialType(oActivator) != RACIAL_TYPE_DWARF))
        AssignCommand(oActivator, ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 1.0, 5.0));
}

////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
string ConvertCustom(string sLetter, int iRotate)
{
    if (GetStringLength(sLetter) > 1)
        sLetter = GetStringLeft(sLetter, 1);

    //Functional groups for custom languages
    //Vowel Sounds: a, e, i, o, u
    //Hard Sounds: b, d, k, p, t
    //Sibilant Sounds: c, f, s, q, w
    //Soft Sounds: g, h, l, r, y
    //Hummed Sounds: j, m, n, v, z
    //Oddball out: x, the rarest letter in the alphabet

    string sTranslate = "aeiouAEIOUbdkptBDKPTcfsqwCFSQWghlryGHLRYjmnvzJMNVZxX";
    int iTrans = FindSubString(sTranslate, sLetter);
    if (iTrans == -1) return sLetter; //return any character that isn't on the cipher

    //Now here's the tricky part... recalculating the offsets according functional
    //letter group, to produce an huge variety of "new" languages.

    int iOffset = iRotate % 5;
    int iGroup = iTrans / 5;
    int iBonus = iTrans / 10;
    int iMultiplier = iRotate / 5;
    iOffset = iTrans + iOffset + (iMultiplier * iBonus);

    return GetSubString(sTranslate, iGroup * 5 + iOffset % 5, 1);
}//end ConvertCustom

////////////////////////////////////////////////////////////////////////
string ProcessCustom(string sPhrase, int iLanguage)
{
    string sOutput;
    int iToggle;
    while (GetStringLength(sPhrase) > 1)
    {
        if (GetStringLeft(sPhrase,1) == "*")
            iToggle = abs(iToggle - 1);
        if (iToggle)
            sOutput = sOutput + GetStringLeft(sPhrase,1);
        else
            sOutput = sOutput + ConvertCustom(GetStringLeft(sPhrase, 1), iLanguage);
        sPhrase = GetStringRight(sPhrase, GetStringLength(sPhrase)-1);
    }
    return sOutput;
}

string dmfi_SortListString(string sList)
{
    int i, j, nLarger, nCount = CountList(sList);
    string sCurrent, sCompare, sSortList = "DMFI_SORT_LIST";

    DeclareStringList(DMFI, nCount, sSortList);

    for (i = 0; i < nCount; i++)
    {
        nLarger = 0;
        sCurrent = GetListItem(sList, i);

        for (j = 0; j < nCount; j++)
        {
            if (i == j)
                continue;

            sCompare = GetListItem(sList, j);
            if ((sCompare < sCurrent) || (sCompare == sCurrent && i < j))
                nLarger++;
        }

        SetListString(DMFI, nLarger, sCurrent, sSortList);
    }

    sList = JoinList(DMFI, sSortList);
    DeleteStringList(DMFI, sSortList);

    return sList;
}





////////////////////////////////////////////////////////////////////////
//Marshall the request.

void ParseCommand(object oActionTarget, object oPC, string sArguments)
{
// :: 2008.07.31 morderon / tsunami282 - allow certain . commands for
// ::     PCs as well as DM's; allow shortcut targeting of henchies/pets

    string sValue, sCommandList, sCommand, sArgument, sLanguage;
    int i, nCount, iOffset = 0

    //TODO exactly how do these offsets work and why.  document.
    //int iOffset=0;

    //Check case if PC is trying to target a DM
    if (_GetIsDM(oActionTarget) && oActionTarget != oPC)
        return;

    // break into command and args
    sCommandList = dmfi_GetArgumentList(sArguments, " ");
    sCommand = GetListItem(sCommandList, 0);
    sArgument = GetListItem(sCommandList, 1);
    
    //TODO more tokens!
    // ** commands usable by everyone
    //Dicebag stuff
    if (HasListItem("loc,local,glo,global,pri,private,dm", sCommand)
    {
        if (HasListItem("loc,local", sCommand)
            sValue = "LOCAL";
        else if (HasListItem("glo,global", sCommand))
            sValue = "GLOBAL";
        else if (HasListItem("pri,private"), sCommand))
            sValue = "PRIVATE";
        else if sCommand = "dm"
            sValue = "DM";

        dmfi_SetSettingString(oPC, DMFI_SETTING_DICEBAG, sValue);
        return;
    }

    if (HasListItem("aniy,anin", sCommand))
    {
        dmfi_SetSettingString(oPC, DMFI_SETTING_DICEBAG_ANIMATION, 
            GetStringRight(sCommand, 1) == "y" ? "TRUE" : "FALSE")
        return;
    }

    if (HasListItem("emoy,emon"), sCommand)
    {
        dmfi_SetSettingString(oPC, DMFI_SETTING_DMFI_SETTING_EMOTES_MUTED,
            GetStringRight(sCommand, 1) == "y", "FALSE" : "TRUE");
        return;
    }

    if (HasListItem("lan,language"), sCommand)
    {
        //TODO set language variable on pc during login and when new langauges are learned
        //Was a language provided?
        if (sArgument == "")
            //Error, no language provided
            return;
        
        //Is the target valid for the player type?
        if (!(_GetIsDM(oPC) || oActionTarget == oPC || GetMaster(oActionTarget) == oPC))
            //Error, can't do that!
            return;

        //Ok, let's figure out which language they want to translate to
        sArgument = GetStringLeft(sArgument, 16 - GetStringLength(DMFI_LANGUAGE_ITEM_PREFIX));

        //See if the language is on our list of loaded languages (which might different
        //  form our list of installed languages)
        //The fastest way to do this is to use the full language name and compare
        //  it to the installed language list.
        //Should be using _LOADED here because we're assigning a language to speak,
        //  not just awarding a language.
        if(!_GetLocalInt(DMFI, DMFI_LANGUAGE_INITIALIZED))
            dmfi_InitializeLanguages();

        if (HasListItem(DMFI_LANGUAGE_LOADED_CSV, sArgument))
            sLanguage = sArgument;
        else
        {
            if (nCount = CountObjectList(DMFI_LANGUAGE_OBJECT))
            {
                for (i = 0; i < nCount; i++)
                {
                    int nLanguageIndex;
                    oLanguageItem = GetListObject(DMFI, i, DMFI_LANGUAGE_OBJECT)
                    sLanguageAbbreviation = _GetLocalString(oLanguageItem, DMFI_LANGUAGE_ABBREVIATION);
                    if (sArgument == sLanguageAbbreviation)
                    {
                        sLanguage = _GetLocalString(oLanguageItem, DMFI_LANGUAGE_NAME);
                        break;
                    }
                    else if (nLanguageIndex = _GetLocalString(oLanguageItem, DMFI_LANGUAGE_INDEX))
                    {
                        if (nLanguageIndex == _GetLocalInt(oLanguageItem, DMFI_LANGUAGE_INDEX))
                        {
                            sLanguage = _GetLocalString(oLanguageItem, DMFI_LANGUAGE_NAME);
                            break;
                        }    
                        
                    }
                }
            }
        }

        if (sLanguage != "")
        {
            if (dmfi_AssignCurrentLanguage(oActionTarget, oPC, sLanguage))
                //TODO Send Message to PC saying they're speaking a different language.
                return;
            else
                //TDOO send failur message
                return;
        }
    }

    //Ok that's the end of PC commands, now to DM only commdns.  iOffset hasn't been used yet.
    // that's all the PC commands, bail out if not DM
    if (!_GetIsDM(oPC))
        return;

    if (HasListItem("app,appear"), sCommand)
    {
        int nAppearance;
        string sAppearance;
        
        if (TestStringAgainstPattern("*n", sArgument))
        {
            nAppearance = StringToInt(sArgument);
        }
        else
        {
            //Unlike previous behavior, let's just use the appearance.2da.  This will allow
            // custom worlds to use whatever hak they feel like using without being limited to
            //  the standard NWN list.  This is the hard way, but it works.  
            i = 0;
            //TODO need some serious work for custom worlds, cannot be limited to standard nwn stuff.
            //  will probably need 2da stuff.  how to loop a 2da even when "" is returned for *****
            
            while (1)
            {
                if (Get2DAString("appearance", "NAME", i) == "")
                {
                    nAppearance = -1;
                    break;
                }
                else if (GetStringUpperCase(sArgument) == Get2DAString("appearance", "LABEL", i))
                {
                    nAppearance = i;
                    break;
                }
            }
        }

        if (nAppearance != -1)
            SetCreatureAppearanceType(oActionTarget, i);
        else
            //Raise error
            //return;

        dmw_CleanUp(oCommander);
        return;
    }

    //Ok, now checking for pc checks.  Easy way is if it's all spelled out, but we'll see
    //  Special cases like .use magic device won't work because of the way the string is parsed.
    //  We'll treat those with special cases after checking for the rest.  Since we're going to load
    //  all the skills from the 2da, there can't be any spaces.  This is going to be a limitation
    //  for entry, but will greatly expand the cpaiblity of the system.  TODO how will these offsets
    //  work when the list isn't predefined?  What exactly are the offsets?
    if (nCount = CountList(DMFI_SKILLS))
        dmfi_LoadSkills();
    
    if (nIndex = FindListItem(DMFI_SKILLS, sArgument) != -1)
        iOffset = nIndex + 10 + (nIndex/10);
    

    if(!iOffset)
    {
        //We didn't find anything the easy way.  let's try reducing the 
    }

    {
        sAbbreviatedList = dmfi_AbbreviateList(DMFI_PC_CHECKS, 4);



    }


    if (iOffset)
    {
        if (FindSubString(sCom, "all") != -1 || FindSubString(sArgs, "all") != -1)
            _SetLocalInt(oCommander, "dmfi_univ_int", iOffset+40);
        else
            _SetLocalInt(oCommander, "dmfi_univ_int", iOffset);

        _SetLocalString(oCommander, "dmfi_univ_conv", "dicebag");
        if (GetIsObjectValid(oTarget))
        {
            if (oTarget != _GetLocalObject(oCommander, "dmfi_univ_target"))
            {
                _SetLocalObject(oCommander, "dmfi_univ_target", oTarget);
                FloatingTextStringOnCreature("DMFI Target set to "+GetName(oTarget), oCommander);
            }
            ExecuteScript("dmfi_execute", oCommander);
        }
        else
        {
            DMFISendMessageToPC(oCommander, "No valid DMFI target!", FALSE, DMFI_MESSAGE_COLOR_ALERT);
        }

        dmw_CleanUp(oCommander);
        return;
    }






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
                // _SetLocalObject(oCommander, "dmfi_VoiceTarget", oGet);
                _SetLocalObject(oCommander, "dmfi_univ_target", oGet);
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
                _SetLocalObject(oCommander, "dmfi_VoiceTarget", oGet);
                FloatingTextStringOnCreature("You have targeted " + GetName(oGet) + " with the Voice Widget", oCommander, FALSE);
                return;
            }
            oGet = GetNextObjectInArea(GetArea(oCommander));
        }
        FloatingTextStringOnCreature("Target not found.", oCommander, FALSE);
        return;
    }
}


////////////////////////////////////////////////////////////////////////
int RelayTextToEavesdropper(object oShouter, int nVolume, string sSaid)
{
// arguments
//  (return) - flag to continue processing text: X2_EXECUTE_SCRIPT_CONTINUE or
//             X2_EXECUTE_SCRIPT_END
//  oShouter - object that spoke
//  nVolume - channel (TALKVOLUME) text was spoken on
//  sSaid - text that was spoken

    int bScriptEnd = X2_EXECUTE_SCRIPT_CONTINUE;

    // sanity checks
    if (GetIsObjectValid(oShouter))
    {
        int iHookToDelete = 0;
        int iHookType = 0;
        int channels = 0;
        int rangemode = 0;
        string siHook = "";
        object oMod = MODULE;
        int iHook = 1;
        while (1)
        {
            siHook = IntToString(iHook);
            iHookType = _GetLocalInt(oMod, sHookTypeVarname+siHook);
            if (iHookType == 0) break; // end of list

            // check channel
            channels = _GetLocalInt(oMod, sHookChannelsVarname+siHook);
            if (((1 << nVolume) & channels) != 0)
            {
                string sVol = (nVolume == TALKVOLUME_WHISPER ? "whispers" : "says");
                object oOwner = _GetLocalObject(oMod, sHookOwnerVarname+siHook);
                if (GetIsObjectValid(oOwner))
                {
                    // it's a channel for us to listen on, process
                    int bcast = _GetLocalInt(oMod, sHookBcastDMsVarname+siHook);
                    // for type 1, see if speaker is the one we want (pc or party)
                    // for type 2, see if speaker says his stuff within ("earshot" / area / module) of listener's location
                    if (iHookType == 1) // listen to what a PC hears
                    {
                        object oListener;
                        location locShouter, locListener;
                        object oTargeted = _GetLocalObject(oMod, sHookCreatureVarname+siHook);
                        if (GetIsObjectValid(oTargeted))
                        {
                            rangemode = _GetLocalInt(oMod, sHookRangeModeVarname+siHook);
                            if (rangemode) oListener = GetFirstFactionMember(oTargeted, FALSE); // everyone in party are our listeners
                            else oListener = oTargeted; // only selected PC is our listener
                            while (GetIsObjectValid(oListener))
                            {
                                // check speaker:
                                // check within earshot
                                int bInRange = FALSE;
                                locShouter = GetLocation(oShouter);
                                locListener = GetLocation(oListener);
                                if (oShouter == oListener)
                                {
                                    bInRange = TRUE; // the target can always hear himself
                                }
                                else if (GetAreaFromLocation(locShouter) == GetAreaFromLocation(locListener))
                                {
                                    float dist = GetDistanceBetweenLocations(locListener, locShouter);
                                    if ((nVolume == TALKVOLUME_WHISPER && dist <= WHISPER_DISTANCE) ||
                                        (nVolume != TALKVOLUME_WHISPER && dist <= TALK_DISTANCE))
                                    {
                                        bInRange = TRUE;
                                    }
                                }
                                if (bInRange)
                                {
                                    // relay what's said to the hook owner
                                    string sMesg = "("+GetName(GetArea(oShouter))+") "+GetName(oShouter)+" "+sVol+": "+sSaid;
                                    // if (bcast) SendMessageToAllDMs(sMesg);
                                    // else SendMessageToPC(oOwner, sMesg);
                                    DMFISendMessageToPC(oOwner, sMesg, bcast, DMFI_MESSAGE_COLOR_EAVESDROP);
                                }
                                if (rangemode == 0) break; // only check the target creature for rangemode 0
                                if (bInRange) break; // once any party member hears shouter, we're done
                                oListener = GetNextFactionMember(oTargeted, FALSE);
                            }
                        }
                        else
                        {
                            // bad desired speaker, remove hook
                            iHookToDelete = iHook;
                        }
                    }
                    else if (iHookType == 2) // listen at location
                    {
                        location locShouter, locListener;
                        object oListener = _GetLocalObject(oMod, sHookCreatureVarname+siHook);
                        if (oListener != OBJECT_INVALID)
                        {
                            locListener = GetLocation(oListener);
                        }
                        else
                        {
                            locListener = _GetLocalLocation(oMod, sHookLocationVarname+siHook);
                        }
                        locShouter = GetLocation(oShouter);
                        rangemode = _GetLocalInt(oMod, sHookRangeModeVarname+siHook);
                        int bInRange = FALSE;
                        if (rangemode == 0)
                        {
                            // check within earshot
                            if (GetAreaFromLocation(locShouter) == GetAreaFromLocation(locListener))
                            {
                                float dist = GetDistanceBetweenLocations(locListener, locShouter);
                                if ((nVolume == TALKVOLUME_WHISPER && dist <= WHISPER_DISTANCE) ||
                                    (nVolume != TALKVOLUME_WHISPER && dist <= TALK_DISTANCE))
                                {
                                    bInRange = TRUE;
                                }
                            }
                        }
                        else if (rangemode == 1)
                        {
                            // check within area
                            if (GetAreaFromLocation(locShouter) == GetAreaFromLocation(locListener)) bInRange = TRUE;
                        }
                        else
                        {
                            // module-wide
                            bInRange = TRUE;
                        }
                        if (bInRange)
                        {
                            // relay what's said to the hook owner
                            string sMesg = "("+GetName(GetArea(oShouter))+") "+GetName(oShouter)+" "+sVol+": "+sSaid;
                            // if (bcast) SendMessageToAllDMs(sMesg);
                            // else SendMessageToPC(oOwner, sMesg);
                            DMFISendMessageToPC(oOwner, sMesg, bcast, DMFI_MESSAGE_COLOR_EAVESDROP);
                        }
                    }
                    else
                    {
                        Debug("ERROR: DMFI OnPlayerChat handler: invalid iHookType; removing hook.");
                        iHookToDelete = iHook;
                    }
                }
                else
                {
                    // bad owner, delete hook
                    iHookToDelete = iHook;
                }
            }

            iHook++;
        }

        // remove a bad hook: note we can only remove one bad hook this way, have to rely on subsequent calls to remove any others
        if (iHookToDelete > 0)
        {
            RemoveListenerHook(iHookToDelete);
        }
    }

    return bScriptEnd;
}
