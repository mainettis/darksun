// -----------------------------------------------------------------------------
//    File: util_i_debug.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds utility functions for generating debug messages.
// -----------------------------------------------------------------------------

#include "util_i_color"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// VarNames
const string REPORT_COLOR = "DEBUG_COLOR";
const string REPORT_LEVEL = "DEBUG_LEVEL";
const string REPORT_LOG   = "DEBUG_LOG";

// Debug levels
const int DEBUG_LEVEL_CRITICAL = 0;
const int DEBUG_LEVEL_ERROR    = 1;
const int DEBUG_LEVEL_WARNING  = 2;
const int DEBUG_LEVEL_NOTICE   = 3;

// Debug logging
const int DEBUG_LOG_NONE = 0x0;
const int DEBUG_LOG_FILE = 0x1;
const int DEBUG_LOG_DM   = 0x2;
const int DEBUG_LOG_PC   = 0x4;
const int DEBUG_LOG_ALL  = 0xf;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// So here's the idea, need a messaging and communications systems to allow for the following:
// Send a message to a specific, multiple (i.e. area, event, etc.), all PCs
//  we can use the server pc roster for this.  it's stored on GetModule() as an
//  object varlist called PLAYER_ROSTER.  DMs are the same on DM_ROSTER.
//  Each area carries an AREA_ROSTER. It's not set on MODULE.  This is done by the
//  framework, so we can't change it. So we have to be careful to use SetLocal* vs _SetLocal*
//  If we have regions, we'll have a REGION_ROSTER,
//  but that's not implemented.  So how do we create the primary comms functions, and then
//  the wrappers to address them.

// PC - specific pc?
// AreaPCs
//  SendMessage(group, message)  group -> reference to the object list?
//  SendMessage (object, objectlist, message)?
//  if object == pc, and objectlist == "" send to pc?



string GetMessageColor(int nType)
{
    int nColor;

    switch (nType)
    {
        case MESSAGE_EVENT:  nColor = COLOR_TURQUOISE; break;
        case MESSAGE_SERVER: nColor = COLOR_PURPLE;    break;
        default:                                       break;
    }

    return HexToColor(nColor);
}

void SendMessage(object oDestination, string sObjectList, int nType, string sMessage)
{
    if (!GetIsObjectValid(oDestination))
        sError = "message destination object invalid.";
    else if (_GetIsPC(oDestination) && sObjectList != "")
        sError = "message intended for a PC, but objectlist passed.";
    else if (sMessage == "")
        sError = "message not passed.";

    if (sError != "")
    {
        Debug("Message failed: " + sError);
        return;
    }

    string sPrefix;

    switch (nType)
    {
        case MESSAGE_EVENT:  sPrefix = "[EVENT] "; break;
        case MESSAGE_SERVER: sPrefix = "[SERVER] "; break;
    }
    
    sMessage = ColorString(sPrefix + sMessage, GetMessageColor(nType));

    //Do we have a message to a single PC?
    if ((_GetIsPC(oDestination) || _GetIsDM(oDestination)) && sObjectList == "")
    {
        SendMessageToPC(oPC, sMessage);
        return;
    }

    if (sObjectList != "")
    {
        int i, nCount = CountObjectList(oDestination, sObjectList);

        for (i = 1; i < nCount; i++)
        {
            object oPC = GetListObject(oDestination, sObjectList, i);
            SendMessageToPC(oPC, sMessage);
        }
    }
}

Log(string sMessage)
{
    WriteTimestampedLogEntry(sMessage);
}

void MessageAllPC(string sMessage)
{
    if (sMessage != "")
        SendMessage(GetModule(), PLAYER_ROSTER, MESSAGE_SERVER, sMessage);
}

void MessageAllDM(string sMessage)
{
    if (sMessage != "")
        SendMessage(GetModule(), DM_ROSTER, MESSAGE_SERVER, sMessage);
}

void MessageAll(string sMessage)
{
    AllPC(sMessage);
    AllDM(sMessage);
}

void MessagePC(object oPC, string sMessage, int nType)
{
    if (GetIsObjectValid(oPC) && sMessage != "")
    {
        SendMessage(oPC, "", nType, sMessage)
    }
}


