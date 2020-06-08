// -----------------------------------------------------------------------------
//    File: crowd_i_main.nss
//  System: Simulated Population (core)
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

#include "crowd_i_config"
#include "crowd_i_const"
#include "crowd_i_text"
#include "util_i_math"
#include "dsutil_i_data"
#include "core_i_constants"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< GetSettings >---
// Returns a CommonerSettings structure of all values set on variable of the
//  crowd initializer item at nIndex.
struct CommonerSettings GetSettings(int nIndex);

// ---< SpawnCrowds >---
// Loops through the area's crowd initializer items, loads variables from those
//  items into a CommonerSettingStructure and calls the primary function to
//  spawn and update the referenced crowd.
void SpawnCrowds();

// ---< ClearCrowds >---
// Loops through the area's crowd initializer items, finds the tags of the crowd
//  members that are active and destroys all crowd members.  This is called from
//  crowd_OnAreaExit (event) when there are no PCs in the area.
void ClearCrowds();

// ---< GetRandomFloat >---
// Generates and returns a random float between min and max.
float GetRandomFloat(float min, float max);

// ---< GetIsCommonerAreaActive >---
// Returns value of variable set when Area is active with crowds.
int GetIsCommonerAreaActive(object area, string commonerTag);

// ---< SetCommonerAreaActive >---
// Sets value of variable when Area is active with crowds;
void SetCommonerAreaActive(object area, string commonerTag, int value);

// ---< GetNumberOfCommonersWaitingToSpawn >---
// Returns value of variable set when Area is active with crowds.
int GetNumberOfCommonersWaitingToSpawn(object area, string commonerTag);

// ---< SetNumberOfCommonersWaitingToSpawn >---
// Sets value of variable when Area is active with crowds;
void SetNumberOfCommonersWaitingToSpawn(object area, string commonerTag, int value);

// ---< GetPlayerInArea >---
// Determines where a PC is present in the area by checking the area's
//  AREA_ROSTER.
int GetPlayerInArea(object area);

// ---< DestroyCrowd >---
// Loops through all creatures with tag tag in area area and destroys them.
void DestroyCrowd(object area, string tag);

// ---< CleanCommonerArea >---
// Using passed CommonSettings structure, destroys all associated crowd objects
//  and reset associated variables.
void CleanCommonerArea(object area, struct CommonerSettings settings);

// ---< GetNumberOfObjectsInAreaByTag >---
// Starting from objectInArea, loops through all creatures in the area and returns
//  count of all creatures matching tag.
int GetNumberOfObjectsInAreaByTag(object objectInArea, string tag);

// ---< GetMaxNumberOfCommoners >---
// Using the three commoner count variables set on the crown initializer item,
//  returns the correct count of the max number of commoners to be spawned.
int GetMaxNumberOfCommoners(object area, struct CommonerSettings settings);

// ---< GetResRefSuffix >---
// Modified index to a fixed-width string.
string GetResRefSuffix(int index);

// ---< GetResRefFromPrefix >---
// Adds a fixed-width string representing a random commoner template to
//  the commoner resref prefix.
string GetResRefFromPrefix(string prefix, int numberOfTemplates);

// ---< MakeCommonerWalk >---
// Selects a waypoint for the crowd member to walk to and forces the crowd
//  member to walk to that point.
void MakeCommonerWalk(object commoner, object originWP, int numberOfWaypoints, struct CommonerSettings settings);

// ---< SpawnCommoner >---
// Primary function for spawning a crowd member.  This function will select the
//  NPC resref, clothing resref and spawn location for the crowd member.
void SpawnCommoner(object area, struct CommonerSettings settings);

// ---< DelayAndSpawnCommoner >---
// This function randomly delays spawning the next crowd member by an amount
// between the min and max delays settings on the crowd initializer item.
void DelayAndSpawnCommoner(object area, struct CommonerSettings settings);

// ---< SanitizeSettings >---
// Ensures all settings in a CommonerSettings structure have valid values. If
//  item initializer variables were not included, default values will be set.
struct CommonerSettings SanitizeSettings(struct CommonerSettings settings);

// ---< SpawnAndUpdateCommoners >---
// Called from the timer expiration event, this function check to see if any
//  new crowd members need to be spawned and, if so, sets them up for spawning.
void SpawnAndUpdateCommoners(struct CommonerSettings settings, object area = OBJECT_SELF);

