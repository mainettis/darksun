// -----------------------------------------------------------------------------
//    File: crowd_i_events.nss
//  System: Simulated Population (events)
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

#include "crowd_i_main"
#include "dsutil_i_data"
#include "dsutil_i_map"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< crowd_OnModuleLoad >---
// Library and event registered function to initialize crowd/simulate population
//  variables based on custom crowd initializer items.
void crowd_OnModuleLoad();

// ---< crowd_OnAreaEnter >---
// Library and event registered function that will start a timer to check for
//  updating any assigned crowds if there are PCs in the area.
void crowd_OnAreaEnter();

// ---< crowd_OnAreaExit >---
// Library and event registered function that will stop a running crowd timer
//  and clear the area of any crowds that have been spawned.
void crowd_OnAreaExit();

// ---< crowd_OnTimerExpire >---
// Library and event registered function that will check if a PC is in the area
//  and, if so, check on the area-assigned crowds to see if any NPCs need to
//  to be spawn/despawned.
void crowd_OnTimerExpire();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void crowd_OnModuleLoad()
{
    if (!_GetLocalInt(CROWDS, CROWD_ITEM_INITIALIZED))
        InitializeSystem(CROWDS, CROWD_ITEM_INVENTORY, CROWD_ITEM_LOADED_CSV,
                        CROWD_ITEM_PREFIX, CROWD_ITEM_OBJECT_LIST,
                        CROWD_ITEM_INITIALIZED, FALSE);
}

void crowd_OnAreaEnter()
{
    object oPC = GetEnteringObject();
    if (!_GetIsPC(oPC))
        return;

    if (!_GetLocalInt(CROWDS, CROWD_ITEM_INITIALIZED))
        crowd_OnModuleLoad();
    
    string sCrowds = _GetLocalString(OBJECT_SELF, CROWD_CSV);

    if (sCrowds == "")
        return;

    if (!_GetLocalInt(OBJECT_SELF, CROWD_CHECK_TIMER))
    {
        int nTimerID = CreateTimer(OBJECT_SELF, CROWD_EVENT_ON_TIMER_EXPIRED, CROWD_CHECK_INTERVAL);
        StartTimer(nTimerID, TRUE);
        _SetLocalInt(OBJECT_SELF, CROWD_CHECK_TIMER, nTimerID);
    }
}

void crowd_OnAreaExit()
{
    object oPC = GetExitingObject();
    if (!_GetIsPC(oPC))
        return;

    int nTimerID = _GetLocalInt(OBJECT_SELF, CROWD_CHECK_TIMER);
    if (nTimerID)
        KillTimer(nTimerID);
    
    if (!CountObjectList(OBJECT_SELF, AREA_ROSTER))
        ClearCrowds();
}

void crowd_OnTimerExpired()
{
    SpawnCrowds();
}
