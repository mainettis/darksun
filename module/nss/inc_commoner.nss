//::///////////////////////////////////////////////
//:: inc_commoner
//:: inc_commoner.nss
//:: Copyright (c) 2018 Rarosu
//:://////////////////////////////////////////////
/*

    Ambient Commoners Script Library

    This script library allows you to spawn NPCs that walk from a source
    location to a target location. The script only requires some settings
    and to be called in the heartbeat script of the areas you want it working
    in. When set up, NPCs will spawn and despawn automatically.

    For simple use, see example below. For more advanced use, see example
    module that is distributed with this script library.

    Example of usage:

    // Heartbeat script of area.
    #include "inc_commoner"

    void main()
    {
        struct CommonerSettings settings;
        settings.NumberOfCommonersDuringDay = 5;
        settings.NumberOfCommonersDuringNight = 1;
        settings.NumberOfCommonersDuringRain = 1;
        settings.CommonerResRefPrefix = "mycommoner";
        settings.NumberOfCommonerTemplates = 4;
        settings.RandomizeClothing = TRUE;
        settings.ClothingResRefPrefix = "myclothing";
        settings.NumberOfClothingTemplates = 3;
        settings.CommonerTag = "Commoner";
        settings.CommonerName = "City Dweller";
        settings.WaypointTag = "WP_COMMONER";
        settings.MinSpawnDelay = 2.0f;
        settings.MaxSpawnDelay = 30.0f;
        settings.StationaryCommoners = FALSE;
        settings.MaxWalkTime = 30.0f;

        SpawnAndUpdateCommoners(settings);
    }



    == CHANGELOG ==

    2018-07-14:
        + Added MaxWalkTime to allow commoners to walk longer distances.
        + Fixed issue with too many commoners spawning during nighttime.

    2018-03-24:
        + Added stationary commoners.

    2018-03-03:
        + Initial release.
*/
//:://////////////////////////////////////////////
//:: Created By: Rarosu
//:: Created On: 2018
//:://////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Structures
////////////////////////////////////////////////////////////////////////////////

// Use this struct to customize the behavior of the spawning commoners.
// To use, in your heartbeat script, do this:
//
//     struct CommonerSettings settings;
//     settings.NumberOfCommonersDuringDay = 4;
//     settings.CommonerResRefPrefix = "mycommoner";
//     // etc. set whatever values you want to change, otherwise reasonable defaults will be used.
//
//     // To then use those settings:
//     SpawnAndUpdateCommoners(settings);
//
//
struct CommonerSettings
{
    // The maximum number of commoners to spawn during daytime.
    int NumberOfCommonersDuringDay;

    // The maximum number of commoners to spawn during nighttime.
    int NumberOfCommonersDuringNight;

    // The maximum number of commoners to spawn during rain and snow.
    // This will not spawn more than NumberOfCommonersDuringDay or
    // NumberOfCommonersDuringNight.
    int NumberOfCommonersDuringRain;

    // The base ResRef of the commoners to spawn, e.g. "commoner" will spawn
    // creatures with ResRef "commoner001", "commoner002", etc.
    string CommonerResRefPrefix;

    // The number of creature templates with the above ResRef prefix there are.
    int NumberOfCommonerTemplates;

    // Set to TRUE if you wish the commoners to equip random clothing. FALSE if
    // they should keep the items they spawn with equipped.
    int RandomizeClothing;

    // The base ResRef of the clothing to spawn on the commoners, e.g. "clothing"
    // will spawn clothing with ResRef "clothing001", "clothing002" randomly on
    // commoners.
    string ClothingResRefPrefix;

    // The number of armor item templates with the above ResRef prefix there are.
    int NumberOfClothingTemplates;

    // The tag to assign to the commoners that are spawned (the tag in the template is ignored).
    // If you call SpawnAndUpdateCommoners multiple times for an area with different settings,
    // make sure you use different tags.
    string CommonerTag;

    // The name to set on the spawned commoners. Leave empty to use template default.
    string CommonerName;

    // The tag used to identify the waypoints the commoners will be spawning at and moving
    // between.
    string WaypointTag;

