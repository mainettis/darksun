// -----------------------------------------------------------------------------
//    File: dmfi_l_plugin.nss
//  System: DMFI (library)
//     URL: 
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// Description:
//  Library functions for PW Subsystem
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

#include "dmfi_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    //Need to check for pw plugin and this is a sub-plugin
    if (!GetIfPluginExists("dmfi"))
    {
        object oPlugin = GetPlugin("dmfi", TRUE);
        SetName(oPlugin, "[Plugin] DM Friendly Initiative :: Wands & Widgets 1.09");
        SetDescription(oPlugin,
            "This plugin implements the DMFI W&W 1.09 System.");

        // ----- Module Events -----
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "dmfi_OnModuleLoad");
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "dmfi_OnClientEnter");
        RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_CHAT,  "dmfi_OnPlayerChat");
    }

    // ----- Module Events -----
    RegisterLibraryScript("dmfi_OnModuleLoad", 1);
    RegisterLibraryScript("dmfi_OnClientEnter", 2);
    RegisterLibraryScript("dmfi_OnPlayerChat",  3);
    RegisterLibraryScript("dmfi_c_buff", 4);
    RegisterLibraryScript("dmfi_c_heal", 5);
    RegisterLibraryScript("dmfi_c_damage", 6);
    RegisterLibraryScript("dmfi_c_playanimation", 7);
    RegisterLibraryScript("dmfi_c_setdescription", 8);
    RegisterLibraryScript("dmfi_c_setname", 9);
    RegisterLibraryScript("dmfi_c_flee", 10);
    RegisterLibraryScript("dmfi_c_disappear", 11);
    RegisterLibraryScript("dmfi_c_destroyobject", 12);
    RegisterLibraryScript("dmfi_c_createobject", 13);
    RegisterLibraryScript("dmfi_c_cleareffects", 14);
    RegisterLibraryScript("dmfi_c_follow", 15);
    RegisterLibraryScript("dmfi_c_freeze", 16);
    RegisterLibraryScript("dmfi_c_mute", 17);
    RegisterLibraryScript("dmfi_c_dmtool", 18);
    RegisterLibraryScript("dmfi_c_set", 19);
    RegisterLibraryScript("dmfi_c_get", 20);
    RegisterLibraryScript("dmfi_c_vfx", 21);
    RegisterLibraryScript("dmfi_c_faction", 22);
    RegisterLibraryScript("dmfi_c_target", 23);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1: dmfi_OnModuleLoad(); break;
        case 2: dmfi_OnClientEnter(); break;
        case 3: dmfi_OnPlayerChat();  break;
        case 4: dmfi_c_buff(); break;
        case 5: dmfi_c_heal(); break;
        case 6: dmfi_c_damage(); break;
        case 7: dmfi_c_playanimation(); break;
        case 8: dmfi_c_setdescription(); break;
        case 9: dmfi_c_setname(); break;
        case 10: dmfi_c_flee(); break;
        case 11: dmfi_c_disappear(); break;
        case 12: dmfi_c_destroyobject(); break;
        case 13: dmfi_c_createobject(); break;
        case 14: dmfi_c_cleareffects(); break;
        case 15: dmfi_c_follow(); break;
        case 16: dmfi_c_freeze(); break;
        case 17: dmfi_c_mute(); break;
        case 18: dmfi_c_dmtool(); break;
        case 19: dmfi_c_set(); break;
        case 20: dmfi_c_get(); break;
        case 21: dmfi_c_vfx(); break;
        case 22: dmfi_c_faction(); break;
        case 23: dmfi_c_target(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
