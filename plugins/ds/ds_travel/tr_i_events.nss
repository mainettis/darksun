// -----------------------------------------------------------------------------
//    File: tr_i_events.nss
//  System: Travel (events)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Event functions for PW Subsystem.
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

#include "tr_i_main"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< tr_OnAreaEnter >---
// Local OnAreaEnter event function for overland travel maps.  This function
//  initiates the encounter variables for the current travel map and starts
//  the encounter check timer for each PC.
void tr_OnAreaEnter();

// ---< tr_OnAreaEnter >---
// Local OnAreaExit event function for overland travel maps.  This function
//  cleans up the variables set when the PC entered the map.
void tr_OnAreaExit();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void tr_OnAreaEnter()
{
    object oPC = GetEnteringObject();

    if (!_GetIsPC(oPC))
        return;

    int nTimerID, nReturning = GetPlayerInt(oPC, TRAVEL_ENCOUNTER_ID);

    if (!nReturning)    //Entering area from another area, not from an encounter
    {
        SetPlayerInt(oPC, TRAVEL_MAX_ENCOUNTERS, Random(TRAVEL_ENCOUNTER_LIMIT) + Random(TRAVEL_ENCOUNTER_LIMIT_JITTER));
        SetPlayerInt(oPC, TRAVEL_CURRENT_ENCOUNTERS, 0);

        Debug("Maximum encounters for this PC is " + IntToString(GetPlayerInt(oPC, TRAVEL_MAX_ENCOUNTERS)));

        nTimerID = CreateTimer(oPC, TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE, TRAVEL_ENCOUNTER_TIMER_INTERVAL, 0, TRAVEL_ENCOUNTER_TIMER_JITTER);
        SetPlayerInt(oPC, TRAVEL_ENCOUNTER_TIMER, nTimerID);
        StartTimer(nTimerID, FALSE);
    }
    else
    {
        DeletePlayerInt(oPC, TRAVEL_ENCOUNTER_ID);
        nTimerID = GetPlayerInt(oPC, TRAVEL_ENCOUNTER_TIMER);
        StartTimer(nTimerID, FALSE);
    }

    SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5f);
}

void tr_OnAreaExit()
{
    object oPC = GetExitingObject();

    if (!_GetIsPC(oPC))
        return;

    int nEncounter = GetPlayerInt(oPC, TRAVEL_ENCOUNTER_ID);
    int nTimerID = GetPlayerInt(oPC, TRAVEL_ENCOUNTER_TIMER);

    SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 1.0f);

    if (!nEncounter)
    {
        DeletePlayerInt(oPC, TRAVEL_ENCOUNTER_ID);
        DeletePlayerInt(oPC, TRAVEL_MAX_ENCOUNTERS);
        DeletePlayerInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
        DeletePlayerLocation(oPC, TRAVEL_SOURCE_LOCATION);

        KillTimer(nTimerID);
    }
    else
        StopTimer(nTimerID);
}
