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

    if (!_GetLocalInt(OBJECT_SELF, TRAVEL_ENCOUNTER_AREA))
        return;

    int nTimerID, nReturning = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);

    if (!nReturning)    //Entering area from another area, not from an encounter
    {
        _SetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS, Random(TRAVEL_ENCOUNTER_LIMIT) + Random(TRAVEL_ENCOUNTER_LIMIT_JITTER));
        _SetLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS, 0);

        Debug("Maximum encounters for this PC is " + IntToString(_GetLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS)));

        nTimerID = CreateTimer(oPC, TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE, TRAVEL_ENCOUNTER_TIMER_INTERVAL, 0, TRAVEL_ENCOUNTER_TIMER_JITTER);
        _SetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER, nTimerID);
        StartTimer(nTimerID, FALSE);
    }
    else
    {
        _DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
        nTimerID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER);
        StartTimer(nTimerID, FALSE);
    }

    SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5f);
}

void tr_OnAreaExit()
{
    object oPC = GetExitingObject();

    if (!_GetIsPC(oPC))
        return;

    int nEncounter = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
    int nTimerID = _GetLocalInt(oPC, TRAVEL_ENCOUNTER_TIMER);

    SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 1.0f);

    if (!nEncounter)
    {
        _DeleteLocalInt(oPC, TRAVEL_ENCOUNTER_ID);
        _DeleteLocalInt(oPC, TRAVEL_MAX_ENCOUNTERS);
        _DeleteLocalInt(oPC, TRAVEL_CURRENT_ENCOUNTERS);
        _DeleteLocalLocation(oPC, TRAVEL_SOURCE_LOCATION);

        KillTimer(nTimerID);
    }
    else
        StopTimer(nTimerID);
}
