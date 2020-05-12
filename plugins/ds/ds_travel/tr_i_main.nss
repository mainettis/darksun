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

void _setEncounterVariables(object oPC, int nEncounterID)
{
    int nEncounters = GetPlayerInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
    
    SetPlayerInt(oPC, TRAVEL_CURRENT_ENCOUNTERS, ++nEncounters);
    SetPlayerInt(oPC, TRAVEL_ENCOUNTER_ID, nEncounterID);
    SetPlayerLocation(oPC, TRAVEL_SOURCE_LOCATION, GetLocation(oPC));
}

struct TRAVEL_ENCOUNTER tr_GetEncounterData(int nEncounterID)
{
    struct TRAVEL_ENCOUNTER te;

    te.nEncounterID = nEncounterID;
    te.sEncounterID = IntToString(nEncounterID);
    te.oEncounterArea = GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + te.sEncounterID);
    te.oTriggeredBy = GetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY + te.sEncounterID);
    te.sPrimaryWaypoint = GetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT + te.sEncounterID);
    te.sSecondaryWaypoints = GetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + te.sEncounterID);

    return te;
}

int tf_CreateEncounter(object oPC)
{
    object oEncounterArea, oTravelArea = GetArea(oPC);
    string sSecondaryWaypoints, sWaypointTag, sWaypoints, sTriggers, sSpawns, sEncounterArea, sEncounterAreas = GetLocalString(oTravelArea, ENCOUNTER_AREAS);
    int nWaypointType, nArea, nEncounterID, nCount = CountList(sEncounterAreas);
    int i = 2;
    string sEncounterID = IntToString(nEncounterID);

    if (!nCount)
    {
        Debug("Unable to create encounter, no encounter areas defined on oTravelArea's ENCOUNTER_AREA variable.");
        return 0;
    }

    Debug("Creating encounter for " + GetName(oPC));
    
    //TODO Create ENCOUNTERS data object
    nEncounterID = GetLocalInt(ENCOUNTERS, ENCOUNTER_NEXT_ID);
    
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
        {
            nWaypointType = GetLocalInt(oAreaObject, "*Type");
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

    SetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT    + sEncounterID, ENCOUNTER_WAYPOINT_TAG + sEncounterID + IntToString(1));
    SetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID, sSecondaryWaypoints);
    SetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY        + sEncounterID, oPC);
    SetLocalObject(ENCOUNTERS, ENCOUNTER_AREA                + sEncounterID, oEncounterArea);
    SetLocalInt   (ENCOUNTERS, ENCOUNTER_NEXT_ID                           , ++nEncounterID);

    //This was never pulled into the framework, send PR for On EMPTY event
    SetLocalString(oEncounterArea, AREA_EVENT_ON_EMPTY, "tr_KillEncounter");
    SetLocalString(oEncounterArea, MODULE_EVENT_ON_PLAYER_DEATH, "tr_encounter_OnPlayerDeath");

    Debug("Successfully created encounter with ID " + sEncounterID);
    return nEncounterID;
}

void tr_KillEncounter(int nEncounterID = 0)
{
    string sEncounterID = IntToString(nEncounterID);
    object oEncounterArea = nEncounterID ? GetLocalObject(ENCOUNTERS, ENCOUNTER_AREA + sEncounterID) : OBJECT_SELF;



    //Search for dead bodies and bring them back.
    oObject = GetFirstObjectInArea(oEncounterArea)
    {
        while (GetIsObjectValid(oObject))
        {
            string sObjectTag = GetTag(oObject);

            if (GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE
                && GetStringLeft(sObjectTag, GetStringLength(H2_CORPSE)) == H2_CORPSE)
            {
                //This is the corpse we're looking for.
                //Get the player now.  This is stupid, can we incorporate the UUID so as not to loop through all the PCs?
                //  or access/set the pc object on the dead thing and the loot bag so we can quickly grab the pc and
                //  put them both back on the travel map?  See memeticai for variable inheritence basics?
                uniquePCID = GetStringRight(sObjectTag, GetStringLength(sObjectTag) - GetStringLength(H2_CORPSE));
/*  ----------------------------- working here -------------------  TODO  -----------------*/
//  find all the corpses, if any, then move them back to their starting locations.
            }
        }
    }

    if (!DestroyArea(oEncounterArea))
    {
        Debug("Cannot kill encounter " + sEncounterID + "; PCs detected in encounter area.");
        return;
    }    

    DeleteLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT    + sEncounterID);
    DeleteLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID);
    DeleteLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY        + sEncounterID);
    DeleteLocalObject(ENCOUNTERS, ENCOUNTER_AREA                + sEncounterID);
}

void tr_StartEncounter(int nEncounterID)
{
    string sEncounterID = IntToString(nEncounterID);
    object oPC = GetLocalObject(ENCOUNTERS, ENCOUNTER_TRIGGERED_BY + sEncounterID);
    string sPrimaryWaypoint = GetLocalString(ENCOUNTERS, ENCOUNTER_PRIMARY_WAYPOINT + sEncounterID);
    string sSecondaryWaypoints = GetLocalString(ENCOUNTERS, ENCOUNTER_SECONDARY_WAYPOINTS + sEncounterID);
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
        SetLocalInt(oEncounterAOE, ENCOUNTER_ID, nEncounterID);

        Debug("Encounter AOE for encounter " + sEnounterID + " created.");
    }
}

void tr_encounter_OnAOEEnter()
{
    object oTarget, oEncounterAOE = OBJECT_SELF;
    object oPC = GetEnteringObject();
        
    int    nEncounterID = GetLocalInt(oEncounterAOE, ENCOUNTER_ID);
    
    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);
 
    int nWaypointCount = CountList(te.sSecondaryWaypoints);

    if ((TRAVEL_ENCOUNTER_ALLOW_STRANGERS) || (TRAVEL_ENCOUNTER_CREATE_AOE && _IsPartyMember(oPC, te.oTriggeringPC)))
    {
        if (GetIsObjectValid(te.oEncounterArea) && CountListObject(te.oEncounterArea, AREA_ROSTER))
        {
            if (nWaypointCount)
                oTarget = GetWaypointByTag(GetListItem(te.sSecondaryWaypoints, Random(nWaypointCount) + 1));
            else
                oTarget = GetWaypointByTag(te.sPrimaryWaypoint);

            if (GetIsObjectValid(oTarget))
            {
                AssignCommand(oPC, ClearAllActions());
                AssignCommand(oPC, JumpToObject(oTarget));

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
    int nTimerID, nGoing, nEncounters = GetPlayerInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
    int nEncounterID, nMaxEncounters = GetPlayerInt(oPC, TRAVEL_MAX_ENCOUNTERS);
    float fDistance;

    if (!_GetIsPC(oPC))
        return;

     if (nEncounters >= nMaxEncounters && TRAVEL_ENCOUNTER_LIMIT)
    {
        nTimerID = GetPlayerInt(oPC, TRAVEL_ENCOUNTER_TIMER);
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
    location lPC = GetPlayerLocation(oPC, TRAVEL_SOURCE_LOCATION);
    int nEncounterID = GetPlayerInt(oPC, ENCOUNTER_ID);;

    if (!GetIsObjectValid(GetAreaFromLocation(lPC)))
        return;

    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, JumpToLocation(lPC));

    struct TRAVEL_ENCOUNTER te = tr_GetEncounterData(nEncounterID);

    if (!CountObjectList(te.oEncounterArea, AREA_ROSTER))
        KillEncounter(te.nEncounterID);
 }
