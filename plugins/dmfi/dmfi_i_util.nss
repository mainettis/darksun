// -----------------------------------------------------------------------------
//    File: x.nss
//  System: x (constants)
//     URL:
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Constants for PW Subsystem.
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

#include "x3_inc_string"
#include "dmfi_i_const"
#include "util_i_debug"
#include "dmfi_i_csvlists"
#include "dsutil_i_data"

// ---< dmfi_InitializeSystem >---
// This function will cycle through CSVs in INIT_LIST and loads pointers to their
//  objects on the DMFI data object.  This function can be run multiple times
//  if the INIT_LIST is modified, but requires bForce = TRUE in order to bypass
//  the initialization check to ensure we're not wasting resources.
int dmfi_InitializeSystem(string INIT_LIST, string LOADED_LIST, string ITEM_PREFIX,
                          string OBJECT_LIST, string INIT_FLAG, int bForce = FALSE)
{
    int i, iItemCount, nCount = CountList(INIT_LIST);
    object oItem;
    string sItem, sItems;

    if (_GetLocalInt(DMFI, INIT_FLAG) && !bForce)
        return TRUE;

    _DeleteLocalString(DMFI, LOADED_LIST);
    if (!nCount)
        return FALSE;

    //Since we'll be using these for conversation, sort them in alphabetical order
    //TODO can these lists be sorted?
    /*if (DMFI_SORT_LIST)
        INIT_LIST = dmfi_SortListString(INIT_LIST);*/

    for (i = 0; i < nCount; i++)
    {
        sItem = GetListItem(INIT_LIST, i);
        sItem = GetStringLeft(sItem, 16 - GetStringLength(ITEM_PREFIX));
        oItem = CreateItemOnObject(ITEM_PREFIX + sItem, DMFI);

        if (GetIsObjectValid(oItem))
        {
            if (AddListObject(DMFI, oItem, OBJECT_LIST, TRUE))
                sItems = AddListItem(sItems, sItem);
            else
                Warning("DFMI: Item '" + GetTag(oItem) + "' found but not " +
                    "loaded due to item duplication.  Check the install list.");
        }
        else
            Warning("DMFI: Item '" + sItem + "' not found.");
    }

    iItemCount = CountObjectList(DMFI, OBJECT_LIST);

    //TODO - list sort?
    //TODO create a subsystem to the util_i_debug to manage communications through the pw.
    /*Debug("DMFI:  Successfully loaded " + iItemCount + " items." +
        (iItemCount == nCount ? "\n  All items on the install list have been loaded." :
        "\n  Unable to find valid items for " + nCount - iItemCount " languages."*/

    _SetLocalString(DMFI, LOADED_LIST, sItems);
    _SetLocalInt(DMFI, INIT_FLAG, TRUE);

    return iItemCount;
}

// ---< dmfi_GetDefaultSetting >---
// Returns the default setting for the passed sSetting given the object oPC.
string dmfi_GetDefaultSetting(object oPC, string sSetting)
{
    if(!_GetLocalInt(oPC, DMFI_INITIALIZED))
        return "";

    Debug("DMFI :: Setting Default " + sSetting + " value for " + GetName(oPC));

    string sRet, sDefaults = DMFI_DEFAULT_PC_SETTINGS;
    if(_GetIsDM(oPC))
        sDefaults = DMFI_DEFAULT_DM_SETTINGS;

    return csv_GetKeyValueString(sDefaults, sSetting);
}

// ---< dmfi_PushSettings >---
// The DMFI user settings are stored in a variable on the user for quick access
//  and server performance reasons.  When the settings are changed, the database
//  is not updated to reflect the changes until the user logs out or the update
//  is forced.  This function updates the database user setting values with those
//  from the variable in the user's PC object.
void dmfi_PushSettings(object oPC)
{
    if(!_GetLocalInt(oUser, DMFI_INITIALIZED))
        return;

    string sSettings = _GetLocalString(oUser, DMFI_USER_SETTINGS);
    SetDatabaseString(DMFI_USER_SETTINGS, sSettings, oPC);
}