// ---< ResumeCommonerBehavior >---
// Since all NPCs can be interacted with, this function will return an NPC to
//  their routine after being interupted by a PC.
void ResumeCommonerBehavior(object commoner = OBJECT_SELF);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

struct CommonerSettings GetSettings(int nIndex)
{
    struct CommonerSettings cs;

    object oGroup = GetListObject(CROWDS, nIndex, CROWD_ITEM_OBJECT_LIST);
    Debug("GetSettings:  oGroup = " + GetName(oGroup));
    if (GetIsObjectValid(oGroup))
    {
        cs.CommonerDialog               = _GetLocalString(oGroup, CROWD_CONVERSATION);
        cs.NumberOfCommonersDuringDay   = _GetLocalInt(oGroup, CROWD_DAYCOUNT);
        cs.NumberOfCommonersDuringNight = _GetLocalInt(oGroup, CROWD_NIGHTCOUNT);
        cs.NumberOfCommonersDuringRain  = _GetLocalInt(oGroup, CROWD_WXCOUNT);
        cs.CommonerResRefPrefix         = _GetLocalString(oGroup, CROWD_NPC_RESREF);
        cs.NumberOfCommonerTemplates    = _GetLocalInt(oGroup, CROWD_NPC_COUNT);
        cs.RandomizeClothing            = _GetLocalInt(oGroup, CROWD_RANDOMIZE_CLOTHING);
        cs.ClothingResRefPrefix         = _GetLocalString(oGroup, CROWD_CLOTHING_RESREF);
        cs.NumberOfClothingTemplates    = _GetLocalInt(oGroup, CROWD_CLOTHING_COUNT);
        cs.CommonerTag                  = _GetLocalString(oGroup, CROWD_NPC_TAG);
        cs.CommonerName                 = _GetLocalString(oGroup, CROWD_NPC_NAME);
        cs.WaypointTag                  = _GetLocalString(oGroup, CROWD_WP_TAG);
        cs.MinSpawnDelay                = _GetLocalFloat(oGroup, CROWD_MIN_DELAY);
        cs.MaxSpawnDelay                = _GetLocalFloat(oGroup, CROWD_MAX_DELAY);
        cs.StationaryCommoners          = _GetLocalInt(oGroup, CROWD_STATIONARY_NPC);
        cs.MaxWalkTime                  = _GetLocalFloat(oGroup, CROWD_NPC_WALK_TIME);
    }

    return cs;
}

void SpawnCrowds()
{
    string sCrowds = _GetLocalString(OBJECT_SELF, CROWD_CSV);

    int i, nIndex, nCount = CountList(sCrowds);
    for (i = 0; i < nCount; i++)
    {
        string sCrowd = GetListItem(sCrowds, i);
        if ((nIndex = FindListItem(sCrowds, sCrowd)) > -1)
        {
            struct CommonerSettings cs = GetSettings(nIndex);
            SpawnAndUpdateCommoners(cs);
        }
    }
}

void ClearCrowds()
{
    string sCrowds = _GetLocalString(OBJECT_SELF, CROWD_CSV);

    int i, nIndex, nCount = CountList(sCrowds);
    for (i = 0; i < nCount; i++)
    {
        string sCrowd = GetListItem(sCrowds, i);
        if ((nIndex = FindListItem(sCrowds, sCrowd)) > -1)
        {
            struct CommonerSettings cs = GetSettings(nIndex);
            CleanCommonerArea(OBJECT_SELF, cs);
        }
    } 
}

float GetRandomFloat(float min, float max)
{
    float precision = 10.0f;
    int iMin = FloatToInt(min * precision);
    int iMax = FloatToInt(max * precision);
    int iRandom = Random(iMax - iMin) + iMin;

    return IntToFloat(iRandom) / precision;
}

int GetIsCommonerAreaActive(object area, string commonerTag)
{
    return _GetLocalInt(area, "CommonerAreaActive_" + commonerTag);
}

void SetCommonerAreaActive(object area, string commonerTag, int value)
{
    _SetLocalInt(area, "CommonerAreaActive_" + commonerTag, value);
}

int GetNumberOfCommonersWaitingToSpawn(object area, string commonerTag)
{
    return _GetLocalInt(area, "CommonersWaitingToSpawn_" + commonerTag);
}

