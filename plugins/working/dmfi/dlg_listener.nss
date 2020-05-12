
// dmfi_univ_listen

// template: dmfi_getln_cbtpl
// triggered from OnPlayerChat callback

#include "dmfi_db_inc"

void main()
{
    int nVolume = GetPCChatVolume();
    object oShouter = GetPCChatSpeaker();
    string sSaid = GetPCChatMessage();

// SendMessageToPC(GetFirstPC(), "ENTER dmfi_univ_listen: speaker=" + GetName(oShouter) + ", channel=" + IntToString(nVolume) + ", said=" + sSaid);
    // first, lets deal with a getln event
    string getln_mode = _GetLocalString(OBJECT_SELF, "dmfi_getln_mode");
    if (getln_mode == "name")
    {
        if (sSaid != ".")
        {
            object oTarget = _GetLocalObject(oShouter, "dmfi_univ_target");
            SetName(oTarget, sSaid);
        }
        _DeleteLocalString(OBJECT_SELF, "dmfi_getln_mode");
    }
    else if (getln_mode == "desc")
    {
        if (sSaid != ".")
        {
            object oTarget = _GetLocalObject(oShouter, "dmfi_univ_target");
            SetDescription(oTarget, sSaid);
        }
        _DeleteLocalString(OBJECT_SELF, "dmfi_getln_mode");
    }
    else
    {
        // you may wish to define an "abort" input message, such as a line
        // containing a single period:
        if (sSaid != ".")
        {
            // put your code here to process the input line (in sSaid)

            if (_GetIsDM(oShouter))
                _SetLocalInt(GetModule(), "dmfi_Admin" + GetPCPublicCDKey(oShouter), 1);
            if (GetIsDMPossessed(oShouter)) 
                _SetLocalObject(GetMaster(oShouter), "dmfi_familiar", oShouter);

            object oTarget = _GetLocalObject(oShouter, "dmfi_VoiceTarget");
            object oMaster = OBJECT_INVALID;
            if (GetIsObjectValid(oTarget)) oMaster = oShouter;

            int iPhrase = _GetLocalInt(oShouter, "hls_EditPhrase");

            object oSummon;

            if (GetIsObjectValid(oShouter) && _GetIsDM(oShouter))
            {
                if (GetTag(OBJECT_SELF) == "dmfi_setting" && _GetLocalString(oShouter, "EffectSetting") != "")
                {
                    string sPhrase = _GetLocalString(oShouter, "EffectSetting");
                    _SetLocalFloat(oShouter, sPhrase, StringToFloat(sSaid));
                    SetDMFIPersistentFloat("dmfi", sPhrase, StringToFloat(sSaid), oShouter);
                    _DeleteLocalString(oShouter, "EffectSetting");
                    DelayCommand(0.5, ActionSpeakString("The setting " + sPhrase + " has been changed to " + FloatToString(_GetLocalFloat(oShouter, sPhrase))));
                    DelayCommand(1.5, DestroyObject(OBJECT_SELF));
                }
            }

            if (GetIsObjectValid(oShouter) && _GetIsPC(oShouter))
            {
                if (sSaid != _GetLocalString(GetModule(), "hls_voicebuffer"))
                {
                    _SetLocalString(GetModule(), "hls_voicebuffer", sSaid);

                    // PrintString("<Conv>"+GetName(GetArea(oShouter))+ " " + GetName(oShouter) + ": " + sSaid + " </Conv>");

                    // if the phrase begins with .MyName, reparse the string as a voice throw
                    if (GetStringLeft(sSaid, GetStringLength("." + GetName(OBJECT_SELF))) == "." + GetName(OBJECT_SELF) &&
                        (_GetLocalInt(GetModule(), "dmfi_Admin" + GetPCPublicCDKey(oShouter)) ||
                        _GetIsDM(oShouter)))
                    {
                        oTarget = OBJECT_SELF;
                        sSaid = GetStringRight(sSaid, GetStringLength(sSaid) - GetStringLength("." + GetName(OBJECT_SELF)));
                        if (GetStringLeft(sSaid, 1) == " ") sSaid = GetStringRight(sSaid, GetStringLength(sSaid) - 1);
                        sSaid = ":" + sSaid;
                        SetPCChatMessage(sSaid);
// SendMessageToPC(GetFirstPC(), "LEAVE(1) dmfi_univ_listen: speaker=" + GetName(oShouter) + ", channel=" + IntToString(nVolume) + ", said=" + sSaid);
                        return; // must bail out here to prevent clearing of message at end
                    }

                    if (iPhrase)
                    {
                        if (iPhrase > 0)
                        {
                            SetCustomToken(iPhrase, sSaid);
                            SetDMFIPersistentString("dmfi", "hls" + IntToString(iPhrase), sSaid);
                            FloatingTextStringOnCreature("Phrase " + IntToString(iPhrase) + " has been recorded", oShouter, FALSE);
                        }
                        else if (iPhrase < 0)
                        {

                        }
                        _DeleteLocalInt(oShouter, "hls_EditPhrase");
                    }
                }
            }
        }
    }

    // after processing, you will likely want to "eat" the text line, so it is
    // not spoken or available for further processing
    SetPCChatMessage("");

// SendMessageToPC(GetFirstPC(), "LEAVE(2) dmfi_univ_listen: speaker=" + GetName(oShouter) + ", channel=" + IntToString(nVolume) + ", said=" + sSaid);

}