    // The minimum delay to wait after the heartbeat event notices a commoner missing
    // until it spawns a new one.
    float MinSpawnDelay;

    // The maximum delay to wait after the heartbeat event notices a commoner missing
    // until it spawns a new one.
    float MaxSpawnDelay;

    // Set to TRUE to make the spawned commoners should stay where they spawn.
    // If FALSE, they will move to another waypoint in the area and disappear.
    int StationaryCommoners;

    // If spawned commoners are not stationary (i.e. they are walking to a destination)
    // this is the maximum time they will be walking before teleporting to their destination.
    // To avoid the commoners getting stuck forever. Default 30.0 seconds.
    float MaxWalkTime;
};

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////

// The ResRef prefix to use if the CommonerResRefPrefix is empty in the settings.
const string COMMONER_DEFAULT_RESREF_PREFIX = "commoner";

// The ResRef prefix to use for clothing if the ClothingResRefPrefix is empty in the settings.
const string COMMONER_DEFAULT_CLOTHING_RESREF_PREFIX = "clothing";

// The tag to set on spawned commoners if CommonerTag is empty in the settings.
const string COMMONER_DEFAULT_TAG = "Commoner";

// If WaypointTag is not set in the settings, the script will look for waypoints
// with this tag to spawn commoners at and move them between.
const string COMMONER_DEFAULT_WAYPOINT_TAG = "WP_COMMONER";

// The default delay to use between spawning commoners if the values in the settings
// are invalid. The values are considered invalid if both of them are zero or the max
// delay is less than the min delay.
const float COMMONER_DEFAULT_MIN_SPAWN_DELAY = 2.0f;
const float COMMONER_DEFAULT_MAX_SPAWN_DELAY = 30.0f;

////////////////////////////////////////////////////////////////////////////////
// Function definitions
////////////////////////////////////////////////////////////////////////////////

// Call this in the OnHeartbeat script of your area. This will keep the area
// populated with commoners if there are players inside of it and clean up
// the area otherwise.
void SpawnAndUpdateCommoners(struct CommonerSettings settings, object area = OBJECT_SELF);

// Call this whenever your commoners are interrupted and you want them to resume
// what they were doing. For instance, call this after a conversation with the
// commoners have concluded.
void ResumeCommonerBehavior(object commoner = OBJECT_SELF);

////////////////////////////////////////////////////////////////////////////////
// Function implementations
////////////////////////////////////////////////////////////////////////////////

void Debug(string s)
{
    SendMessageToPC(GetFirstPC(), s);
    WriteTimestampedLogEntry(s);
}

int Min(int a, int b)
{
    return a < b ? a : b;
}

float GetRandomFloat(float min, float max)
{
    float precision = 10.0f;
    int iMin = FloatToInt(min * precision);
    int iMax = FloatToInt(max * precision);
    int iRandom = Random(iMax - iMin) + iMin;

    return IntToFloat(iRandom) / precision;
}

int IsCommonerAreaActive(object area, string commonerTag)
{
    return GetLocalInt(area, "CommonerAreaActive_" + commonerTag);
}

void SetCommonerAreaActive(object area, string commonerTag, int value)
{
    SetLocalInt(area, "CommonerAreaActive_" + commonerTag, value);
}

int GetNumberOfCommonersWaitingToSpawn(object area, string commonerTag)
{
    return GetLocalInt(area, "CommonersWaitingToSpawn_" + commonerTag);
}

void SetNumberOfCommonersWaitingToSpawn(object area, string commonerTag, int value)
{
    if (value < 0)
        value = 0;
    SetLocalInt(area, "CommonersWaitingToSpawn_" + commonerTag, value);
}

object GetPlayerInArea(object area)
{
    object pc = GetFirstPC();
    while (pc != OBJECT_INVALID)
    {
        if (GetArea(pc) == area)
        {
            return pc;
        }

        pc = GetNextPC();
    }

    return OBJECT_INVALID;
}

