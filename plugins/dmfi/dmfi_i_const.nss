// -----------------------------------------------------------------------------
//    File: dmfi_i_const.nss
//  System: DMFI (constants)
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

//TODO build these two wands.
//The following values are used with the chat command system.  The items in
//  DMFI_COMMAND_ITEMS_CSV are the "built-in" chat commands.  Other commands
//  can be added by the builder as long as the commands are unique module-wide,
//  including these commands.  You can see which commands are currently loaded
//  by either using the DM conversation or looking at the individual items.
//TODO tutorial on creating new [.] commands

// --- Command Item System Values
const string DMFI_COMMAND_ITEMS_PREFIX = "dmfi_";
const string DMFI_COMMAND_ITEMS_LOADED_CSV = "DMFI_COMMAND_ITEMS_LOADED_CSV";
const string DMFI_COMMAND_ITEMS_OBJECT_LIST = "DMFI_COMMAND_ITEMS_OBJECT_LIST";
const string DMFI_COMMAND_ITEMS_INITIALIZED = "DMFI_COMMAND_ITEMS_INITIALIZED";
string       DMFI_COMMAND_ITEMS_CSV = "afflict,dicebag,pc_dicebag,pc_follow,pc_emote,server,encounter,faction,emote,fx," +
                                      "music,sound,voice,xp,500xp,en_ditto,mute,peace,voiceWidget,remove,dmw,target," +
                                      "buff,dmbook,playerbook,jail_widget,naming";

// --- Command Item Variables
const string DMFI_COMMAND_ITEM_NAME = "DMFI_COMMAND_ITEM_NAME";
const string DMFI_COMMAND_ITEM_COMMANDS = "DMFI_COMMAND_ITEM_COMMANDS";
const string DMFI_COMMAND_ITEM_SCRIPT = "DMFI_COMMAND_ITEM_SCRIPT";
const string DMFI_COMMAND_ITEM_ACTIVE = "DMFI_COMMAND_ITEM_ACTIVE";

const string DMFI_COMMAND_VOICE_COMMANDS = ":,;";  //Plus ,
const string DMFI_COMMAND_ACTION_COMMANDS = "[,*,.";
const string DMFI_COMMAND_SET_CHARACTERS = "!,@,#,$,%,^";
const string DMFI_COMMAND_SET = "DMFI_COMMAND_SET";
const string DMFI_COMMAND_EMOTE = "*";

// --- Language Item System Values
//The following values are used with the language system.  The items in
//  DMFI_LANGUAGE_ITEMS_CSV are the "built-in" languages.  Other languages
//  can be added by teh builder as long as the language names are unique
//  module-wide.  You can see which languages are currently loaded by either
//  using the DM conversation or looking at the individual items.

const string DMFI_LANGUAGE_ITEMS_PREFIX = "dmfi_l_";
const string DMFI_LANGUAGE_ITEMS_LOADED_CSV = "DMFI_LANGUAGE_ITEMS_LOADED_CSV";
const string DMFI_LANGUAGE_ITEMS_OBJECT_LIST = "DMFI_LANGUAGE_ITEMS_OBJECT_LIST";
const string DMFI_LANGUAGE_ITEMS_INITIALIZED = "DMFI_LANGUAGE_ITEMS_INITIALIZED";
string       DMFI_LANGUAGE_ITEMS_CSV = "common,drow,abyssal,celestial,cant,infernal,draconic,goblin,dwarf,elven," +
                                       "gnome,halfling,orc,animal,sylvan,rashemi,mulhorandi,leetspeak";  

// --- Language Item Variables
const string DMFI_LANGUAGE_ITEM_NAME = "DMFI_LANGUAGE_ITEM_NAME";
const string DMIF_LANGUAGE_ITEM_ABBREVIATION = "DMIF_LANGUAGE_ITEM_ABBREVIATION";
const string DMFI_LANGUAGE_ITEM_ALPHABET = "DMFI_LANGUAGE_ITEM_ALPHABET";
const string DMFI_LANGUAGE_ITEM_TRANSLATION_MODE = "DMFI_LANGUAGE_ITEM_TRANSLATION_MODE";
const string DMFI_LANGUAGE_ITEM_ACTIVE = "DMFI_LANGUAGE_ITEM_ACTIVE";

// --- Language Translation Modes
const int DMFI_LANGUAGE_TRANSLATION_MODE_LETTER = 0;
const int DMFI_LANGUAGE_TRANSLATION_MODE_WORD = 1;
const int DMFI_LANGUAGE_TRANSLATION_MODE_REPEAT = 2;

// This variable determines the primary language to translate from
//TODO move to config file?
const string DMFI_LANGUAGE_ITEM_COMMON = "common";

// --- Module Variables
const string DMFI = "DMFI Data";
object DMFI_DATA = GetDatapoint(DMFI);
const string DMFI_INITIALIZED = "DMFI_INITIALIZED";
const string DMFI_EMOTES_MUTED = "DMFI_EMOTES_MUTED";
int DMFI_MODULE_EMOTES_MUTED = _GetLocalInt(DMFI, DMFI_EMOTES_MUTED);

// --- Player Variables
const string DMFI_USER_SETTINGS = "DMFI_USER_SETTINGS";
const string DMFI_COMMAND_HOOKS = "DMFI_COMMAND_HOOKS";
const string DMFI_LANGUAGE_KNOWN = "DMFI_LANGUAGE_KNOWN";
const string DMFI_LANGUAGE_CURRENT = "DMFI_LANGUAGE_CURRENT";
const string DMFI_TARGET_VOICE = "DMFI_TARGET_VOICE";
const string DMFI_TARGET_COMMAND = "DMFI_TARGET_COMMAND";






