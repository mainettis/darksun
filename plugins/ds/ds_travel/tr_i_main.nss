// -----------------------------------------------------------------------------
//    File: unid_i_main.nss
//  System: UnID Item on Drop (core)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Core functions for PW Subsystem.
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

#include "tr_i_config"
#include "tr_i_const"
#include "tr_i_text"
#include "ds_i_const"
#include "dsutil_i_data"
#include "core_i_constants"
#include "corpse_i_const"
#include "loot_i_main"
#include "pw_i_core"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< _setEncounterVariables >---
// Internal function for setting the required variables on any object travelling
//  to an encounter area.
void _setEncounterVariables(object oPC, int nEncounterID);

// ---< tr_CreateEncounter >---
// Sets up all required objects for an encounter to occur.  Returns the encounter
//  ID.  Once this encounter has been created, the encounter ID can be used to 
//  start the encounter and kill the encounter.  The encounter cannot be killed
//  if there is a PC in the area.
int tr_CreateEncounter(object oPC);

// ---< tr_KillEncounter >---
// Deletes all variables associated with nEncounterID, if passed.  If not passed,
//  it is assumed the function is being called from the OnAreaEmpty event.  Will
//  check for PCs in the area and abort if found.  Destroys the encounter area.
void tr_KillEncounter(int nEncounterID = 0);

// ---< tr_StartEncounter >---
// Starts the encounter nEncounterID.  This should never be called if
//  tr_CreateEncounter did not return a valid encounter ID.  

// ---< tr_CheckForEncounter >---
// This is the executed script with the custom timer event for the overland travel
//  system expires.  This function checks to see if the party will have an
//  encounter during their overland travel and, if so, sends them there.
void tr_CheckForEncounter();

// ---< tr_EncounterExit >---
// This function sends the PC back to where they came from after the conclusion
//  of an encounter.
void tr_EncounterExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int ENCOUNTER_AREA_PC_COUNT;  //TODO get rid of when AREA_ROSTER works.

void _setEncounterVariables(object oPC, int nEncounterID)
{
    int nEncounters = _GetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
    
    _SetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS, ++nEncounters);
    _SetLocalInt(oPC, TRAVEL_ENCOUNTER_ID, nEncounterID);
    _SetLocalLocation(oPC, TRAVEL_SOURCE_LOCATION, GetLocation(oPC));
}

struct TRAVEL_ENCOUNTER tr_GetEncounterData(int nEncounterID)
{
    struct TRAVEL_ENCOUNTER te;

    te.nEncounterID = nEncounterID;
    te.sEncounterID = IntToString(nEncounterID);
    te.oEncounterArea = _GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + te.sEncounterID);
    te.oTriggeredBy = _GetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY + te.sEncounterID);
    te.sPrimaryWaypoint = _GetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT + te.sEncounterID);
    te.sSecondaryWaypoints = _GetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + te.sEncounterID);

    return te;
}