// ---< dmfi_PullSettings >---
// The DMFI user settings are normally stored in a variable on the user object
//  for performance reasons.  This function will pull the entire settings variable
//  from the database.
string dmfi_PullSettings(object oPC)
{
    return GetDatabaseString(DMFI_USER_SETTINGS, oPC);
}

// ---< dmfi_SetSetting >---
// Internal function called by dmfi_SetSetting[Int,Float,String].
//  This function will pull the user settings from the user's local
//  settings variable, find the appropriate setting, and change the
//  setting to the desired value.  If the setting is not found,
//  a new setting is added.  The settings are then re-saved on the
//  user's local variable.  If bForce, the settings are retrieved
//  from the database instead of the user variable and set in both
//  the database and user variable.
int dmfi_SetSetting(object oPC, string sSetting, string sValue, int bForce)
{
    if(!_GetLocalInt(oPC, DMFI_INITIALIZED))
        return FALSE;

    Debug("DMFI :: Setting " + (bForce ? "persistent " : "") + sSetting +
            " for " + GetName(oPC));

    string sUserSettings = _GetLocalString(oPC, DMFI_USER_SETTINGS);
    string sNewSetting = sSetting + ":" + sValue;

    if(bForce)
        sUserSettings = GetDatabaseString(DMFI_USER_SETTINGS, oPC);

    if(csv_HasKeyValuePair(sUserSettings, sSetting) > -1)
        csv_SetKeyValueString(sUserSettings, sSetting, sValue);
    else
        Debug("DMFI :: Unable to set " + (bForce ? "persistent " : "") +
            sSetting + ".  Key:Value Pair does not exist.");

    _SetLocalString(oPC, DMFI_USER_SETTINGS, sUserSettings);

    if(bForce)
        SetDatabaseString(DMFI_USER_SETTINGS, sUserSettings, oPC);

    return TRUE;
}

int dmfi_SetSettingString(object oPC, string sSetting, string sValue, int bForce = FALSE)
{
    return dmfi_SetSetting(oPC, sSetting, sValue, bForce);
}

int dmfi_SetSettingInt(object oPC, string sSetting, int nValue, int bForce = FALSE)
{
    string sValue = IntToString(nValue);
    return dmfi_SetSetting(oPC, sSetting, sValue, bForce);
}

int dmfi_SetSettingFloat(object oPC, string sSetting, float fValue, int bForce = FALSE)
{
    string sValue = FloatToString(fValue);
    return dmfi_SetSetting(oPC, sSetting, sValue, bForce);
}

// ---< dmfi_DeleteSetting >---
// This function checks the objects settings variable for the passed setting.
//  A new settings string will be set to the object's variable upon completion.
//  If bUseDefault, the setting will be replaced with the value from the
//      default list.  This is recommended so settings don't go missing.  If
//      FALSE, error-checking is required to ensure all required settings are
//      present.
//  If bForce, the settings string will be source from the database entry for
//      the passed object unless it does not exist, in which case the object's
//      settings variable will be used.  If neither has the string value set,
//      an empty string is returned.  Upon completion, the new settings string
//      will be set to the object's setting variable and to the database.
string dmfi_DeleteSetting(object oPC, string sSetting, int bUseDefault = TRUE, int bForce = FALSE)
{
    if(!_GetLocalInt(oPC, DMFI_INITIALIZED))
        return "";

    /*Debug("DMFI :: Deleting " + (bForce ? "persistent " : ""() + sSetting) +
        " for " + GetName(oPC) + (bUseDefault ? " and replacing with default." : "."));*/

    string sValue, sUserSettings = _GetLocalString(oPC, DMFI_USER_SETTINGS);
    if (bForce)
        sUserSettings = GetDatabaseString(DMFI_USER_SETTINGS, oPC);

    if (sUserSettings == "")
        return "";

    if (csv_HasKeyValuePair(sUserSettings, sSetting) > -1)
    {
        sUserSettings = csv_RemoveKeyValuePair(sUserSettings, sSetting);
        if(bUseDefault)
        {
            sValue = dmfi_GetDefaultSetting(oPC, sSetting);
            if (sValue != "")
                sUserSettings = csv_SetKeyValueString(sUserSettings, sSetting, sValue);
            else
                Warning("DMFI :: Default setting " + sSetting + " does not exist.");
        }

        _SetLocalString(oPC, DMFI_USER_SETTINGS, sUserSettings);
        if (bForce)
            SetDatabaseString(DMFI_USER_SETTINGS, sUserSettings, oPC);
    }

    return sUserSettings;
}

