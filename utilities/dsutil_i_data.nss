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

#include "ds_i_const"
#include "util_i_debug"     

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
vector   _GetLocalVector     (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");

int      _SetLocalInt        (object oObject, string sVarName, int      nValue, int nFlag = 0x00, string sData = "");
int      _SetLocalFloat      (object oObject, string sVarName, float    fValue, int nFlag = 0x00, string sData = "");
int      _SetLocalString     (object oObject, string sVarName, string   sValue, int nFlag = 0x00, string sData = "");
int      _SetLocalObject     (object oObject, string sVarName, object   oValue, int nFlag = 0x00, string sData = "");
int      _SetLocalLocation   (object oObject, string sVarName, location lValue, int nFlag = 0x00, string sData = "");
int      _SetLocalVector     (object oObject, string sVarName, vector   vValue, int nFlag = 0x00, string sData = "");

void     _DeleteLocalInt     (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalFloat   (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalString  (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalObject  (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalLocation(object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");
void     _DeleteLocalVector  (object oObject, string sVarName,                  int nFlag = 0x00, string sData = "");

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

object DetermineObject(oObject)
{
    if (oObject == oModule)
        return MODULE;
    
    if (GetIsPC(oObject) && !nFlag)
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return oData;
    }

    return oObject
}

int _GetLocalInt(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    return GetLocalInt(oObject, sVarName);
}

float _GetLocalFloat(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    return GetLocalFloat(oObject, sVarName);
}

string _GetLocalString(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    return GetLocalString(oObject, sVarName);
}

object _GetLocalObject(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    return GetLocalObject(oObject, sVarName);
}

location _GetLocalLocation(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    return GetLocalLocation(oObject, sVarName);
}

vector _GetLocalVector(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);    
    float fX = _GetLocalFloat(oObject, sVarName + "X");
    float fY = _GetLocalFloat(oObject, sVarName + "Y");
    float fZ = _GetLocalFloat(oObject, sVarName + "Z");
    return Vector(fX, fY, fZ);    
}

// ---< _Set* Variable Procedures >---

int _SetLocalInt(object oObject, string sVarName, int nValue, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalInt(oObject, sVarName, nValue);
    return TRUE;
}

int _SetLocalFloat(object oObject, string sVarName, float fValue, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalFloat(oObject, sVarName, fValue);
    return TRUE;
}

int _SetLocalString(object oObject, string sVarName, string sValue, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalString(oObject, sVarName, sValue);
    return TRUE;
}

int _SetLocalObject(object oObject, string sVarName, object oValue, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalObject(oObject, sVarName, oValue);
    return TRUE;
}

int _SetLocalLocation(object oObject, string sVarName, location lValue, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    SetLocalLocation(oObject, sVarName, lValue);
    return TRUE;
}

int _SetLocalVector(object oObject, string sVarName, vector vValue, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    _SetLocalFloat(oObject, sVarName + "X", vValue.x);
    _SetLocalFloat(oObject, sVarName + "Y", vValue.y);
    _SetLocalFloat(oObject, sVarName + "Z", vValue.z);
    return TRUE;
}

// ---< _Delete* Variable Procedures >---

void _DeleteLocalInt(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalInt(oObject, sVarName);
}

void _DeleteLocalFloat(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalFloat(oObject, sVarName);
}

void _DeleteLocalString(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalString(oObject, sVarName);
}

void _DeleteLocalObject(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalObject(oObject, sVarName);
}

void _DeleteLocalLocation(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{    
    oObject = DetermineObject(oObject);
    DeleteLocalLocation(oObject, sVarName);
}

void _DeleteLocalVector(object oObject, string sVarName, int nFlag = 0x00, string sData = "")
{
    oObject = DetermineObject(oObject);
    _DeleteLocalFloat(oObject, sVarName + "X");
    _DeleteLocalFloat(oObject, sVarName + "Y");
    _DeleteLocalFloat(oObject, sVarName + "Z");  
}