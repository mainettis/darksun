int StartingConditional()
{
    // set the custom tokens
    object oPC = GetPCSpeaker();
    object oTarget = _GetLocalObject(oPC, "dmfi_univ_target");

    string sName = GetName(oTarget);
    SetCustomToken(20680, sName);
    string sOrigName = GetName(oTarget, TRUE);
    SetCustomToken(20681, sOrigName);

    return TRUE;
}