int tf_CreateEncounter(object oPC)
{
    object oEncounterArea, oTravelArea = GetArea(oPC);
    string sSecondaryWaypoints, sWaypointTag, sWaypoints, sTriggers, sSpawns, sEncounterArea, sEncounterAreas = _GetLocalString(oTravelArea, ENCOUNTER_AREAS);
    int nWaypointType, nArea, nEncounterID, nCount = CountList(sEncounterAreas);
    int i = 2;
    string sEncounterID = IntToString(nEncounterID);

    if (!nCount)
    {
        Debug("Unable to create encounter, no encounter areas defined on oTravelArea's ENCOUNTER_AREA variable.");
        return 0;
    }

    Debug("Creating encounter for " + GetName(oPC));
    
    nEncounterID = _GetLocalInt(ENCOUNTERS, ENCOUNTER_NEXT_ID);
    
    if (!nEncounterID)
        nEncounterID = 1;

    sEncounterID = IntToString(nEncounterID);

    sEncounterArea = GetListItem(sEncounterAreas, Random(nCount) + 1);
    oEncounterArea = CreateArea(sEncounterArea, ENCOUNTER_AREA_TAG + IntToString(nEncounterID));

    object oAreaObject = GetFirstObjectInArea(oEncounterArea);

    //TODO Retag everything that could be referenced in a jump to or specific waypoint name.
    while (GetIsObjectValid(oAreaObject))
    {
        if (GetObjectType(oAreaObject) == OBJECT_TYPE_WAYPOINT)
        {       //TODO constant for *Type
            nWaypointType = _GetLocalInt(oAreaObject, "*Type");
            if (nWaypointType == ENCOUNTER_WAYPOINT_PRIMARY)
                SetTag(oAreaObject, ENCOUNTER_WAYPOINT_TAG + sEncounterID + IntToString(1));
            else if (nWaypointType == ENCOUNTER_WAYPOINT_SECONDARY)
            {
                sWaypointTag = ENCOUNTER_WAYPOINT_TAG + sEncounterID + IntToString(i++);
                SetTag(oAreaObject, sWaypointTag);
                sSecondaryWaypoints = AddListItem(sSecondaryWaypoints, sWaypointTag);
            }
        }
    }

    _SetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT    + sEncounterID, ENCOUNTER_WAYPOINT_TAG + sEncounterID + IntToString(1));
    _SetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID, sSecondaryWaypoints);
    _SetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY        + sEncounterID, oPC);
    _SetLocalObject(ENCOUNTERS, ENCOUNTER_AREA                + sEncounterID, oEncounterArea);
    _SetLocalInt   (ENCOUNTERS, ENCOUNTER_NEXT_ID                           , ++nEncounterID);

    Debug("Successfully created encounter with ID " + sEncounterID);
    return nEncounterID;
}

void tr_KillEncounter(int nEncounterID = 0)
{
    string sEncounterID = IntToString(nEncounterID);
    object oEncounterArea = nEncounterID ? _GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + sEncounterID) : OBJECT_SELF;

/* TODO waiting on update to framework to create AREA_ROSTER
    if (!CountObjectList(oEncounterArea, AREA_ROSTER))
        {
            Debug("Cannot kill encounter " + sEncounterID + "; PCs detected in encounter area.");
            return;
        }
*/
    //Workaround until the AREA_ROSTER is working
    if (!ENCOUNTER_AREA_PC_COUNT)
        {
            Debug("Cannot kill encounter " + sEncounterID + "; PCs detected in encounter area.");
            return;
        }

    //Search for dead bodies and bring them back.
    //TODO instead of looping all the objects, set a variable when a PC dies and
    //  check, then loop if necessary?
    object oNewCorpse, oObject = GetFirstObjectInArea(oEncounterArea);
    while (GetIsObjectValid(oObject))
    {
        string sObjectTag = GetTag(oObject);

        if (GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE
            && GetStringLeft(sObjectTag, GetStringLength(H2_CORPSE)) == H2_CORPSE)
        {
            //Not sure if we can jump a placeable to a location, need to to a test, so
            //  here's both methods, use one or the other.
            // Simulates picking them up and dropping them somewhere else.
            // TODO this is a crappy way to do this as it cycles through every pc.
            //  How's about storing the pc object on the death token?  If so, how to
            //  handle logged out pcs.
            object oCorpseToken = GetItemPossessedBy(oObject, H2_PC_CORPSE_ITEM);
            string uniquePCID = _GetLocalString(oCorpseToken, H2_DEAD_PLAYER_ID);
            object oPC = h2_FindPCWithGivenUniqueID(uniquePCID);
            if (GetIsObjectValid(oPC))
            {
                location lDestination = _GetLocalLocation(oPC, TRAVEL_SOURCE_LOCATION);
                _SetLocalLocation(oCorpseToken, H2_LAST_DROP_LOCATION, lDestination);
                oNewCorpse = CopyObject(oObject, lDestination);
                object oLootBag = _GetLocalObject(oPC, H2_LOOT_BAG);
                object oNewLootBag = h2_CreateLootBag(oNewCorpse);
                h2_MovePossessorInventory(oLootBag, TRUE, oNewLootBag);
                //DestroyObject(oLootBag);
                _SetLocalObject(oPC, H2_LOOT_BAG, oNewLootBag);
            }
            else
                oNewCorpse = CopyObject(oObject, GetLocation(GetObjectByTag(H2_WP_DEATH_CORPSE)));
                //What do we do with all his crap!?

            AssignCommand(oObject, SetIsDestroyable(TRUE, FALSE));
            //DestroyObject(oObject);  //Need these destroys?   Area is about to be destroyed.

            //Don't forget the lootbag that was created;
        }
    }

    //Get rid of the AOE portal
    if (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY)
    {
        object oEncounterAOE = _GetLocalObject(ENCOUNTERS, ENCOUNTER_AOE + sEncounterID);
        AssignCommand(oEncounterAOE, SetIsDestroyable(TRUE));
        DestroyObject(oEncounterAOE);
    }

    if (!DestroyArea(oEncounterArea))
    {
        Debug("Cannot kill encounter " + sEncounterID + "; PCs detected in encounter area.");
        return;
    }    

    _DeleteLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT    + sEncounterID);
    _DeleteLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID);
    _DeleteLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY        + sEncounterID);
    _DeleteLocalObject(ENCOUNTERS, ENCOUNTER_AREA                + sEncounterID);
}

