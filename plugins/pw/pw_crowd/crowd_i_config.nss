// -----------------------------------------------------------------------------
//    File: crowd_i_config.nss
//  System: Simulated Population (configuration)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Configuration File for PW Subsystem.
// -----------------------------------------------------------------------------
// Builder Use:
//  Set the constants below as directed in the comments for each constant.
// -----------------------------------------------------------------------------
// Acknowledgment:
// -----------------------------------------------------------------------------
//  Revision:
//      Date:
//    Author:
//   Summary:
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Variables
// -----------------------------------------------------------------------------

// The crowd/simulated population system uses custom game objects with specific
//  variables to initialize crowd objects.  CROWD_ITEM_PREFIX is the prefix
//  of the item being used to initialize the crowd object.  All initialization
//  objects must start with this prefix.  This CSV is a list of those crowd
//  objects that will be loaded on module load.  For example, if you wanted to
//  load a crowd object called `crowd_KlegGuard`, you would include `KlegGuard`
//  in the CROWD_ITEM_INVENTORY list and `crowd_` as the CROWD_ITEM_PREVIX
//  value.  The CROWD_ITEM_INVENTORY should list all possible crowds in the
//  entire module, even if they're not used in the area you're building.
string CROWD_ITEM_INVENTORY = "start";
const string CROWD_ITEM_PREFIX = "crowd_";

// The crowd system will re-check the simulated population every so often to
//  see if more NPCs need to be spawned or if they all need to be despawned.
//  This is the interval at which the system will make that check.
const float CROWD_CHECK_INTERVAL = 45.0f;

// The default NPC resref to use if the `CommonerResRefPrefix` setting is empty.
//  these NPCs will be part of the crowd, so there should be several of them or
//  varying races.
const string COMMONER_DEFAULT_RESREF_PREFIX = "commoner";

// The default clothing resref to use if the `ClothingResRefPrefix` setting is
//  empty.  These items will be used to randomly cloth the crowds so they don't
//  all look the same.
const string COMMONER_DEFAULT_CLOTHING_RESREF_PREFIX = "clothing";

// The tag set on each spawn crowd member if the `CommonerTag` setting is empty.
const string COMMONER_DEFAULT_TAG = "crowd_member";

// The tag set on individual waypoints associated with the simulated populatoin
//  system.  Crown members will be spawned and will walk between these waypoints.
//  This tag is used only if the `WaypointTag` is not set in the setting.
const string COMMONER_DEFAULT_WAYPOINT_TAG = "WP_CROWD";

// The default delay to use between spawning crowd members if the values in the settings
// are invalid. The values are considered invalid if both of them are zero or the max
// delay is less than the min delay.
const float COMMONER_DEFAULT_MIN_SPAWN_DELAY = 2.0f;
const float COMMONER_DEFAULT_MAX_SPAWN_DELAY = 30.0f;
