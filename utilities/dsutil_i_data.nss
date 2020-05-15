// -----------------------------------------------------------------------------
//    File: dsutil_i_data.nss
//  System: PW Administration (identity and data management)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Include for primary data control functions.
// -----------------------------------------------------------------------------
// Builder Use:
//  This include should be "included" in just about every script in the system.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

#include "util_i_debug"     
#include "dsutil_i_comms"   

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< Identity >---

// ---< _GetIsDM >---
// A module-level function intended to replace the game's GetIsDM() function.
//  Checks for GetIsDM and GetIsDMPossessed.
int _GetIsDM(object oPC);

// ---< _GetIsPC >---
// A module-level function intended to repalce the game's IsPC() function.
//  Checks to see if oPC is a player character that is not DM-controlled.
int _GetIsPC(object oPC);

// ---< _GetIsPartyMember >---
// A module-level function intended to determine if oPC is a member of
//  oKnownPartyMember's party/faction.
int _GetIsPartyMember(object oPC, object oKnownPartyMember);

// ---< Variable Management >---

// ---< [_Get/_Set/_Delete]Local[Int/Float/String/Object/Location] >---
// Custom module-level functions intended to replace Bioware's variable handling
//  functions.  oObject will be checked for specific conditions, such as
//  == GetModule() or GetIsPC() to route the variable to the correct location
//  and ensure we're always loading the variable to the correct location.
// nFlag will modify the routing.  
// sData is not currently planned for use but is in place for future expansion.
// _SetLocal* will return TRUE/FALSE based on whether the operation was completed.
//  This is in place solely for future expansion to denote an error condition.
//  Although a value is currently returned, it has no meaning WRT an error condition.
int      _GetLocalInt        (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
float    _GetLocalFloat      (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
string   _GetLocalString     (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
object   _GetLocalObject     (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
location _GetLocalLocation   (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");

int      _SetLocalInt        (object oObject, string sVarName, int      nValue, int nFlag = 0x00, string sData = "");
int      _SetLocalFloat      (object oObject, string sVarName, float    fValue, int nFlag = 0x00, string sData = "");
int      _SetLocalString     (object oObject, string sVarName, string   sValue, int nFlag = 0x00, string sData = "");
int      _SetLocalObject     (object oObject, string sVarName, object   oValue, int nFlag = 0x00, string sData = "");
int      _SetLocalLocation   (object oObject, string sVarName, location lValue, int nFlag = 0x00, string sData = "");

void     _DeleteLocalInt     (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalFloat   (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalString  (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalObject  (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalLocation(object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ---< Identity >---

int _GetIsDM(object oPC)
{
    return (GetIsDM(oPC) || GetIsDMPossessed(oPC));
}

int _GetIsPC(object oPC)
{
    return (GetIsPC(oPC) && !_GetIsDM(oPC));
}

int _GetIsPartyMember(object oPC, object oKnownPartyMember)
{
    object oPartyMember = GetFirstFactionMember(oKnownPartyMember);

    while (GetIsObjectValid(oPartyMember))
    {
        if (oPartyMember == oPC)
            return TRUE;

        oPartyMember = GetNextFactionMember(oKnownPartyMember);
    }

    return FALSE;
}

// ---< Variable Management >---

// ---< _Get* Variable Procedures >---

int _GetLocalInt(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
    
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalInt(oData, sVarName);
    }  

    return GetLocalInt(oObject, sVarName);
}

float _GetLocalFloat(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
     
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalFloat(oData, sVarName);
    }  

    return GetLocalFloat(oObject, sVarName);
}

string _GetLocalString(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
     
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalString(oData, sVarName);
    }  

    return GetLocalString(oObject, sVarName);
}

object _GetLocalObject(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
     
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalObject(oData, sVarName);
    }  

    return GetLocalObject(oObject, sVarName);
}

location _GetLocalLocation(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
      
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalLocation(oData, sVarName);
    }  

    return GetLocalLocation(oObject, sVarName);
}

// ---< _Set* Variable Procedures >---

int _SetLocalInt(object oObject, string sVarName, int nValue, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
       
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalInt(oData, sVarName, nValue);
            return TRUE;
        }
    }

    SetLocalInt(oObject, sVarName, nValue);
    return TRUE;
}

int _SetLocalFloat(object oObject, string sVarName, float fValue, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
       
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalFloat(oData, sVarName, fValue);
            return TRUE;
        }
    }

    SetLocalFloat(oObject, sVarName, fValue);
    return TRUE;
}

int _SetLocalString(object oObject, string sVarName, string sValue, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
       
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalString(oData, sVarName, sValue);
            return TRUE;
        }
    }

    SetLocalString(oObject, sVarName, sValue);
    return TRUE;
}

int _SetLocalObject(object oObject, string sVarName, object oValue, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
      
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalObject(oData, sVarName, oValue);
            return TRUE;
        }
    }

    SetLocalObject(oObject, sVarName, oValue);
    return TRUE;
}

int _SetLocalLocation(object oObject, string sVarName, location lValue, int nFlag = 0x00, string sData = "")
{
    if (oObject == oModule)
        oObject = MODULE;
      
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalLocation(oData, sVarName, lValue);
            return TRUE;
        }
    }

    SetLocalLocation(oObject, sVarName, lValue);
    return TRUE;
}

// ---< _Delete* Variable Procedures >---

void _DeleteLocalInt(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    if (oObject == oModule)
        oObject = MODULE;
       
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalInt(oData, sVarName);
    }

    DeleteLocalInt(oObject, sVarName);
}

void _DeleteLocalFloat(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    if (oObject == oModule)
        oObject = MODULE;
       
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalFloat(oData, sVarName);
    }

    DeleteLocalFloat(oObject, sVarName);
}

void _DeleteLocalString(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    if (oObject == oModule)
        oObject = MODULE;
       
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalString(oData, sVarName);
    }

    DeleteLocalString(oObject, sVarName);
}

void _DeleteLocalObject(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    if (oObject == oModule)
        oObject = MODULE;
       
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalObject(oData, sVarName);
    }

    DeleteLocalObject(oObject, sVarName);
}

void _DeleteLocalLocation(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    if (oObject == oModule)
        oObject = MODULE;
        
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalLocation(oData, sVarName);
    }

    DeleteLocalLocation(oObject, sVarName);
}