// ---< dmfi_GetSetting >---
// Internal function called by dmfi_GetSetting[Int,Float,String].  This function
//  will pull user settings from a variable on the object oPC and return the
//  value for the passed sSetting.
// If bForce, the settings will be sourced from the database instead of oPC's
//  settings variable.
string dmfi_GetSetting(object oPC, string sSetting, int bForce)
{
    if(!_GetLocalInt(oPC, DMFI_INITIALIZED))
        return "";

    string sCurrentSetting, sUserSettings = _GetLocalString(oPC, DMFI_USER_SETTINGS);

    if(!bForce)
        sUserSettings = GetDatabaseString(DMFI_USER_SETTINGS, oPC);

    return csv_GetKeyValueString(sUserSettings, sSetting);
}

// ---< dmfi_GetSettingInt >---
// This function pulls the int-based setting value from the user setting
//  variable stored on oPC.
// If bForce, the value is sourced from the database.
int dmfi_GetSettingInt(object oPC, string sSetting, int bForce = FALSE)
{
    string sValue = dmfi_GetSetting(oPC, sSetting, bForce);

    if(sValue == "FALSE")
        return FALSE;

    if(sValue == "TRUE")
        return TRUE;

    if(sValue != "")
        return StringToInt(sValue);
    else
        Warning("DMFI :: Key:Value pair for " + sSetting + " not found.");

    return -1;
}

// ---< dmfi_GetSettingFloat >---
// This function pulls the float-based setting value from the user setting
//  variable stored on oPC.
// If bForce, the value is sourced from the database.
float dmfi_GetSettingFloat(object oPC, string sSetting, int bForce = FALSE)
{
    string sValue = dmfi_GetSetting(oPC, sSetting, bForce);

    if(sValue != "")
        return StringToFloat(sValue);
    else
        Warning("DMFI :: Key:Value pair for " + sSetting + " not found.");

    return -1.0;
}

// ---< dmfi_GetSettingString >---
// This function pulls the string-based setting value from the user setting
//  variable stored on oPC.
// If bForce, the value is sourced from the database.
string dmfi_GetSettingString(object oPC, string sSetting, int bForce = FALSE)
{
    sSetting = dmfi_GetSetting(oPC, sSetting, bForce);
    if (sSetting != "")
        return sSetting;
    else
        Warning("DMFI :: Key:Value pair for " + sSetting + " not found.");

    return "";
}

// ---< dmfi_SetDefaultSettings >---
// This function will set a setting string in the database attached to
//  the user.  If the setting string already exists, it will be replaced
//  with the default settings as defind in DMFI_DEFAULT_SETTINGS.
void dmfi_SetDefaultSettings(object oPC, int bForce = FALSE)
{
    Debug("DMFI:  Initializing default settings for " /*+player*/);

    string sSettings = DMFI_DEFAULT_PC_SETTINGS;
    if (_GetIsDM(oPC))
        sSettings = DMFI_DEFAULT_DM_SETTINGS;

    _SetLocalString(oPC, DMFI_USER_SETTINGS, sSettings);

    if (bForce)
        SetDatabaseString(DMFI_USER_SETTINGS, sSettings, oPC);

    //TODO Custom Tokens, see original scripts.
}

struct DMFI_CHATHOOK dmfi_GetChatHook(int nHandle)
{
    int nIndex = FindListInt(DMFI, nHandle, DMFI_CHATHOOK_HANDLE);
    struct DMFI_CHATHOOK ch;

    if (nIndex != -1)
    {
        ch.nHandle = GetListInt(DMFI, nIndex, DMFI_CHATHOOK_HANDLE);
        ch.nChannels = GetListInt(DMFI, nIndex, DMFI_CHATHOOK_CHANNELS);
        ch.bListenAll = GetListInt(DMFI, nIndex, DMFI_CHATHOOK_LISTENALL);
        ch.bAutoRemove = GetListInt(DMFI, nIndex, DMFI_CHATHOOK_AUTOREMOVE);
        ch.sScript = GetListString(DMFI, nIndex, DMFI_CHATHOOK_SCRIPT);
        ch.oScriptRunner = GetListObject(DMFI, nIndex, DMFI_CHATHOOK_RUNNER);
        ch.oSpeaker = GetListObject(DMFI, nIndex, DMFI_CHATHOOK_SPEAKER);
    }

