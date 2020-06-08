// -----------------------------------------------------------------------------
//    File: crowd_l_plugin.nss
//  System: Simulated Population (library)
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
#include "crowd_i_events"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------
void OnLibraryLoad()
{
    object oPlugin = GetPlugin("pw");

    // ----- Module Events -----
    RegisterEventScripts(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "crowd_OnModuleLoad");

    // ----- Area Events -----
    RegisterEventScripts(oPlugin, AREA_EVENT_ON_ENTER, "crowd_OnAreaEnter");
    RegisterEventScripts(oPlugin, AREA_EVENT_ON_EXIT, "crowd_OnAreaExit");

    // ----- Timer Events -----
    RegisterEventScripts(oPlugin, CROWD_EVENT_ON_TIMER_EXPIRED, "crowd_OnTimerExpired", 4.0);

    // ----- Module Events -----
    RegisterLibraryScript("crowd_OnModuleLoad", 1);

    // ----- Area Events -----
    RegisterLibraryScript("crowd_OnAreaEnter", 2);
    RegisterLibraryScript("crowd_onAreaExit",  3);

    // ----- Timer Events -----
    RegisterLibraryScript("crowd_OnTimerExpired", 4);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        // ----- Module Events -----
        case 1: crowd_OnModuleLoad(); break;

        // ----- Area Events -----
        case 2: crowd_OnAreaEnter(); break;
        case 3: crowd_OnAreaExit();  break;

        // ----- Timer Events -----
        case 4: crowd_OnTimerExpired(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
