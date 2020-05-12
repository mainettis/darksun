// -----------------------------------------------------------------------------
//    File: dsutil_i_data.nss
//  System: PW Administration (identity and data)
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

// These functions are meant to be included in just about every script in the
//  module.  They reference basic identities, module and player data.  It
//  also includes debugging and communcations, so including this script will
//  give every script just about all the connectivity they need.

#include "ds_i_const"
#include "util_i_debug"
//#include "dsutil_i_comms"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< Identity >---

// ---< _GetIsDM >---
// A module-private function intended to replace the game's GetIsDM() function.
//  Checks for GetIsDM and GetIsDMPossessed.
int _GetIsDM(object oPC);

// ---< _GetIsPC >---
// A module-private function intended to repalce the game's IsPC() function.
//  Checks to see if oPC is a player character that is not DM-controlled.
int _GetIsPC(object oPC);

// ---< _IsPartyMember >---
// A module-private function intended to determine if oPC is a member of
//  oKnownPartyMember's party/faction.
int _IsPartyMember(object oPC, object oKnownPartyMember);

// ---< Module Data> ---

// ---< *Module* >---
// The following functions Get, Set, and Delete variables on the MODULE datapoint
//  instead of the overused and performance-sucking GetModule().  The MODULE
//  datapoint is defined in ds_i_const.
int  GetModuleInt(string sVarName);
void SetModuleInt(string sVarName, int nValue);
void DeleteModuleInt(string sVarName);

string GetModuleString(string sVarName);
void   SetModuleString(string sVarName, string sValue);
void   DeleteModuleString(string sVarName);

float GetModuleFloat(string sVarName);
void  SetModuleFloat(string sVarName, float fValue);
void  DeleteModuleFloat(string sVarName);

object GetModuleObject(string sVarName);
void   SetModuleObject(string sVarName, object oValue);
void   DeleteModuleObject(string sVarName);

location GetModuleLocation(string sVarName);
void     SetModuleLocation(string sVarName, location lValue);
void     DeleteModuleLocation(string sVarName);

// ---< *Player* >---
// The following functions Get, Set, and Delete variable on an undroppable
//  player data item that is given to the player upon first login.  This item
//  will prevent having to set variables on the overused PC object.  Variables
//  set via these functions will be persistent for servervault characters.
int  GetPlayerInt(object oPC, string sVarName);
void SetPlayerInt(object oPC, string sVarName, int nValue);
void DeletePlayerInt(object oPC, string sVarName);

float GetPlayerFloat(object oPC, string sVarName);
void  SetPlayerFloat(object oPC, string sVarName, float fValue);
void  DeletePlayerFloat(object oPC, string sVarName);

object GetPlayerObject(object oPC, string sVarName);
void   SetPlayerObject(object oPC, string sVarName, object oValue);
void   DeletePlayerObject(object oPC, string sVarName);

string GetPlayerString(object oPC, string sVarName);
void   SetPlayerString(object oPC, string sVarName, string sValue);
void   DeletePlayerString(object oPC, string sVarName);

location GetPlayerLocation(object oPC, string sVarName);
void     SetPlayerLocation(object oPC, string sVarName, location lValue);
void     DeleteLocalLocation(object oPC, string sVarName);

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

int _IsPartyMember(object oPC, object oKnownPartyMember)
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

// ---< Module Data >---

const int DECLARE = TRUE;
const string INHERIT_INT = "INH_INT:";
const string PARENT = "*Parent";

// ---< _GetLocalInt >---
// This is an experiment in overriding  the module's [Get/Set/Delete]Local*
//  in order to allow a redneck version of inheritance, essentially allowing
//  any object with a *Parent variable set to use the parent's variables.
// Requires the parent to first set those variables in a declaration statement.
//  Assumes single inheritance for now -- no grandchildren inheriting from
//  grandparents -- only parent -> child.
// The inheritance idea is unabashedly stolen from the awesome programmers behind
//  memeticai.
int _GetLocalInt(object oObject, string sVarName)
{
    //Since we don't allow inheritance on PCs (at least yet), let's check that
    //  first and move on.
    //If this is a PC, grab the variable from their local variable repository
    //  (player item).  Careful here, can't accidentally ever set PC as a child
    //  or a parent for now because of the way variables are handles for PCs
    //  through the HCR2 system.
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalInt(oData, sVarName);
    }  

    //Check for declared variables that are inherited by others.  This will allow
    //  declared variabled to act as local variables for the parent object.
    object oDeclarations = GetLocalObject(oObject, INHERIT_INT + sVarName);
    if (GetIsObjectValid(oDeclarations))
        return GetLocalInt(oDeclarations, sVarName);

    //Check for inherited variables on the parent.  If this is a child object,
    //  check the parent for the variable on the parent's declared variables
    //  list.  If that variable doesn't exist, continue on.
    object oParent = GetLocalObject(oObject, PARENT);
    if (GetIsObjectValid(oParent))
        return _GetLocalInt(oParent, sVarName);

    //Well, there's no other possibilities left, just see if the called object
    //  has the variable on it.
    return GetLocalInt(oObject, sVarName);
}