    return ch;
}

struct DMFI_LISTENER_HOOK dmfi_GetListenerHook(int nHandle)
{
    int nIndex = FindListInt(DMFI, nHandle, DMFI_LISTENER_HANDLE);
    struct DMFI_LISTENER_HOOK lh;

    if (nIndex)
    {
        lh.nHandle = GetListInt(DMFI, nIndex, DMFI_LISTENER_HANDLE);
        lh.nType = GetListInt(DMFI, nIndex, DMFI_LISTENER_TYPE);
        lh.nChannels = GetListInt(DMFI, nIndex, DMFI_LISTENER_CHANNELS);
        lh.nRange = GetListInt(DMFI, nIndex, DMFI_LISTENER_RANGE);
        lh.bBroadcast = GetListInt(DMFI, nIndex, DMFI_LISTENER_BROADCAST);
        lh.oCreature = GetListObject(DMFI, nIndex, DMFI_LISTENER_CREATURE);
        lh.oOwner = GetListObject(DMFI, nIndex, DMFI_LISTENER_OWNER);
        lh.lLocation = GetListLocation(DMFI, nIndex, DMFI_LISTENER_LOCATION);
    }

    return lh;
}

// ---< dmfi_IsVoiceCommand >---
// Returns TRUE if sCommand is a valid voice command character.
int dmfi_IsVoiceCommand(string sCommand)
{
    sCommand = TrimString(sCommand);
    sCommand = GetStringLeft(sCommand, 1);

    return (HasListItem(DMFI_COMMAND_VOICE_COMMANDS, sCommand) || sCommand == ",");
}

// ---< dmfi_IsActionCommand >---
// Returns TRUE if sCommand is a valid action command character.
int dmfi_IsActionCommand(string sCommand)
{
    sCommand = TrimString(sCommand);
    sCommand = GetStringLeft(sCommand, 1);

    return HasListItem(DMFI_COMMAND_ACTION_COMMANDS, sCommand);
}

// ---< dmfi_IsVoiceActionPair >---
// Returns TRUE if sCommand is a voice/action pairing such as ;*.  This is used
//  to determine if the PC is attempting to have an object under their control,
//  such as a familiar, conduct a specific action.
int dmfi_IsVoiceActionPair(string sCommand)
{
    string sVoiceCommand, sActionCommand;

    if (GetStringLength(sCommand) != 2)
        return FALSE;
    else
    {
        sVoiceCommand = GetStringLeft(sCommand, 1);
        sActionCommand = GetStringRight(sCommand, 1);

        if (dmfi_IsVoiceCommand(sVoiceCommand) &&
            dmfi_IsActionCommand(sActionCommand))
            return TRUE;
        else
            return FALSE;
    }
}

// ---< dmfi_IsEmoteCommand >---
// Returns TRUE if sCommand appears to be a valid attempt to conduct an emote.
int dmfi_IsEmoteCommand(string sCommand)
{
    sCommand = TrimString(sCommand);
    sCommand = GetStringLeft(sCommand, 2);

    if (GetStringLength(sCommand) == 1)
    {
        if (sCommand == DMFI_COMMAND_EMOTE)
            return TRUE;
    }
    else if (dmfi_IsVoiceActionPair(sCommand) && 
                GetStringRight(sCommand, 1) == DMFI_COMMAND_EMOTE)
        return TRUE;

    return FALSE;
}

// ---< dmfi_IsCommand >---
// Returns TRUE if sCommand is a registered command character.  This does not
//  determine if it is a valid command such as .get, .set, etc., only whether
//  the prefixed character(s) are valid command characters (. ; : etc.);
int dmfi_IsCommand(string sCommand)
{
    return (dmfi_IsVoiceCommand(sCommand) || dmfi_IsActionCommand(sCommand));
}