//TODO probably for a config file?
// TODO build basic wands
const string DMFI_DM_ITEM_INVENTORY = "targetwand,voicewand,dmbook,playerbook";
const string DMFI_PC_ITEM_INVENTORY = "playerbook,targetwand,voicewand";


/*string DMFI_DEFAULT_DM_SETTINGS = "ALIGNMENT_SHIFT:5," +
                                        "BEAM_DURATION:5.0," +
                                        "BUFF_LEVEL:LOW," +
                                        "BUFF_PARTY:FALSE," +
                                        "DICEBAG:PRIVATE," +
                                        "EFFECT_DELAY:1.0,";
                                        "EFFECT_DURATION:60.0," +
                                        "EMOTES_MUTED:FALSE," +
                                        "REPUTATION:5.0," +
                                        "SAFE_FACTIONS:0," +
                                        "SAVE_AMOUNT:5.0," +
                                        "SOUND_DELAY:0.2," +
                                        "STUN_DURATION:1000.0," +
                                        "DICEBAG_ANIMATION:TRUE";
string DMFI_DEFAULT_PC_SETTINGS = "EMOTES_MUTED:FALSE," +
                                        "DICEBAG_ANIMATION:TRUE," +
                                        "DICEBAG:PRIVATE";*/

// ----- Settings Constants -----
const string DMFI_SETTING_ALIGNMENT_SHIFT = "ALIGNMENT_SHIFT";
const string DMFI_SETTING_BEAM_DURATION =   "BEAM_DURATION";
const string DMFI_SETTING_BUFF_LEVEL =      "BUFF_LEVEL";
const string DMFI_SETTING_BUFF_PARTY =      "BUFF_PARTY";
const string DMFI_SETTING_DICEBAG =         "DICEBAG";
const string DMFI_SETTING_EFFECT_DELAY =    "EFFECT_DELAY";
const string DMFI_SETTING_EFFECT_DURATION = "EFFECT_DURATION";
const string DMFI_SETTING_EMOTES_MUTED =    "EMOTES_MUTED";
const string DMFI_SETTING_REPUTATION =      "REPUTATION";
const string DMFI_SETTING_SAFE_FACTIONS =   "SAFE_FACTIONS";
const string DMFI_SETTING_SAVE_AMOUNT =     "SAVE_AMOUNT";
const string DMFI_SETTING_SOUND_DELAY =     "SOUND_DELAY";
const string DMFI_SETTING_STUN_DURATION =   "STUN_DURATION";
const string DMFI_SETTING_DICEBAG_ANIMATION =       "DICEBAG_ANIMATION";

// ----- Variable Names -----

const int DMFI_HOOK_HANDLE_SPLIT = 10000;

const string DMFI_CHATHOOK_PREVIOUS_HANDLE = "DMFI_CHATHOOK_PREVIOUS_HANDLE";
const string DMFI_CHATHOOK_HANDLE = "DMFI_CHATHOOK_HANDLE";
const string DMFI_CHATHOOK_SCRIPT = "DMFI_CHATHOOK_SCRIPT";
const string DMFI_CHATHOOK_RUNNER = "DMFI_CHATHOOK_RUNNER";
const string DMFI_CHATHOOK_CHANNELS = "DMFI_CHATHOOK_CHANNELS";
const string DMFI_CHATHOOK_LISTENALL = "DMFI_CHATHOOK_LISTENALL";
const string DMFI_CHATHOOK_SPEAKER = "DMFI_CHATHOOK_SPEAKER";
const string DMFI_CHATHOOK_AUTOREMOVE = "DMFI_CHATHOOK_AUTOREMOVE";

const string DMFI_LISTENER_HANDLE = "DMFI_LISTENER_HANDLE";
const string DMFI_LISTENER_TYPE = "DMFI_LISTENER_TYPE";
const string DMFI_LISTENER_CREATURE = "DMFI_LISTENER_CREATURE";
const string DMFI_LISTENER_LOCATION = "DMFI_LISTENER_LOCATION";
const string DMFI_LISTENER_CHANNELS = "DMFI_LISTENER_CHANNELS";
const string DMFI_LISTENER_OWNER = "DMFI_LISTENER_OWNER";
const string DMFI_LISTENER_RANGE = "DMFI_LISTENER_RANGE";
const string DMFI_LISTENER_BROADCAST = "DMFI_LISTENER_BROADCAST";

const int DMFI_LISTENER_RANGE_EARSHOT = 0;
const int DMFI_LISTENER_RANGE_AREA = 1;
const int DMFI_LISTENER_RANGE_REGION = 2;
const int DMFI_LISTENER_RANGE_MODULE = 3;


                           
const string DMFI_COMMAND_ARGUMENTS = "DMFI_COMMAND_ARGUMENTS";

string DMFI_SKILLS;


struct DMFI_CHATHOOK
{
    int nHandle;
    int nChannels;
    int nListenAll;
    int nAutoRemove;
    string sScript;
    object oScriptRunner;
    object oSpeaker;
};

struct DMFI_LISTENER_HOOK
{
    int nHandle;
    int nType;
    int nChannels;
    int bParty;
    int bBroadcast;
    object oCreature;
    object oOwner;
    location lLocation;
};

struct DMFI_LANGUAGE_ITEM
{
    int nMode;
    int nActive;
    string sName;
    string sAbbreviation;
    string sAlphabet;
};

struct DMFI_COMMAND_ITEM
{
    int nActive;
    string sName;
    string sCommands;
    string sScript;
};

struct DMFI_COMMAND_VARIABLES
{
    object oSpeaker;
    object oTarget;
    string sArguments;
    string sModifiedMessage;
};
