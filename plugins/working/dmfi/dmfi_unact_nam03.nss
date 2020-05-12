void main()
{
    object oPC = GetPCSpeaker();
    object oTarget = _GetLocalObject(oPC, "dmfi_univ_target");
    SetName(oTarget, "");
}