// ---< dmfi_GetLanguage >---
// Returns a struct DMFI_LANGUAGE_ITEM variable containing the variables set
//  on language initializer items.
struct DMFI_LANGUAGE_ITEM dmfi_GetLanguage(int nIndex)
{
    struct DMFI_LANGUAGE_ITEM li;
    object oLanguageItem = GetListObject(DMFI, nIndex, DMFI_LANGUAGE_ITEMS_OBJECT_LIST);

    li.nMode = _GetLocalInt(oLanguageItem, DMFI_LANGUAGE_ITEM_TRANSLATION_MODE);
    li.sName = _GetLocalString(oLanguageItem, DMFI_LANGUAGE_ITEM_NAME);
    li.sAbbreviation = _GetLocalString(oLanguageItem, DMIF_LANGUAGE_ITEM_ABBREVIATION);
    li.sAlphabet = _GetLocalString(oLanguageItem, DMFI_LANGUAGE_ITEM_ALPHABET);
    li.nActive = _GetLocalString(oLanguageItem, DMFI_LANGUAGE_ITEM_ACTIVE);

    return li;
}

// ---< dmfi_GetWordCount >---
// Attempts to count the number of words in a phrase, assuming a space as a
//  delimiter.  Compares by character to ensure we're not sending bad
//  info in case of multiple spaces in a phrase.
int dmfi_GetWordCount(string sPhrase)
{
    int nLength, nCount, nIndex = 0;
    string sCurrentCharacter, sNextCharacter;

    if (nLength = GetStringLength(sPhrase))
    {
        while (nIndex < (nLength - 1))
        {
            sNextCharacter = GetSubString(sPhrase, nIndex + 1, 1);

            if (sNextCharacter == " ")
                nCount++;

            nIndex++;
        }

        return nIndex++;
    }
    else
        return 0;
}

// ---< dmfi_AssignKnownLanguages >---
// Assigns sLanguage as a known language on PC oActionTarget.  Known languages
//  do not need to be set on NPCs.  Returns TRUE if the language was set,
//  FALSE if not. If bForce, the languages known variable will be set to the
//  database.
int dmfi_AssignKnownLanguages(object oActionTarget, string sLanguage, int bForce = FALSE)
{
    if(!_GetLocalInt(oActionTarget, DMFI_INITIALIZED))
        return FALSE;
    
    if (!_GetIsPC(oActionTarget))
        return FALSE;

    if (bForce)
        sList = GetDatabaseString(DMFI_LANGUAGE_KNOWN, oActionTarget);
    else
        string sList = _GetLocalString(oActionTarget, DMFI_LANGUAGE_KNOWN);

    if (!CountList(sList))
        sList = DMFI_LANGUAGE_ITEM_COMMON;
    else
        sList = AddListItem(sList, sLanguage, TRUE);

    _SetLocalString(oActionTarget, DMFI_LANGUAGE_KNOWN, sList);
    if (bForce)
        SetDatabaseString(DMFI_LANGUAGE_KNOWN, sList, oActionTarget);

    return TRUE;

}

// ---< dmfi_PullKnownLanguages >---
// Pulls known languages from the database.
string dmfi_PullKnownLanguages(oActionTarget)
{
    return GetDatabaseString(DMFI_LANGUAGE_KNOWN, oActionTarget);
}

// ---< dmfi_PushKnownLanguages >---
// Sets known languages in the database
void dmfi_PushKnownLanguages(oActionTarget)
{
    string sLanguages = _GetLocalString(oActionTarget, DMFI_LANGUAGE_KNOWN);
    SetDatabaseString(DMFI_LANGUAGE_KNOWN, sLanguages, oActionTarget);
}

// ---< dmfi_ResetKnownLanguages >---
// Removes all known languages from a PC, leaving only common.
void dmfi_ResetKnownLanguages(object oActionTarget, int bForce = FALSE);
{
    if(!_GetLocalInt(oActionTarget, DMFI_INITIALIZED))
        return FALSE;

    if (!_GetIsPC(oActionTarget))
        return FALSE;

    string sLanguages = DMFI_LANGUAGE_ITEM_COMMON;
    _SetLocalString(oActionTarget, DMFI_LANGUAGE_KNOWN, sLanguages);
    dmfi_AssignCurrentLanguage(oActionTarget, DMFI_LANGUAGE_ITEM_COMMON);

    if (bForce)
        SetDatabaseString(DMFI_LANGUAGE_KNOWN, sLanguages, oActionTarget);
}