void DestroyAllCreaturesByTagInArea(object area, string tag)
{
    location areaOrigin = Location(area, Vector(), 0.0f);

    int nth = 1;
    object creature = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, areaOrigin, nth);
    while (creature != OBJECT_INVALID)
    {
        if (GetTag(creature) == tag)
        {
            SetPlotFlag(creature, FALSE);
            DestroyObject(creature);
        }

        nth++;
        creature = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, areaOrigin, nth);
    }
}

void CleanCommonerArea(object area, struct CommonerSettings settings)
{
    DestroyAllCreaturesByTagInArea(area, settings.CommonerTag);

    SetNumberOfCommonersWaitingToSpawn(area, settings.CommonerTag, 0);
    SetCommonerAreaActive(area, settings.CommonerTag, FALSE);
}

int GetNumberOfObjectsInAreaByTag(object objectInArea, string tag)
{
    int nth = 1;
    object obj = GetNearestObjectByTag(tag, objectInArea, nth);
    while (obj != OBJECT_INVALID)
    {
        nth++;
        obj = GetNearestObjectByTag(tag, objectInArea, nth);
    }

    return nth - 1;
}

int GetMaxNumberOfCommoners(object area, struct CommonerSettings settings)
{
    int max = settings.NumberOfCommonersDuringDay;

    if (GetIsNight())
    {
        max = settings.NumberOfCommonersDuringNight;
    }

    int weather = GetWeather(area);
    if (weather == WEATHER_RAIN || weather == WEATHER_SNOW)
    {
        max = Min(max, settings.NumberOfCommonersDuringRain);
    }

    return max;
}

string GetResRefSuffix(int index)
{
    if (index < 10)
        return "00" + IntToString(index);
    if (index < 100)
        return "0" + IntToString(index);
    return IntToString(index);
}

string GetResRefFromPrefix(string prefix, int numberOfTemplates)
{
    int index = Random(numberOfTemplates) + 1;
    return prefix + GetResRefSuffix(index);
}

void MakeCommonerWalk(object commoner, object originWP, int numberOfWaypoints, struct CommonerSettings settings)
{
    object targetWP = GetNearestObjectByTag(settings.WaypointTag, originWP, Random(numberOfWaypoints - 1) + 1);
    if (targetWP == OBJECT_INVALID || targetWP == originWP)
    {
        return;
    }

    SetLocalObject(commoner, "CommonerTargetWaypoint", targetWP);
    AssignCommand(commoner, ActionForceMoveToObject(targetWP, FALSE, 1.0f, settings.MaxWalkTime));
    AssignCommand(commoner, ActionDoCommand(DestroyObject(commoner)));
}

void SpawnCommoner(object area, struct CommonerSettings settings)
{
    // Check if a commoner should spawn, and if so, update the number of commoners waiting to spawn.
    int numberOfCommonersWaitingToSpawn = GetNumberOfCommonersWaitingToSpawn(area, settings.CommonerTag);
    SetNumberOfCommonersWaitingToSpawn(area, settings.CommonerTag, numberOfCommonersWaitingToSpawn - 1);

    // Do not spawn a commoner if no PC is in the area.
    object pc = GetPlayerInArea(area);
    if (pc == OBJECT_INVALID)
    {
        return;
    }

    // Find out where to spawn the commoner.
    int numberOfWaypoints = GetNumberOfObjectsInAreaByTag(pc, settings.WaypointTag);
    object originWP = GetNearestObjectByTag(settings.WaypointTag, pc, Random(numberOfWaypoints) + 1);

    if (originWP == OBJECT_INVALID)
    {
        return;
    }

    // Find out what resref to use to spawn the commoner.
    string resref = GetResRefFromPrefix(settings.CommonerResRefPrefix, settings.NumberOfCommonerTemplates);
    object commoner = CreateObject(OBJECT_TYPE_CREATURE, resref, GetLocation(originWP), FALSE, settings.CommonerTag);

    if (settings.CommonerName != "")
    {
        // Optionally set the name.
        SetName(commoner, settings.CommonerName);
    }

    if (settings.RandomizeClothing)
    {
        // Optionally give randomized clothing.
        string clothingResRef = GetResRefFromPrefix(settings.ClothingResRefPrefix, settings.NumberOfClothingTemplates);
        object clothing = CreateItemOnObject(clothingResRef, commoner);
        if (clothing != OBJECT_INVALID)
        {
            AssignCommand(commoner, ActionEquipItem(clothing, INVENTORY_SLOT_CHEST));
        }
    }

    if (!settings.StationaryCommoners)
    {
        // Optionally make the commoner walk to a destination.
        MakeCommonerWalk(commoner, originWP, numberOfWaypoints, settings);
    }
}

