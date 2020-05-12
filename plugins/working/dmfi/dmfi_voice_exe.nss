//::///////////////////////////////////////////////
//:: DMFI - settings voice command handler
//:: dmfi_voice_exe
//:://////////////////////////////////////////////
/*
  Processor for the text heard by the settings adjuster creature.
*/
//:://////////////////////////////////////////////
//:: Created By: The DMFI Team
//:: Created On:
//:://////////////////////////////////////////////
//:: 2008.08.02 tsunami282 - most code transferred to dmfi_plychat_exe, this
//::    script now used for processing what the Settings Adjuster creature hears.

#include "dmfi_db_inc"

void main()
{
    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();

    if (_GetIsDM(oShouter))
        _SetLocalInt(GetModule(), "dmfi_Admin" + GetPCPublicCDKey(oShouter), 1);

    if (GetIsDMPossessed(oShouter))
        _SetLocalObject(GetMaster(oShouter), "dmfi_familiar", oShouter);

    object oTarget = _GetLocalObject(oShouter, "dmfi_VoiceTarget");
    object oMaster = OBJECT_INVALID;
    if (GetIsObjectValid(oTarget))
        oMaster = oShouter;

    int iPhrase = _GetLocalInt(oShouter, "hls_EditPhrase");

    //*object oSummon;

    if (nMatch == LISTEN_PATTERN && GetIsObjectValid(oShouter) && _GetIsDM(oShouter))
    {
        string sSaid = GetMatchedSubstring(0);

        if (GetTag(OBJECT_SELF) == "dmfi_setting" && _GetLocalString(oShouter, "EffectSetting") != "")
        {
            string sPhrase = _GetLocalString(oShouter, "EffectSetting");
            _SetLocalFloat(oShouter, sPhrase, StringToFloat(sSaid));
            SetDMFIPersistentFloat("dmfi", sPhrase, StringToFloat(sSaid), oShouter);
            _DeleteLocalString(oShouter, "EffectSetting");
            DelayCommand(0.5, ActionSpeakString("The setting " + sPhrase + " has been changed to " + FloatToString(_GetLocalFloat(oShouter, sPhrase))));
            DelayCommand(1.5, DestroyObject(OBJECT_SELF));
            //maybe add a return here
        }
    }
}

