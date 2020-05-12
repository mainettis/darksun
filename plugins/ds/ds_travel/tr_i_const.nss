// -----------------------------------------------------------------------------
//    File: tr_i_const.nss
//  System: Travel (constants)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Constants for PW Subsystem.
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

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// TODO clean up these constants

// ----- Custom Events
const string TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE = "Encounter_OnTimerExpire";

// ----- Variables
const string TRAVEL_MAX_ENCOUNTERS = "TRAVEL_MAX_ENCOUNTERS";
const string TRAVEL_CURRENT_ENCOUNTERS = "TRAVEL_CURRENT_ENCOUNTERS";
const string TRAVEL_PARTY_ENCOUNTERS = "TRAVEL_PARTY_ENCOUNTERS";
const string TRAVEL_ENCOUNTER_ID = "TRAVEL_ENCOUNTER_ID";
//const string TRAVEL_ENCOUNTER_ACTIVE = "TRAVEL_ENCOUNTER_ACTIVE";
const string TRAVEL_ENCOUNTER_TIMER = "TRAVEL_ENCOUNTER_TIMER";
const string TRAVEL_SOURCE_LOCATION = "TRAVEL_SOURCE_LOCATION";

const string ENCOUNTER_AREAS = "ENCOUNTER_AREAS";
const string ENCOUNTER_AOE = "ENCOUNTER_AOE";

struct TRAVEL_ENCOUNTER
{
    int nEncounterID;
    string sEncounterID;
    object oTriggeredBy;
    object oEncounterArea;
    string sPrimaryWaypoint;
    string sSecondaryWaypoints;
};