void DelayAndSpawnCommoner(object area, struct CommonerSettings settings)
{
    float delay = GetRandomFloat(settings.MinSpawnDelay, settings.MaxSpawnDelay);
    DelayCommand(delay, SpawnCommoner(area, settings));
}

struct CommonerSettings SanitizeSettings(struct CommonerSettings settings)
{
    if (settings.CommonerResRefPrefix == "")
        settings.CommonerResRefPrefix = COMMONER_DEFAULT_RESREF_PREFIX;
    if (settings.NumberOfCommonerTemplates < 1)
        settings.NumberOfCommonerTemplates = 1;
    if (settings.ClothingResRefPrefix == "")
        settings.ClothingResRefPrefix = COMMONER_DEFAULT_CLOTHING_RESREF_PREFIX;
    if (settings.NumberOfClothingTemplates < 1)
        settings.NumberOfClothingTemplates = 1;
    if (settings.CommonerTag == "")
        settings.CommonerTag = COMMONER_DEFAULT_TAG;
    if (settings.WaypointTag == "")
        settings.WaypointTag = COMMONER_DEFAULT_WAYPOINT_TAG;

    float epsilon = 0.0001f;
    if (settings.MinSpawnDelay <= epsilon && settings.MaxSpawnDelay <= epsilon ||
        settings.MaxSpawnDelay < settings.MinSpawnDelay)
    {
        settings.MinSpawnDelay = COMMONER_DEFAULT_MIN_SPAWN_DELAY;
        settings.MaxSpawnDelay = COMMONER_DEFAULT_MAX_SPAWN_DELAY;
    }

    if (settings.MaxWalkTime < 1.0f)
        settings.MaxWalkTime = 30.0f;

    // Have at least one commoner during day if all max values are set to 0.
    if (settings.NumberOfCommonersDuringDay == 0 &&
        settings.NumberOfCommonersDuringNight == 0 &&
        settings.NumberOfCommonersDuringRain == 0)
    {
        settings.NumberOfCommonersDuringDay = 1;
    }

    return settings;
}

void SpawnAndUpdateCommoners(struct CommonerSettings settings, object area = OBJECT_SELF)
{
    object pc = GetPlayerInArea(area);
    if (pc == OBJECT_INVALID)
    {
        if (IsCommonerAreaActive(area, settings.CommonerTag))
        {
            CleanCommonerArea(area, settings);
        }

        return;
    }

    SetCommonerAreaActive(area, settings.CommonerTag, TRUE);
    settings = SanitizeSettings(settings);

    int maxNumberOfCommoners = GetMaxNumberOfCommoners(area, settings);
    int numberOfCommoners = GetNumberOfObjectsInAreaByTag(pc, settings.CommonerTag);
    int numberOfCommonersWaitingToSpawn = GetNumberOfCommonersWaitingToSpawn(area, settings.CommonerTag);

    while (numberOfCommoners + numberOfCommonersWaitingToSpawn < maxNumberOfCommoners)
    {
        DelayAndSpawnCommoner(area, settings);

        numberOfCommonersWaitingToSpawn++;
        SetNumberOfCommonersWaitingToSpawn(area, settings.CommonerTag, numberOfCommonersWaitingToSpawn);
    }
}

void ResumeCommonerBehavior(object commoner = OBJECT_SELF)
{
    object destination = GetLocalObject(commoner, "CommonerTargetWaypoint");
    if (destination == OBJECT_INVALID)
    {
        return;
    }

    AssignCommand(commoner, ActionForceMoveToObject(destination));
    AssignCommand(commoner, ActionDoCommand(DestroyObject(commoner)));
}

////////////////////////////////////////////////////////////////////////////////
// For compilation
////////////////////////////////////////////////////////////////////////////////
//void main() {}

