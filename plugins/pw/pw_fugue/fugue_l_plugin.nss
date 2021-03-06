// -----------------------------------------------------------------------------
//    File: fugue_l_plugin.nss
//  System: Fugue Death and Resurrection (library)
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
// This script is a copy of Edward Becks HCR2 script h2_core_i modified and renamed
//  to work under Michael Sinclair's (Squatting Monk) core-framework system and
//  for use in the Dark Sun Persistent World.  Some of the HCR2 pw functions
//  have been removed because they are duplicates from the core-framework or no
//  no longer applicable to the pw system within the core-framework.
// -----------------------------------------------------------------------------
// Revisions:
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "fugue_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----      
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "fugue_OnClientEnter", 4.0);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH, "fugue_OnPlayerDeath", EVENT_PRIORITY_ONLY);
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_PLAYER_DYING, "fugue_OnPlayerDying", 4.0);

    // ----- Module Events -----
    RegisterLibraryScript("fugue_OnClientEnter", 1);
    RegisterLibraryScript("fugue_OnPlayerDeath", 2);
    RegisterLibraryScript("fugue_OnPlayerDying", 3);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1:  fugue_OnClientEnter(); break;
        case 2:  fugue_OnPlayerDeath(); break;
        case 3:  fugue_OnPlayerDying(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
