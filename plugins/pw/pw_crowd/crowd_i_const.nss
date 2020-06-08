// -----------------------------------------------------------------------------
//    File: crowd_i_const.nss
//  System: Simulated Population (constants)
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

struct CommonerSettings
{
    string CommonerDialog;            // The name of the dialog to reference for the commoner's conversation.
    int NumberOfCommonersDuringDay;   // The maximum number of commoners to spawn during daytime.
    int NumberOfCommonersDuringNight; // The maximum number of commoners to spawn during nighttime.
    int NumberOfCommonersDuringRain;  // The maximum number of commoners to spawn during rain and snow.
                                      // This will not spawn more than NumberOfCommonersDuringDay or
                                      // NumberOfCommonersDuringNight.
    string CommonerResRefPrefix;      // The base ResRef of the commoners to spawn, e.g. "commoner" will spawn
                                      // creatures with ResRef "commoner001", "commoner002", etc.
    int NumberOfCommonerTemplates;    // The number of creature templates with the above ResRef prefix there are.
    int RandomizeClothing;            // Set to TRUE if you wish the commoners to equip random clothing. FALSE if
                                      // they should keep the items they spawn with equipped.
    string ClothingResRefPrefix;      // The base ResRef of the clothing to spawn on the commoners, e.g. "clothing"
                                      // will spawn clothing with ResRef "clothing001", "clothing002" randomly on
                                      // commoners.
    int NumberOfClothingTemplates;    // The number of armor item templates with the above ResRef prefix there are.
    string CommonerTag;               // The tag to assign to the commoners that are spawned (the tag in the template is ignored).
                                      // If you call SpawnAndUpdateCommoners multiple times for an area with different settings,
                                      // make sure you use different tags.
    string CommonerName;              // The name to set on the spawned commoners. Leave empty to use template default.
    string WaypointTag;               // The tag used to identify the waypoints the commoners will be spawning at and moving
                                      // between.
    float MinSpawnDelay;              // The minimum delay to wait after the heartbeat event notices a commoner missing
                                      // until it spawns a new one.
    float MaxSpawnDelay;              // The maximum delay to wait after the heartbeat event notices a commoner missing
                                      // until it spawns a new one.
    int StationaryCommoners;          // Set to TRUE to make the spawned commoners should stay where they spawn.
                                      // If FALSE, they will move to another waypoint in the area and disappear.
    float MaxWalkTime;                // If spawned commoners are not stationary (i.e. they are walking to a destination)
                                      // this is the maximum time they will be walking before teleporting to their destination.
                                      // To avoid the commoners getting stuck forever. Default 30.0 seconds.
};

// CROWDS datapoint contains copies of all the crowd initializer items
const string CROWD_DATA = "CROWD_DATA";
object CROWDS = GetDatapoint(CROWD_DATA);

// List variables for use by crowd initializer items
const string CROWD_ITEM_LOADED_CSV  = "CROWD_ITEM_LOADED_CSV";
const string CROWD_ITEM_OBJECT_LIST = "CROWD_ITEM_OBJECT_LIST";
const string CROWD_ITEM_INITIALIZED = "CROWD_ITEM_INITIALIZED";

// Event variables
const string CROWD_EVENT_ON_TIMER_EXPIRED = "crowd_OnTimerExpired";
const string CROWD_CHECK_TIMER            = "CROWD_CHECK_TIMER";
const string CROWD_CSV                    = "*Crowds";

// CommonerSettings struct variables
const string CROWD_CONVERSATION       = "*Dialog";
const string CROWD_DAYCOUNT           = "CommonerCountDay";
const string CROWD_NIGHTCOUNT         = "CommonerCountNight";
const string CROWD_WXCOUNT            = "CommonerCountWeather";
const string CROWD_NPC_RESREF         = "CommonerResrefPrefix";
const string CROWD_NPC_COUNT          = "CommonerTemplateCount";
const string CROWD_RANDOMIZE_CLOTHING = "RandomizeClothing";
const string CROWD_CLOTHING_RESREF    = "ClothingResrefPrefix";
const string CROWD_CLOTHING_COUNT     = "ClothingTemplateCount";
const string CROWD_NPC_TAG            = "CommonerTag";
const string CROWD_NPC_NAME           = "CommonerName";
const string CROWD_WP_TAG             = "WaypointTag";
const string CROWD_MIN_DELAY          = "MinSpawnDelay";
const string CROWD_MAX_DELAY          = "MaxSpawnDelay";
const string CROWD_STATIONARY_NPC     = "StationaryCommoners";
const string CROWD_NPC_WALK_TIME      = "MaxWalkTime";