void SetNumberOfCommonersWaitingToSpawn(object area, string commonerTag, int value)
{
    if (value < 0)
        value = 0;
    _SetLocalInt(area, "CommonersWaitingToSpawn_" + commonerTag, value);
}

int GetPlayerInArea(object area)
{
    return CountObjectList(area, AREA_ROSTER);
}

void DestroyCrowd(object area, string tag)
{
    location areaOrigin = Location(area, Vector(), 0.0f);

    int i = 1;
    object creature = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, areaOrigin, i);
    while (creature != OBJECT_INVALID)
    {
        if (GetTag(creature) == tag)
        {
            SetPlotFlag(creature, FALSE);
            DestroyObject(creature);
        }

        i++;
        creature = GetNearestObjectToLocation(OBJECT_TYPE_CREATURE, areaOrigin, i);
    }
}

void CleanCommonerArea(object area, struct CommonerSettings settings)
{
    DestroyCrowd(area, settings.CommonerTag);

    SetNumberOfCommonersWaitingToSpawn(area, settings.CommonerTag, 0);
    SetCommonerAreaActive(area, settings.CommonerTag, FALSE);
}

int GetNumberOfObjectsInAreaByTag(object objectInArea, string tag)
{
    int i = 1;
    object obj = GetNearestObjectByTag(tag, objectInArea, i);
    while (obj != OBJECT_INVALID)
    {
        i++;
        obj = GetNearestObjectByTag(tag, objectInArea, i);
    }

    return i - 1;
}

int GetMaxNumberOfCommoners(object area, struct CommonerSettings settings)
{
    int max = settings.NumberOfCommonersDuringDay;
    if (GetIsNight())
        max = settings.NumberOfCommonersDuringNight;

    int weather = GetWeather(area);
    if (weather == WEATHER_RAIN || weather == WEATHER_SNOW)
        max = min(max, settings.NumberOfCommonersDuringRain);

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
        return;

    _SetLocalObject(commoner, "CommonerTargetWaypoint", targetWP);
    AssignCommand(commoner, ActionForceMoveToObject(targetWP, FALSE, 1.0f, settings.MaxWalkTime));
    AssignCommand(commoner, ActionDoCommand(DestroyObject(commoner)));
}

void SpawnCommoner(object area, struct CommonerSettings settings)
{
    // Do not spawn a commoner if no PC is in the area.
    if (!GetPlayerInArea(area))
        return;

    object pc = GetListObject(area, 0, AREA_ROSTER);

    // Check if a commoner should spawn, and if so, update the number of commoners waiting to spawn.
    int numberOfCommonersWaitingToSpawn = GetNumberOfCommonersWaitingToSpawn(area, settings.CommonerTag);
    SetNumberOfCommonersWaitingToSpawn(area, settings.CommonerTag, numberOfCommonersWaitingToSpawn - 1);

    // Find out where to spawn the commoner.
    int numberOfWaypoints = GetNumberOfObjectsInAreaByTag(pc, settings.WaypointTag);
    object originWP = GetNearestObjectByTag(settings.WaypointTag, pc, Random(numberOfWaypoints) + 1);

    if (originWP == OBJECT_INVALID)
        return;

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
            AssignCommand(commoner, ActionEquipItem(clothing, INVENTORY_SLOT_CHEST));
    }

    if (!settings.StationaryCommoners)
        MakeCommonerWalk(commoner, originWP, numberOfWaypoints, settings);

    if (settings.CommonerDialog != "")
        _SetLocalString(commoner, CROWD_CONVERSATION, settings.CommonerDialog);
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
    if (!GetPlayerInArea(area))
    {
        if (GetIsCommonerAreaActive(area, settings.CommonerTag))
            CleanCommonerArea(area, settings);

        return;
    }

    SetCommonerAreaActive(area, settings.CommonerTag, TRUE);
    settings = SanitizeSettings(settings);

    object pc = GetListObject(area, 0, AREA_ROSTER);

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
    object destination = _GetLocalObject(commoner, "CommonerTargetWaypoint");
    if (destination == OBJECT_INVALID)
        return;

    AssignCommand(commoner, ActionForceMoveToObject(destination));
    AssignCommand(commoner, ActionDoCommand(DestroyObject(commoner)));
}