void tr_StartEncounter(int nEncounterID)
{
    string sEncounterID = IntToString(nEncounterID);
    object oPC = _GetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY + sEncounterID);
    string sPrimaryWaypoint = _GetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT + sEncounterID);
    string sSecondaryWaypoints = _GetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID);
    object oEncounterArea = _GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + sEncounterID);
    int nWaypointCount = CountList(sSecondaryWaypoints);

    if (!GetIsObjectValid(oPC))
    {
        tr_KillEncounter(nEncounterID);
        Debug("Could not start encounter ID " + IntToString(nEncounterID) + "\nTriggering object is invalid.");
        return;
    }

    // TODO clean up all these declarations
    object oEncounterAOE, oTarget, oTravelArea = GetArea(oPC);
    object oPartyMember = GetFirstFactionMember(oPC);
    float fDistance;
    location lEncounterAOE = GetLocation(oPC);

    while (GetIsObjectValid(oPartyMember))
    {
        Debug("Encounter " + sEncounterID + " started; triggered by " + GetName(oPC));
        if ((fDistance = GetDistanceBetween(oPC, oPartyMember)) == 0.0)
        {
            oPartyMember = GetNextFactionMember(oPC);
            continue;
        }

        if (fDistance <= TRAVEL_ENCOUNTER_WAYPOINT_INCLUDE)
            oTarget = GetWaypointByTag(sPrimaryWaypoint);
        else if (fDistance > TRAVEL_ENCOUNTER_WAYPOINT_INCLUDE && fDistance <= TRAVEL_ENCOUNTER_PARTY_INCLUDE)
            oTarget = GetWaypointByTag(GetListItem(sSecondaryWaypoints, Random(nWaypointCount) + 1));

        _setEncounterVariables(oPartyMember, nEncounterID);
        AssignCommand(oPartyMember, ClearAllActions());
        AssignCommand(oPartyMember, JumpToObject(oTarget));
        Debug("  " + GetName(oPartyMember) + " sent to " + GetTag(oTarget) + " to join encounter " + sEncounterID);

        oPartyMember = GetNextFactionMember(oPC);
    }

    if (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY)
    {
        effect eEncounterAOE = EffectAreaOfEffect(AOE_PER_CUSTOM_AOE, "tr_encounter_OnAOEEnter", "", "");
        ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eEncounterAOE, lEncounterAOE);
        oEncounterAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lEncounterAOE);
        SetTag(oEncounterAOE, ENCOUNTER_AOE + sEncounterID);
        _SetLocalInt(oEncounterAOE, TRAVEL_ENCOUNTER_ID, nEncounterID);
        _SetLocalObject(ENCOUNTERS, ENCOUNTER_AOE + sEncounterID, oEncounterAOE);
        
        //TODO Delete when area_roster works
        int nEncounterPlayerCount = _GetLocalInt(oEncounterArea, ENCOUNTER_AREA_PC_COUNT);
        _SetLocalInt(oEncounterArea, ENCOUNTER_AREA_PC_COUNT, ++nEncounterPlayerCount);

        //Don't let the AOE be dispelled or destroyed
        _SetLocalInt(oTarget, "X1_L_IMMUNE_TO_DISPEL", 10);
        AssignCommand(oEncounterAOE, SetIsDestroyable(FALSE));

        Debug("Encounter AOE for encounter " + sEncounterID + " created.");
    }
}

