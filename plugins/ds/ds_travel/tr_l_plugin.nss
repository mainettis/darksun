// -----------------------------------------------------------------------------
//    File: tr_l_plugin.nss
//  System: Travel (library)
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

#include "util_i_library"
#include "core_i_framework"
#include "tr_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("ds_tr"))
    {
        object oPlugin = GetPlugin("ds_tr", TRUE);
        SetName(oPlugin, "[Plugin] Travel System");
        SetDescription(oPlugin,
            "This plugin controls the Dark Sun Overland Travel System.");

        // ----- Module Events -----
        RegisterEventScripts(oPlugin, TRAVEL_ENCOUNTER_ON_TIMER_EXPIRE, "tr_CheckForEncounter");
    }

    // ----- Module Events -----
    RegisterLibraryScript("tr_CheckForEncounter", 1);
    RegisterLibraryScript("tr_OnAreaEnter", 2);
    RegisterLibraryScript("tr_OnAreaExit", 3);
    RegisterLibraryScript("tr_EncounterExit", 4);
    RegisterLibraryScript("tr_KillEncounter", 5);
    RegisterLibraryScript("tr_OnEncounterAOEEnter", 6);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:  tr_CheckForEncounter(); break;
        case 2:  tr_OnAreaEnter();       break;
        case 3:  tr_OnAreaExit();        break;
        case 4:  tr_EncounterExit();     break;
        case 5:  tr_KillEncounter();     break;
        case 6:  tr_encounter_OnAOEEnter(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
