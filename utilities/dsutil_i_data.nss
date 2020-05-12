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

// ---< _GetIsPartyMember >---
// A module-private function intended to determine if oPC is a member of
//  oKnownPartyMember's party/faction.
int _GetIsPartyMember(object oPC, object oKnownPartyMember);

// ---< [_Get/_Set/_Delete]Local[Int/Float/String/Object/Location] >---
// Custom module functions intended to replace Bioware's variable handling
//  functions.  Currently, just a wrapper and perform the same functions, save
//  for PC variable-setting via HCR2, having these functions in place will allow
//  future modification for planned variable inheritance in NPC classes.
// _SetLocal* have return functions (TRUE/FALSE) to allow error-checking for future
//  expansion.  For now, the return value has no use, but future development
//  will use this value to pass an error condition.
int      _GetLocalInt     (object oObject, string sVarName);
float    _GetLocalFloat   (object oObject, string sVarName);
string   _GetLocalString  (object oObject, string sVarName);
object   _GetLocalObject  (object oObject, string sVarName);
location _GetLocalLocation(object oObject, string sVarName);

int      _SetLocalInt     (object oObject, string sVarName, int      nValue, int nDeclare = FALSE);
int      _SetLocalFloat   (object oObject, string sVarName, float    fValue, int nDeclare = FALSE);
int      _SetLocalString  (object oObject, string sVarName, string   sValue, int nDeclare = FALSE);
int      _SetLocalObject  (object oObject, string sVarName, object   oValue, int nDeclare = FALSE);
int      _SetLocalLocation(object oObject, string sVarName, location lValue, int nDeclare = FALSE);

void     _DeleteLocalInt     (object oObject, string sVarName);
void     _DeleteLocalFloat   (object oObject, string sVarName);
void     _DeleteLocalString  (object oObject, string sVarName);
void     _DeleteLocalObject  (object oObject, string sVarName);
void     _DeleteLocalLocation(object oObject, string sVarName);

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

// The following three procedures have a double underscore in front of them
//  and are currently only for test purposes while the variable inheritence
//  system is developed/tested.  Once complete, the new procedures will be
//  incorporated into the single underscore procedures below and should be
//  integrated seamlessly into the module since everything was built with
//  the _* procedures.

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
//  memeticai.  Why useful?  Not sure yet, maybe for spawns?  Possibly for other
//  smaller things like lootbags on dead pcs and such.
int __GetLocalInt(object oObject, string sVarName)
{
    //Since we don't allow inheritance on PCs (at least yet), let's check that
    //  first and move on.
    //If this is a PC, grab the variable from their local variable repository
    //  (player item).  Careful here, can't accidentally ever set PC as a child
    //  or a parent for now because of the way variables are handles for PCs
    //  through the HCR2 system.
    //We're not using the module-specific _GetIsPC because we want to be able
    //  to set variables on DMs also, so any player controlled character
    //  needs to pass this test.
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalInt(oData, sVarName);
    }  

    /*
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
    */

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
int __SetLocalInt(object oObject, string sVarName, int nValue, int nDeclare = FALSE)
{
    //Since we don't allow inheritance on PC objects, let's check that first
    //  so we can depart quickly if necessary and prevent accidentally setting
    //  inheritance variables on PCs.
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
        {
            SetLocalInt(oData, sVarName, nValue);
            return TRUE;
        }
    }

    /*
    object oParent = GetLocalObject(oObject, PARENT);
    //Declaring should only be done on the parent object.  'return' is not used
    //  except on PC objects to allow oObject to "fall through" to the final
    //  SetLocalInt (much like a case without break).
    // TODO check this logic, I think it's wrong.
    if (GetIsObjectValid(oParent))
        SetLocalObject(oObject, INHERIT_INT + sVarName, oObject);
    else if (nDeclare)
        SetLocalObject(oObject, INHERIT_INT + sVarName, oObject);
    else
        return FALSE;
    */

    //Otherwise, just set the variable on the object.
    SetLocalInt(oObject, sVarName, nValue);
    return TRUE;
}

void __DeleteLocalInt(object oObject, string sVarName)
{
    //So this will be a little different.  If we're a child, we shouldn't be
    //  deleting any inherited variables on the parent, only ones that belong
    //  to us.
    //How to handle variables that are declared?

    /*
    object oParent = GetLocalObject(oObject, PARENT);
    if (GetIsObjectValid(oParent))
    {
        DeleteLocalObject(oObject, INHERIT_INT + sVarName);
        return;
    }
    */

    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalInt(oData, sVarName);
    }

    DeleteLocalInt(oObject, sVarName);
}

// ---< _Get Variable Procedures >---

int      _GetLocalInt  (object oObject, string sVarName)
{
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalInt(oData, sVarName);
    }  

    return GetLocalInt(oObject, sVarName);
}

float    _GetLocalFloat(object oObject, string sVarName)
{
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalFloat(oData, sVarName);
    }  

    return GetLocalFloat(oObject, sVarName);
}

string   _GetLocalString(object oObject, string sVarName)
{
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalString(oData, sVarName);
    }  

    return GetLocalString(oObject, sVarName);
}

object   _GetLocalObject(object oObject, string sVarName)
{
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalObject(oData, sVarName);
    }  

    return GetLocalObject(oObject, sVarName);
}

location _GetLocalLocation(object oObject, string sVarName)
{
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            return GetLocalLocation(oData, sVarName);
    }  

    return GetLocalLocation(oObject, sVarName);
}

// ---< _Set Variable Procedures >---

int _SetLocalInt(object oObject, string sVarName, int nValue, int nDeclare = FALSE)
{
    if (GetIsPC(oObject))
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

int _SetLocalFloat(object oObject, string sVarName, float fValue, int nDeclare = FALSE)
{
    if (GetIsPC(oObject))
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

int _SetLocalString(object oObject, string sVarName, string sValue, int nDeclare = FALSE)
{
    if (GetIsPC(oObject))
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

int _SetLocalObject(object oObject, string sVarName, object oValue, int nDeclare = FALSE)
{
    if (GetIsPC(oObject))
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

int _SetLocalLocation(object oObject, string sVarName, location lValue, int nDeclare = FALSE)
{
    if (GetIsPC(oObject))
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

// ---< _Delete Variable Procedures >---

void _DeleteLocalInt(object oObject, string sVarName)
{    
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalInt(oData, sVarName);
    }

    DeleteLocalInt(oObject, sVarName);
}

void _DeleteLocalFloat(object oObject, string sVarName)
{    
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalFloat(oData, sVarName);
    }

    DeleteLocalFloat(oObject, sVarName);
}

void _DeleteLocalString(object oObject, string sVarName)
{    
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalString(oData, sVarName);
    }

    DeleteLocalString(oObject, sVarName);
}

void _DeleteLocalObject(object oObject, string sVarName)
{    
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalObject(oData, sVarName);
    }

    DeleteLocalObject(oObject, sVarName);
}

void _DeleteLocalLocation(object oObject, string sVarName)
{    
    if (GetIsPC(oObject))
    {
        object oData = GetItemPossessedBy(oObject, PLAYER_DATAPOINT);
        if (GetIsObjectValid(oData))
            DeleteLocalLocation(oData, sVarName);
    }

    DeleteLocalLocation(oObject, sVarName);
}