// ---< _SetLocalInt >---
// Continues experiment to override the game's SetLocalInt with something more
//  flexible, although much more complicated.  See documentation for _GetLocalInt
//  for notes.  This functions returns false if you're trying to declare and
//  this isn't a parent.  This should be checked for anytime you're declaring to
//  check for errors.
int _SetLocalInt(object oObject, string sVarName, int nValue, int nDeclare = FALSE)
{
    //Since we don't allow inheritance on PC objects, let's check that first
    //  so we can depart quickly if necessary and prevent accidentally setting
    //  inheritance variables on PCs.
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalInt(oData, sVarName, nValue);
            return;
        }
    }

    object oParent = GetLocalObject(oObject, PARENT);
    //Declaring should only be done on the parent object.  'return' is not used
    //  except on PC objects to allow oObject to "fall through" to the final
    //  SetLocalInt (much like a case without break).
    if (GetIsObjectValid(oParent))
        SetLocalObject(oObject, INHERIT_INT + sVarName, oTarget);
    else if (nDeclare)
        SetLocalObject(oObject, INHERIT_INT + sVarName, oObject);
    else
        return FALSE;

    //Otherwise, just set the variable on the object.
    SetLocalInt(oObject, sVarName, nValue);
}

void _DeleteLocalInt(object oObject, string sVarName)
{
    //So this will be a little different.  If we're a child, we shouldn't be
    //  deleting any inherited variables on the parent, only ones that belong
    //  to us.
    //How to handle variables that are declared?

    object oParent = GetLocalObject(oObject, PARENT);
    if (GetIsObjectValid(oParent))
    {
        DeleteLocalObject(oObject, INHERIT_INT + sVarName, oTarget);
        return;
    }

    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalInt(oData, sVarName);
    }

    DeleteLocalInt(oObject, sVarName);
}

void SetParent(object oObject, object oParent)
{
    SetLocalObject(oObject, PARENT, oParent);
}

int GetModuleInt(string sVarName)
{
    return GetLocalInt(MODULE, sVarName);
}

void SetModuleInt(string sVarName, int nValue)
{
    SetLocalInt(MODULE, sVarName, nValue);
}

void DeleteModuleInt(string sVarName)
{
    DeleteLocalInt(MODULE, sVarName);
}

string GetModuleString(string sVarName)
{
    return GetLocalString(MODULE, sVarName);
}

void SetModuleString(string sVarName, string sValue)
{
    SetLocalString(MODULE, sVarName, sValue);
}

void DeleteModuleString(string sVarName)
{
    DeleteLocalString(MODULE, sVarName);
}

float GetModuleFloat(string sVarName)
{
    return GetLocalFloat(MODULE, sVarName);
}

void SetModuleFloat(string sVarName, float fValue)
{
    SetLocalFloat(MODULE, sVarName, fValue);
}

void DeleteModuleFloat(string sVarName)
{
    DeleteLocalFloat(MODULE, sVarName);
}

object GetModuleObject(string sVarName)
{
    return GetLocalObject(MODULE, sVarName);
}

void SetModuleObject(string sVarName, object oValue)
{
    SetLocalObject(MODULE, sVarName, oValue);
}

void DeleteModuleObject(string sVarName)
{
    DeleteLocalObject(MODULE, sVarName);
}

location GetModuleLocation(string sVarName)
{
    return GetLocalLocation(MODULE, sVarName);
}

void SetModuleLocation(string sVarName, location lValue)
{
    SetLocalLocation(MODULE, sVarName, lValue);
}

void DeleteModuleLocation(string sVarName)
{
    DeleteLocalLocation(MODULE, sVarName);
}

// ---< Player Data >---
int GetPlayerInt(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        return GetLocalInt(oData, sVarName);
    return 0;
}

void SetPlayerInt(object oPC, string sVarName, int nValue)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        SetLocalInt(oData, sVarName, nValue);
}

void DeletePlayerInt(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        DeleteLocalInt(oData, sVarName);
}

float GetPlayerFloat(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        return GetLocalFloat(oData, sVarName);
    return 0.0;
}

void SetPlayerFloat(object oPC, string sVarName, float fValue)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        SetLocalFloat(oData, sVarName, fValue);
}

void DeletePlayerFloat(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        DeleteLocalFloat(oData, sVarName);
}

object GetPlayerObject(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        return GetLocalObject(oData, sVarName);
    return OBJECT_INVALID;
}

void SetPlayerObject(object oPC, string sVarName, object oValue)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        SetLocalObject(oData, sVarName, oValue);
}

void DeletePlayerObject(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        DeleteLocalObject(oData, sVarName);
}

string GetPlayerString(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        return GetLocalString(oData, sVarName);
    return "";
}

void SetPlayerString(object oPC, string sVarName, string sValue)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        SetLocalString(oData, sVarName, sValue);
}

void DeletePlayerString(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        DeleteLocalString(oData, sVarName);

}
location GetPlayerLocation(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        return GetLocalLocation(oData, sVarName);
    return Location(OBJECT_INVALID, Vector(-1.0,-1.0,-1.0), 0.0);
}

void SetPlayerLocation(object oPC, string sVarName, location lValue)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        SetLocalLocation(oData, sVarName, lValue);
}

void DeletePlayerLocation(object oPC, string sVarName)
{
    object oData = GetItemPossessedBy(oPC, PLAYER_DATAPOINT);
    if (GetIsObjectValid(oData))
        DeleteLocalLocation(oData, sVarName);
}