void tr_encounter_OnAOEEnter()
{
    object oTarget, oEncounterAOE = OBJECT_SELF;
    object oPC = GetEnteringObject();
        
    int    nEncounterID = _GetLocalInt(oEncounterAOE, TRAVEL_ENCOUNTER_ID);
    
    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);
 
    int nWaypointCount = CountList(te.sSecondaryWaypoints);

    if ((TRAVEL_ENCOUNTER_ALLOW_STRANGERS) || (TRAVEL_ENCOUNTER_ALLOW_LATE_ENTRY && _GetIsPartyMember(oPC, te.oTriggeredBy)))
    {
        //if (GetIsObjectValid(te.oEncounterArea) && CountListObject(te.oEncounterArea, AREA_ROSTER))  TODO fix when AREA_ROSTER works
        if (GetIsObjectValid(te.oEncounterArea) && ENCOUNTER_AREA_PC_COUNT)
        {
            if (nWaypointCount)
                oTarget = GetWaypointByTag(GetListItem(te.sSecondaryWaypoints, Random(nWaypointCount) + 1));
            else
                oTarget = GetWaypointByTag(te.sPrimaryWaypoint);

            if (GetIsObjectValid(oTarget))
            {
                AssignCommand(oPC, ClearAllActions());
                AssignCommand(oPC, JumpToObject(oTarget));

                //TODO delete when AREA_ROSTER works
                int nEncounterPlayerCount = _GetLocalInt(oEncounterArea, ENCOUNTER_AREA_PC_COUNT);
                _SetLocalInt(oEncounterArea, ENCOUNTER_AREA_PC_COUNT, ++nEncounterPlayerCount);

                Debug(GetName(oPC) + " has been sent to the encounter area for encounter " +
                    te.sEncounterID + " via the encounter AOE");
            }
            else
                Debug(GetName(oPC) + " is attempting to enter encounter " + te.sEncounterID +
                    "via an AOE entry, but a valid entry waypoint could not be found.");
        }
    }
}

void tr_CheckForEncounter()
{
    object oPartyMember, oPC = OBJECT_SELF;
    int nTimerID, nGoing, nEncounters = _GetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
    int nEncounterID, nMaxEncounters = _GetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS);
    float fDistance;

    if (!_GetIsPC(oPC))
        return;

     if (nEncounters >= nMaxEncounters && TRAVEL_ENCOUNTER_LIMIT)
    {
        nTimerID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER);
        KillTimer(nTimerID);
        Debug("Max encounters reached, no more for these guys.");
        return;
    }
 
    if (GetIsDawn() || GetIsDay())
        nGoing = (Random(100) <= TRAVEL_ENCOUNTER_CHANCE_DAY);
    else
        nGoing = (Random(100) < TRAVEL_ENCOUNTER_CHANCE_NIGHT);

    if (nGoing)
    {
        if (nEncounterID = tf_CreateEncounter(oPC))
            tr_StartEncounter(nEncounterID);
    }
    else
        Debug("Encounter checked for " + GetName(oPC) + ".  Party is staying put for now.");
}

void tr_encounter_OnPlayerExit()
{
    //This needs to be run after the module removes the player from the area_roster
    object oPC = GetExitingObject();
    location lPC = _GetLocalLocation(oPC, TRAVEL_SOURCE_LOCATION);
    int nEncounterID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);;

    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);

    if (!GetIsObjectValid(GetAreaFromLocation(lPC)))
        return;

    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, JumpToLocation(lPC));

    //TODO delete when AREA_ROSTER works
    int nEncounterPlayerCount = _GetLocalInt(oEncounterArea, ENCOUNTER_AREA_PC_COUNT);
    _SetLocalInt(oEncounterArea, ENCOUNTER_AREA_PC_COUNT, --nEncounterPlayerCount);

    //big TODO make sure all required fucntions are exposed in the library script

  

/*  TODO waiting on PR to create AREA_ROSTER
    if (!CountObjectList(te.oEncounterArea, AREA_ROSTER))
        KillEncounter(te.nEncounterID);
*/
    if (!ENCOUNTER_AREA_PC_COUNT)
        KillEncounter(te.nEncounterID);
 }