// ---< dmfi_RemoveKnownLanguage >---
// Removes sLanguage from oActionTarget's known languages list, if that
//  language exists on the targets.  Languages do not need to be set or
//  removed from NPCs.  Returns TRUE if the language was removed, FALSE
//  otherwise.  Common cannot be removed from a PC's known language list.
int dmfi_RemoveKnownLanguage(object oActionTarget, string sLanguage)
{
    if(!_GetLocalInt(oActionTarget, DMFI_INITIALIZED))
        return FALSE; 

    if(sLanguage == DMFI_LANGUAGE_ITEM_COMMON)
        return FALSE;

    string sLanguages = _GetLocalString(oActionTarget, DMFI_LANGUAGE_KNOWN);

    if (_GetIsPC(oActionTarget))
    {
        if (HasListItem(sLanguages, sLanguage))
        {
            sLanguages = RemoveListItem(sLanguages, sLanguage);
            _SetLocalString(oActionTarget, DMFI_LANGUAGE_KNOWN);
            return TRUE;
        }
    }

    return FALSE;
}

// TODO send error messages!
// ---< dmfi_AssignCurrentLanguage >---
// Assigns sLanguage as the current language the PC is speaking when using
//  the DMFI language command "[".  Languages are set by the .lang
//  command set.  Current languages do not need to be set on PCs.  Current
//  language can only be set to a language on the PC's known language list.
int dmfi_AssignCurrentLanguage(object oActionTarget, string sLanguage)
{
    if(!_GetLocalInt(oActionTarget, DMFI_INITIALIZED))
        return FALSE;

    if(_GetIsPC(oActionTarget))
    {
        string sLanguages = _GetLocalString(oActionTarget, DMFI_LANGUAGE_CURRENT);

        if (HasListItem(sLanguages, sLanguage) || sLanguage == DMFI_LANGUAGE_ITEM_COMMON)
        {
            _SetLocalString(oActionTarget, DMFI_LANGUAGE_CURRENT, sLanguage);
            return TRUE;
        }
    }

    return FALSE:
}

// ---< dmfi_AbbreviateList >---
// Function to create a last-ditch comparison list if the item someone is searching
//  for is not found the normal way.  This function will truncate each item
//  on sList to a total of nCharacters.  Spaces will be removed from either end.
string dmfi_AbbreviateList(string sList, int nCharacters)
{
    string sAbbreviation, sAbbreviatedList;
    int i, nCount = CountList(sList);

    for (i = 0; i < nCount; i++)
    {
        sAbbreviation = GetStringLeft(GetListItem(sList, i), nCharacters);
        sAbbreviation = TrimString(sAbbreviation);
        sAbbreviatedList = AddListItem(sAbbreviatedList, sAbbreviation);
    }

    return sAbbreviatedList;
}

// ---< dmfi_LoadSkills >---
// Returns a CSV list of all skills loaded in skills.2da.
string dmfi_LoadSkills()
{
    int i = 0;
    string sList, sString;

    while (1)
    {
        if ((sString = Get2DAString("skills", "Label", i)) != "")
            AddListItem(sList, sString, TRUE);
        else
            break;
    }

    return sList;
}

// ---< dmfi_GetArgumentsList >---
// Returns a CSV list of all tokens in sArguments delimited by sDelimiter
string dmfi_GetArgumentsList(string sArguments, string sDelimiter)
{
    string sToken, sList;
    int iIndex;

    sArguments = TrimString(sArguments);
    if (!GetStringLength(sArguments) || !GetStringLength(sDelimiter))
        return "";

    if (GetSubStringCount(sArguments, ","))
        sArguments = StringReplace(sArguments, ",", "");

    if (iIndex = FindSubString(sArguments, sDelimiter) == -1)
        return sArguments;

    while (iIndex != -1)
    {
        sToken = GetSubString(sArguments, 0, iIndex);
        sList = AddListItem(sList, sToken);
        sArguments = StringRemoveParsed(sArguments, sToken, " ");
        iIndex = FindSubString(sArguments, sDelimiter);
    }

    return sList;
}
