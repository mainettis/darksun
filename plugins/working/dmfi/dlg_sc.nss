
int StartingConditional()
{
   int nMyNum = _GetLocalInt(OBJECT_SELF, "dmfi_dmwOffset");
   _SetLocalInt(OBJECT_SELF, "dmfi_dmwOffset", nMyNum+1);

   object oMySpeaker = GetPCSpeaker();
   object oMyTarget = _GetLocalObject(oMySpeaker, "dmfi_univ_target");
   location lMyLoc = _GetLocalLocation(oMySpeaker, "dmfi_univ_location");

   string sMyString = _GetLocalString(oMySpeaker, "dmw_dialog" + IntToString(nMyNum));

   if(sMyString == "")
   {
      return FALSE;
   }
   else
   {
      SetCustomToken(8000 + nMyNum, sMyString);
      return TRUE;
   }
}
