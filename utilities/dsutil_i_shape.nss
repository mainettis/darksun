#include "dsutil_i_data"
#include "dsutil_i_math"
#include "util_i_debug"
#include "util_i_csvlists"

//--------------------------------------------------------------------------------
// Internal routine to convert an int to a string that is always 2 characters in
// size. Only works for positive numbers in range 0 - 99
string IntToPaddedString(int iThisInt);
//--------------------------------------------------------------------------------
// Create a single dimensioned pseudo array of vectors, each of which contains
// (0.0, 0.0, 0.0) sBaseName is the user supplied name for the pseudo-array. The
// pseudo-array index runs from 0 to iMaxIndex.
int CreateVArray(object oHere, string sBaseName, int iMaxIndex);
//--------------------------------------------------------------------------------
// FillVArray copies the contents of vFillValue to every element of the pseudo-array
// sBaseName stored on object oHere.
int FillVArray(object oHere, string sBaseName, vector vFillValue);
//--------------------------------------------------------------------------------
// Routine to return the current last index number of pseudo-array sBaseName
// stored on oHere.
//
// ** NOTE **
//
// Unlike the other routines that return an int, this one does not return a Boolean
// value. Instead, because it is supposed to return an actual number, it returns -1
// if an error is detected and a positive number otherwise.
int LastIndex(object oHere, string sBaseName);
//--------------------------------------------------------------------------------
// Enlarges the pseudo array of vectors sBaseName by iElementsToAdd
// If sBaseName does not exist or iElementsToAdd is less than 1, this function
// returns FALSE. In all other cases the routine proceeds as normal and TRUE is
// returned.
int ExtendVArray(object oHere, string sBaseName, int iElementsToAdd);
//--------------------------------------------------------------------------------
// Routine to free up memory by totally removing the pseudo-array specified by
// sBaseName held on object oHere. After a successful run of this routine the
// pseudo-array will no longer exist and attempts to access it will result in
// an error condition.
int DeleteVArray(object oHere, string sBaseName);
//--------------------------------------------------------------------------------
// "Shortens" the number of entries in the pseudo-array. Does this by "forgetting
// any entries after iAfterThis. If an error is encountered FALSE is returned and
// the function terminates early, otherwise processing continues and TRUE is
// returned.
int TruncateVArray(object oHere, string sBaseName, int iAfterThis);
//--------------------------------------------------------------------------------
// Copy the contents of one pseudo-array to another. If pseudo-array sToThis does
// not exist, it will be created. If pseudo-array sToThis is larger than pseudo-array
// sCopyThis, sToThis will be truncated.If pseudo-array sToThis is smaller than
// pseudo-array sCopyThis, it will be extended.
//
// The pseudo-array named sCopyThis must already exist. If it doesn't this routine will
// terminate early and FALSE will be returned. In all other cases the routine proceeds
//as normal and TRUE is returned.
int CopyVArray(object oHere, string sCopyThis, string sToThis);
//--------------------------------------------------------------------------------
// Copies the contents of the pseudo-array sThis and adds them to the end of the
// pseudo-array sOntoThis extending the entries for it as necessary. Note does not
// copy element 0 of sThis. This is deliberate. If an error is encountered FALSE is
// returned and the function terminates early, otherwise processing continues and
// TRUE is returned.
int AppendVArray(object oHere, string sThis, string sOntoThis);
//--------------------------------------------------------------------------------
// Takes the pseudo-array sSplitThis stored on oHere and splits the contents
// between sSplitThis and sNewHalf. This routine tries to split the contents into
// two equal halves if sSplitThis has an even number of vectors stored in it.
// On the other hand if that number is odd the extra vector remains in sSplitThis.
// Standard user errors are checked for.
int SplitVArray(object oHere, string sSplitThis, string sNewHalf);
//--------------------------------------------------------------------------------
// Adds a single vector vThis onto the end of the pseudo-array sOntoThis. If
// sOntoThis does not exist this function will terminate early and return FALSE,
// otherwise processing continues and TRUE is returned.
int AppendVector(object oHere, vector vThis, string sOntoThis);
//--------------------------------------------------------------------------------
// Opens the pseudo-array sOntoThis stored on oHere and copies the contents of the
// last entry in the pseudo-array into a temporary vector. This temporary vector
// is combined with the offset information contained in vThisRelative. A new empty
// vector is created at the end of the pseudo-array and the contents of the
// temporary vector is copied into it.
int AppendVectorRelative(object oHere, vector vThisRelative, string sOntoThis);
//--------------------------------------------------------------------------------
// Inserts the vector vThisVector into the pseudo-array sThis at position
// iRightHere. There are a number of possible errors that are caught by this routine.
// Should an error be encountered this function terminates early and returns FALSE.
// Should no error be encountered processing continues normally and TRUE is returned.
int InsertVector(object oHere, string sThis, vector vThisVector, int iRightHere);
//--------------------------------------------------------------------------------
// Completely removes the vector at position iRightHere in pseudo-array sThis and
// shortens the array by 1. There are a number of possible errors that are caught by
// this routine. Should an error be encountered this function terminates early and
// returns FALSE. Should no error be encountered processing continues normally and
// TRUE is returned.
int DeleteEntry(object oHere, string sThis, int iRightHere);
//--------------------------------------------------------------------------------
// Replaces the vector held in position iRightHere of pseudo-array sThis with the
// vector vThisVector. This is intended to be used instead of the internal
// _SetLocalVector() routine as error checking is performed. Should an error be
// detected UpdateVector() aborts and FALSE is returned, otherwise TRUE is
// returned at the end of the routine.
int UpdateVector(object oHere, string sThis, vector vThisVector, int iRightHere);
//--------------------------------------------------------------------------------
// Returns a copy of the vector held in position iRightHere of pseudo-array sThis.
// This is intended to be used instead of the internal _GetLocalVector() routine as
// error checking is performed. Because this routine actually is supposed to return
// a value, an alternative method (to what is used for the rest of the routines) of
// error indication is used. Should an error be encountered, the internal function
// RetrievalError() is called and a vector containing [5, 0, 5] (e.g. SOS) is
// returned.
vector RetrieveVector(object oHere, string sThis, int iRightHere);
//--------------------------------------------------------------------------------
// This is a private function only called by RetrieveVector() and then only when
// an error is found. What it does is to send an error message in red to the
// chat window of the player which directs them to examine the log file. The same
// message (sans colour) is sent to the log file. Additionally any and all errors
// detected are listed in the log file.
void RetrievalError(object oHere, string sThis, int iRightHere);
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Debugging routine to copy the contents of a pseudo-array to the log file
void DumpShapeToLog(object oHere, string sThis);
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Internal routine to convert an int to a string that is always 2 characters in
// size. Only works for positive numbers in range 0 - 99
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Create a simple pseudo array of vectors
//--------------------------------------------------------------------------------

//DeclareVectorList?

/*
int CreateVArray(object oHere, string sBaseName, int iMaxIndex)
{
    vector vBlank = Vector(0.0, 0.0, 0.0);
    int iIndex;
    int iReturnThis = TRUE;

    if(oHere == OBJECT_INVALID || sBaseName == "")
        iReturnThis = FALSE;
    else
    {
        SetLocalInt(oHere, sBaseName + "Max", iMaxIndex);

        for(iIndex = 0 ; iIndex <= iMaxIndex ; iIndex++)
            _SetLocalVector(oHere, sBaseName + IntToPaddedString(iIndex), vBlank);
    }
    return iReturnThis;
}
*/

//--------------------------------------------------------------------------------
// FillVArray copies the contents of vFillValue to every element of the pseudo-array
// sBaseName stored on object oHere
//--------------------------------------------------------------------------------

//Loop AddListVector?
// Isn't used in the code anywhere
/*
int FillVArray(object oHere, string sBaseName, vector vFillValue)
{
    int iIndex;
    int iMaxIndex = GetLocalInt(oHere, sBaseName + "Max");
    int iReturnThis = TRUE;

    if(oHere == OBJECT_INVALID || sBaseName == "" || iMaxIndex < 1)
        iReturnThis = FALSE;
    else
        for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
            _SetLocalVector(oHere, sBaseName + IntToPaddedString(iIndex), vFillValue);

    return iReturnThis;
}*/


//--------------------------------------------------------------------------------
// Routine to return the current last index number of pseudo-array sBaseName
// stored on oHere
//--------------------------------------------------------------------------------

//CountVectorList - 1?
/*
int LastIndex(object oHere, string sBaseName)
{
    int iReturnThis = TRUE;

    if(oHere == OBJECT_INVALID || sBaseName == "")
        iReturnThis = -1;
    else
        iReturnThis = GetLocalInt(oHere, sBaseName + "Max");
    return iReturnThis;
}*/

//--------------------------------------------------------------------------------
// Append extra empty vectors onto the pseudo-array
//--------------------------------------------------------------------------------

//DeclareVectorList?  No, that'll delete it.  AddListVector

int ExtendVArray(object oHere, string sBaseName, int iElementsToAdd)
{
    vector vBlank = Vector(0.0, 0.0, 0.0);
    int iIndex = GetLocalInt(oHere, sBaseName + "Max");
    int iNewMaxIndex = iIndex + iElementsToAdd;
    int iReturnThis = TRUE;

    if(oHere == OBJECT_INVALID || iIndex < 1 || iElementsToAdd < 1 || sBaseName == "")
        iReturnThis = FALSE;
    else
    {
        SetLocalInt(oHere, sBaseName + "Max", iNewMaxIndex);

        for(iIndex = iIndex + 1 ; iIndex <= iNewMaxIndex ; iIndex++)
            _SetLocalVector(oHere, sBaseName + IntToPaddedString(iIndex), vBlank);
    }
    return iReturnThis;
}

//--------------------------------------------------------------------------------
// Free up memory by totally removing an existing vector pseudo-array
//--------------------------------------------------------------------------------

//DeleteVectorList
/*
int DeleteVArray(object oHere, string sBaseName)
{
    int iIndex;
    int iReturnThis = TRUE;
    int iMaxIndex = GetLocalInt(oHere, sBaseName + "Max");

    if(oHere == OBJECT_INVALID || sBaseName == "" || iMaxIndex < 1)
        iReturnThis = FALSE;
    else
    {
        for(iIndex = iMaxIndex ; iIndex >= 0 ; iIndex--)
            _DeleteLocalVector(oHere, sBaseName + IntToPaddedString(iIndex));

        DeleteLocalInt(oHere, sBaseName + "Max");
    }
    return iReturnThis;
}*/

//--------------------------------------------------------------------------------
// "Lose" vectors from the end of a pseudo-array
//--------------------------------------------------------------------------------

//Loop DeleteListVector moving backward?
//TODO ensure this integrates with center as vector 0.
//TruncateVArray
int TruncateVectorList(object oTarget, string sShapeName, int nIndex)
{
    if (!GetIsObjectValid(oTarget) || sShapeName == "")
        return FALSE;
    
    int i, nCount = CountVectorList(oTarget, sShapeName) - 1;
    
    if (nCount > nIndex || nIndex < 0 || !nCount)
        return FALSE;

    for (i = nCount; i > nIndex, i--)
        DeleteListVector(oTarget, i, sShapeName);

    return TRUE;
}

//--------------------------------------------------------------------------------
// Copy the contents of one pseudo-array to another
//--------------------------------------------------------------------------------
//TODO
//CopyVectorList
int CopyVArray(object oHere, string sCopyThis, string sToThis)
{
    vector vTemp;
    string sIndexNumber;
    int iIndex;
    int iReturnThis = TRUE;
    int iMaxIndex;

    if(oHere == OBJECT_INVALID || sCopyThis == "" || sToThis == "")
        iReturnThis = FALSE;
    else
    {
        iMaxIndex = GetLocalInt(oHere, sCopyThis + "Max");

        if(iMaxIndex < 1)
            iReturnThis = FALSE;
        else
        {
            SetLocalInt(oHere, sToThis + "Max", iMaxIndex);

            for(iIndex = 0 ; iIndex <= iMaxIndex ; iIndex++)
            {
                sIndexNumber = IntToPaddedString(iIndex);

                vTemp = _GetLocalVector(oHere, sCopyThis + sIndexNumber);
                _SetLocalVector(oHere, sToThis + sIndexNumber, vTemp);
            }
        }
    }
    return iReturnThis;
}

//--------------------------------------------------------------------------------
// Combine 2 pseudo-arrays into one by adding one onto the end of another
//--------------------------------------------------------------------------------
//TODO
//Also CopyVectorList
int AppendVArray(object oHere, string sThis, string sOntoThis)
{
    vector vTemp;
    string sIndexNumber1, sIndexNumber2;
    int iIndex1, iIndex2;
    int iMaxIndexOld1;
    int iMaxIndexOld2;
    int iMaxIndexNew;
    int iReturnThis = TRUE;

    if(oHere == OBJECT_INVALID || sThis == "" || sOntoThis == "")
        iReturnThis = FALSE;
    else
    {
        iMaxIndexOld1 = GetLocalInt(oHere, sOntoThis + "Max");
        iMaxIndexOld2 = GetLocalInt(oHere, sThis + "Max");
        iMaxIndexNew = iMaxIndexOld1 + iMaxIndexOld2;

        if(iMaxIndexOld1 < 1 || iMaxIndexOld2 < 1)
            iReturnThis = FALSE;
        else
        {
            SetLocalInt(oHere, sOntoThis + "Max", iMaxIndexNew);

            for(iIndex1 = 1 ; iIndex1 <= iMaxIndexOld2 ; iIndex1++)
            {
                iIndex2 = iMaxIndexOld1 + iIndex1;
                vTemp = _GetLocalVector(oHere, sThis + IntToPaddedString(iIndex1));
                _SetLocalVector(oHere, sOntoThis + IntToPaddedString(iIndex2), vTemp);
            }
        }
    }
    return iReturnThis;
}

//--------------------------------------------------------------------------------
// Takes one pseudo-array and splits it in two
//--------------------------------------------------------------------------------
//TODO
int SplitVArray(object oHere, string sSplitThis, string sNewHalf)
{
    vector vTemp;
    string sIndexNumber, sIndexNumber2;
    int iIndex;
    int iReturnThis = TRUE;
    int iMaxIndex, iMaxIndex2;
    int iHalfStart;

    if(oHere == OBJECT_INVALID || sSplitThis == "" || sNewHalf == "")
        iReturnThis = FALSE;
    else
    {
        iMaxIndex = GetLocalInt(oHere, sSplitThis + "Max");

        if(iMaxIndex < 2)
            iReturnThis = FALSE;
        else
        {
            iHalfStart = iMaxIndex / 2;

            if(iMaxIndex & 1) // Bitwise test for an odd number
                iHalfStart += 2;
            else
                iHalfStart++;

            iMaxIndex2 = 0;

            _SetLocalVector(oHere, sNewHalf + "00", Vector(0.0, 0.0, 0.0));

            for(iIndex = iHalfStart ; iIndex <= iMaxIndex ; iIndex++)
            {
                iMaxIndex2++;

                sIndexNumber = IntToPaddedString(iIndex);
                sIndexNumber2 = IntToPaddedString(iMaxIndex2);

                vTemp = _GetLocalVector(oHere, sSplitThis + sIndexNumber);
                _SetLocalVector(oHere, sNewHalf + sIndexNumber2, vTemp);
            }
            TruncateVArray(oHere, sSplitThis, --iHalfStart);
            SetLocalInt(oHere, sNewHalf + "Max", iMaxIndex2);
        }
    }
    return iReturnThis;
}

//AppendVector removed, it's just an AddListVector
//TODO

//--------------------------------------------------------------------------------
// Extend a pseudo-array by 1 vector. Create a new vector by combining the contents
// of the last entry with an offset vector and storing the result in the new last
// entry.
//--------------------------------------------------------------------------------
//TODO
int AppendVectorRelative(object oHere, vector vThisRelative, string sOntoThis)
{
    int iReturnThis = TRUE;
    int iMaxIndex;
    string sIndexNumber;
    vector vTemp;

    if(oHere == OBJECT_INVALID || sOntoThis == "")
        iReturnThis = FALSE;
    else
    {
        iMaxIndex = GetLocalInt(oHere, sOntoThis + "Max");

        if(iMaxIndex < 1)
            iReturnThis = FALSE;
        else
        {
            vTemp = RetrieveVector(oHere, sOntoThis, iMaxIndex);
            vTemp.x += vThisRelative.x;
            vTemp.y += vThisRelative.y;
            vTemp.z += vThisRelative.z;
            SetLocalInt(oHere, sOntoThis + "Max", ++iMaxIndex);
            _SetLocalVector(oHere, sOntoThis + IntToPaddedString(iMaxIndex), vTemp);
        }
    }
    return iReturnThis;
}

//--------------------------------------------------------------------------------
// Insert one pseudo-array into another at a certain point extending that
// pseudo-array
//--------------------------------------------------------------------------------

//SetListVector?
//TODO, this is a biggie, if we need it for anything.  Takes a lot of cycles to move
//  stuff around in arrays
int InsertVector(object oHere, string sThis, vector vThisVector, int iRightHere)
{
    int iReturnThis = TRUE;
    int iMaxIndex;
    int iIndex;
    string sIndexNumber1;
    string sIndexNumber2;
    vector vTemp;

    if(oHere == OBJECT_INVALID || sThis == "" || iRightHere < 1)
        iReturnThis = FALSE;
    else
    {
        iMaxIndex = GetLocalInt(oHere, sThis + "Max");

        if(iMaxIndex < 2 || iRightHere < 1 || iRightHere > iMaxIndex)
            iReturnThis = FALSE;
        else
        {
            iMaxIndex++;

            for(iIndex = iMaxIndex ; iIndex > iRightHere ; iIndex--) // make room for the insertion
            {
                sIndexNumber1 = IntToPaddedString(iIndex);
                sIndexNumber2 = IntToPaddedString(iIndex - 1);

                vTemp = _GetLocalVector(oHere, sThis + sIndexNumber2);
                _SetLocalVector(oHere, sThis + sIndexNumber1, vTemp);
            }

            sIndexNumber1 = IntToPaddedString(iRightHere);

            _SetLocalVector(oHere, sThis + sIndexNumber1, vThisVector);
            SetLocalInt(oHere, sThis + "Max", iMaxIndex);
        }
    }
    return iReturnThis;
}

//--------------------------------------------------------------------------------
// Remove a single vector from a pseudo-array
//--------------------------------------------------------------------------------

//DeleteListVector
//Removed DeleteEntry, it's just a DeleteListVector with bMaintainOrder = TRUE
//TODO

//Removed UpdateVector, RetrieveVector, added error handling to basic routines.

//--------------------------------------------------------------------------------
// Debugging routine to copy the contents of a pseudo-array to the log file
//--------------------------------------------------------------------------------

//TODO check these and all the for loops for the correct indices
void DumpShapeToLog(object oTarget, string sShapeName)
{
    int i, nCount = CountVectorList(oTarget, sShapeName) - 1;
    string sMessage;

    vector v = GetListVector(oTarget, 0, sShapeName);

    sMessage = "SHAPES :: Vector Array for shape " + sShapeName +
        "\n  Center - (" + FloatToString(v.x) + ", " + FloatToString(v.y) + ", " + FloatToString(v.z)) + ")";

    for (i = 1 ; i <= nCount; i++)
    {
        v = GetListVector(oTarget, i, sShapeName);;
        sMessage += "\n  Vertex " + IntToString(i) + " - (" + FloatToString(v.x) + ", " + FloatToString(v.y) + ", " + FloatToString(v.z)) + ")";
    }

    Debug(sMessage);
}

// inc_shapes
//--------------------------------------------------------------------------------
// Public constants for selecting predefined shapes
//--------------------------------------------------------------------------------

const int SHAPE_TRIANGLE = 0; // 3 sides
const int SHAPE_SQUARE = 1; // 4 sides
const int SHAPE_PENTAGON = 2; // 5 sides
const int SHAPE_HEXAGON = 3; // 6 sides
const int SHAPE_HEPTAGON = 4; // 7 sides
const int SHAPE_OCTOGON = 5; // 8 sides
const int SHAPE_NONAGON = 6; // 9 sides
const int SHAPE_DECAGON = 7; // 10 sides
const int SHAPE_UNDECAGON = 8; // 11 sides
const int SHAPE_DODECAGON = 9; // 12 sides
const int SHAPE_ARROW = 10; // 4 sides
const int SHAPE_PARRALELLOGRAM = 11; // 4 sides
const int SHAPE_DIAMOND = 12; // 4 sides

const int LAST_SHAPE = SHAPE_DIAMOND;

//--------------------------------------------------------------------------------
// Public constants used for specifying inflation type
//--------------------------------------------------------------------------------

/*const int INFLATE_X =   0;
const int INFLATE_Y =   1;
const int INFLATE_Z =   2;
const int INFLATE_XY =  3;
const int INFLATE_XZ =  4;
const int INFLATE_YZ =  5;
const int INFLATE_XYZ = 6;*/

const int INFLATE_X = 0x01;
const int INFLATE_Y = 0x02;
const int INFLATE_Z = 0x04;

vector ERROR_VECTOR = Vector (0.5f, 0.5f, 0.5f);
vector BLANK_VECTOR = Vector (0.0f, 0.0f, 0.0f);

const string SHAPE_DRAWN = "SHAPE_DRAWN";

//--------------------------------------------------------------------------------
// Public constants for updating coordinates
//--------------------------------------------------------------------------------

const int UPDATE_X =   0;
const int UPDATE_Y =   1;
const int UPDATE_Z =   2;
const int UPDATE_XY =  3;
const int UPDATE_XZ =  4;
const int UPDATE_YZ =  5;

//--------------------------------------------------------------------------------
// Public constants used for rotating shapes
//--------------------------------------------------------------------------------

const int ROTATION_AXIS_X = 0;
const int ROTATION_AXIS_Y = 1;
const int ROTATION_AXIS_Z = 2;

const int ROTATION_AXIS_XY =  3;
const int ROTATION_AXIS_YX =  4;
const int ROTATION_AXIS_XZ =  5;
const int ROTATION_AXIS_ZX =  6;
const int ROTATION_AXIS_YZ =  7;
const int ROTATION_AXIS_ZY =  8;

const int ROTATION_AXIS_XYZ = 9;
const int ROTATION_AXIS_XZY = 10;
const int ROTATION_AXIS_YZX = 11;
const int ROTATION_AXIS_YXZ = 12;
const int ROTATION_AXIS_ZXY = 13;
const int ROTATION_AXIS_ZYX = 14;

//--------------------------------------------------------------------------------
// Public constants used for quickly rotating shapes at special angles
//--------------------------------------------------------------------------------

const int FLIP_ANGLE_090 = 0;
const int FLIP_ANGLE_180 = 1;
const int FLIP_ANGLE_270 = 2;

//--------------------------------------------------------------------------------
// The first group of four routines are all about managing the centre of our shapes.
// This is important as the centres of our shapes is used to determine where our
// shapes are positioned and is used for manipulating them. Failure to maintain the
// centre can result in unexpected results.
//--------------------------------------------------------------------------------

// GetLocalShapeCentre does what is says on the tin. It returns a vector that is a
// copy of the contents of the vector that holds the coordinates of the centre of
// shape sShapeName stored on object oHere. If an error is detected
// GetLocalShapeCentreError is called and this routine exits prematurely.
vector GetLocalShapeCentre(object oHere, string sShapeName);
//--------------------------------------------------------------------------------
// GetLocalShapeCentreError is a private function only called by GetLocalShapeCentre()
// and then only  when an error is found. What it does is to send an error message
// in red to the chat window of the player which directs them to examine the log file.
// The same message (sans colour) is sent to the log file. Additionally any and all
// errors detected are listed in the log file.
void GetLocalShapeCentreError(object oHere, string sShapeName);
//--------------------------------------------------------------------------------
// SetLocalShapeCentre copies the contents of the vector vNewCentre as the new
// coordinates of the centre of shape sShapeName held on object oHere. If any errors
// are detected this routine exits prematurely and returns FALSE otherwise TRUE is
// returned.
int SetLocalShapeCentre(object oHere, string sShapeName, vector vNewCentre);
//--------------------------------------------------------------------------------
// ReCentreShape re-calculates the centre the shape sThis held on the object oHere.
// If any errors are detected this routine exits prematurely and returns FALSE
// otherwise TRUE is returned.
//
// This is mainly intended as an internal routine but should you either create a
// new shape that is not part of this library or manipulate a shape using routines
// external to this library it is essential that you call ReCentreShape afterwards.
int ReCentreShape(object oHere, string sThis);

//--------------------------------------------------------------------------------
// The next 2 routines are intended to speed up updating coordinates in one or more
// vectors held in shape sShapeName on object oHere (one update per function).
// If any errors are detected these routines will exit prematurely and FALSE is
// returned otherwise TRUE is returned. It is advised that you use the appropriate
// predefined constants for iThisElement.
//--------------------------------------------------------------------------------

// UpdateSingleElement updates a single element/coordinate (X, Y or Z) of a single
// vector held in shape sShapeName on object oHere with the value fThisValue. The
// element/coordinate that is to be updated is determined by iThisElement. If any
// errors are detected this routine exits prematurely and returns FALSE otherwise
// TRUE is returned.
int UpdateSingleElement(object oHere, string sShapeName, float fThisValue, int iThisElement = UPDATE_X);
//--------------------------------------------------------------------------------
// UpdateTwoElements updates two elements/coordinates (XY, XZ or YZ) of a single
// vector held in shape sShapeName on object oHere with the values fThisValue1
// and fThisValue2. The elements/coordinates that are to be updated are
// determined by iThisElement. If any errors are detected this routine exits
// prematurely and returns FALSE otherwise TRUE is returned.
int UpdateTwoElements(object oHere, string sShapeName, float fThisValue1, float fThisValue2, int iThisElement = UPDATE_XY);
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// The next routine creates a new shape and populates it with the coordinates for
// that shape. These coordinates have been pre-calculated and stored in a custom
// 2da file.
//--------------------------------------------------------------------------------

// CreateUnitShape creates a new shape in sShapeName stored on object oHere. The
// shape to be created is determined by iShape. The shape is populated from
// pre-calculated data stored in the custom 2da file "SHAPES2D.2DA". There are
// currently 13 shapes available. 10 regular polygons and 3 irregular ones.
//
// All of these shapes are 2d objects transported to the 3d world of NwN. They are
// all centred at the origin (if you didn't read the manual that's at 0, 0, 0).
// The reason that they are called unit shapes is that they are based on a
// circle with a radius of 1. This means that they are small with dimensions that
// do not exceed 2 in either width, breadth or height. They are not meant to be
// used as is but rather manipulated in some way and then moved to their display
// position. If any errors are detected this routine exits prematurely and returns
// FALSE otherwise TRUE is returned.
int CreateUnitShape(object oHere, string sShapeName, int iShape = SHAPE_TRIANGLE);
//--------------------------------------------------------------------------------
// This little routine uses trigonometry to calculate the fMultiplier to pass to
// Inflation() in order to enlarge a regular polygon so that each of its sides are
// a given size. fSideSize is the desired size for each side, while iNumberOfSides
// is the number of sides the polygon has.
float SideFactor(float fSideSize, int iNumberOfSides);
//--------------------------------------------------------------------------------
// Wrapper function to free up memory by totally removing the pseudo-array
// specified by sShapeName held on object oHere. After a successful run of this
// routine the pseudo-array will no longer exist and attempts to access it will
// result in an error condition. Uses DeleteVArray() from inc_varrays.
int DeleteShape(object oHere, string sShapeName);
//--------------------------------------------------------------------------------
// Takes the pseudo-array sSplitThis stored on oHere and splits the contents
// between sSplitThis and sNewShapeHalf. This routine tries to split the contents
// into two equal halves if sSplitThis has an even number of vectors stored in it.
// On the other hand if that number is odd the extra vector remains in sSplitThis.
// It then recentres both shapes. Standard user errors are checked for.
int SplitShape(object oHere, string sSplitThis, string sNewShapeHalf);
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// The next three routines are meant to be used after a shape has been created
// using CreateUnitShape and possibly had scaling and/or rotational transformations
// applied to it. Their purpose is to make the shape fully 3D. Such 3D shapes are
// still centred at 0, 0, 0 with no dimension having an absolute value greater
// than 1. In other words these routines are meant to be used on unit shapes and
// produce shapes that are themselves unit shapes.
//--------------------------------------------------------------------------------

// Extrude3DShape turns a 2D shape into a 3D one in a manner similar to an extrusion
// machine. For example a triangle into a wedge or a square into a cube. Repositions
// the resultant shape so that it is still positioned at 0, 0, 0. If any errors are
// detected this routine exits prematurely and returns FALSE otherwise TRUE is
// returned.
int Extrude3DShape(object oHere, string sThis);
//--------------------------------------------------------------------------------
// Make2DShapePyramidal adds a single vector so that the shape is one with a flat
// base but that tapers to a centrally positioned point. The whole shape is
// repositioned so that its centre is still at 0, 0, 0. If any errors are detected
// this routine exits prematurely and returns FALSE otherwise TRUE is returned.
int Make2DShapePyramidal(object oHere, string sThis);
//--------------------------------------------------------------------------------
// Make2DShapeDoublePyramidal is similar to the previous routine but in this case
// two vectors are added, one above and one below the initial shape. This gives a
// shape that tapers outwards from the base until halfway up when it tapers inwards
// to a point. If any errors are detected this routine exits prematurely and
// returns FALSE otherwise TRUE is returned.
int Make2DShapeDoublePyramidal(object oHere, string sThis);
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// The final section of this library is concerned with performing manipulations on
// the shapes that we have created. In computer graphics (and geometry I believe)
// is known as performing transformations. There are 4 basic transformations that
// can be performed - moving the whole shape (aka translation), scaling, rotation
// and shearing. I have not included shearing in this library as I don't believe
// there is much if any call for it in relation to what I have tried to create
// here.
//
// One thing to note when performing a series of transformations one after the
// other is that the order in which they are performed is important. Different
// orders can very easily produce different results. Also all of the routines
// in this section that return an int are boolean. That is if any errors are
// detected these routines will exit prematurely and return FALSE otherwise TRUE
// is returned.
//
// The first two routines are concerned with moving a shape (aka translation). The
// one after that deals with scaling. The remaining routines either deal directly
// with or are directly related with rotation.
//--------------------------------------------------------------------------------

// Moves shape sShapeName stored on oHere by the amounts specified by fByX, fByY
// and fByZ. This also updates the vector that specifies the centre of the shape.
int MoveRelative(object oHere, string sShapeName, float fByX, float fByY, float fByZ);
//--------------------------------------------------------------------------------
// Moves shape sShapeName stored on oHere so that it is centred at fToX, fToY and
// fToZ. Obviously updates the centre of the shape.
int MoveAbsolute(object oHere, string sShapeName, float fToX, float fToY, float fToZ);
//--------------------------------------------------------------------------------

// Inflation performs scaling of the shape sShapeName stored on oHere, in a
// particular way. Basic scaling as dictated by the rules of geometry has an
// unfortunate side effect that not only alters the size of the object but also
// changes its position. Fortunately there is a technique to avoid this. By
// temporarily moving the shape so that it is centred at the origin scaling will
// take place in all desired directions at once. Once scaling is over moving the
// object back to its original position will achieve scaling without movement.
// That technique is used here. Because scaling is possible not only for the overall
// shape but also in one or two directions only as well it is necessary to specify
// the direction(s) to perform such scaling. This is done via iInflationType using
// the predefined constants that start INFLATE_*. Scaling is performed by
// multiplication using fMultiplier.
int Inflation(object oHere, string sShapeName, float fMultiplier, int iInflationType = INFLATE_XYZ);
//--------------------------------------------------------------------------------

// For specified angles of rotation there is a faster shortcut method that can be
// used instead of performing a series of calculations. Those angles are 90, 180
// and 270 degrees. This method is used by FlipShape to quickly rotate shape
// sShapeName stored on object oHere. iFlipAngle is used to specify which of those
// 3 angles to use and constants have been defined for this purpose. Similarly
// iFlipAxis is used to specify which axis to rotate around using the ROTATION_AXIS_*
// constants.
int FlipShape(object oHere, string sShapeName, int iFlipAngle = FLIP_ANGLE_090, int iFlipAxis = ROTATION_AXIS_X);
//--------------------------------------------------------------------------------

// The 9 routines after NormaliseAngle all expect the angles passed to them to be in
// the range of -180 to 180 degrees. That is where NormaliseAngle comes in. It takes
// any angle specified in fDegrees and returns an angle in the specified range making
// any necessary corrections.
float NormaliseAngle(float fDegrees);
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// RotOneAngle, RotTwoAngles and RotThreeAngles are internal routines that do the
// actual rotation and are called by the routines that follow after them.
//--------------------------------------------------------------------------------

// The simplest of the three, RotOneAngle rotates the shape sShapeName stored on
// oHere. Rotation is about a single axis defined by iRotationAxis. This rotation is
// around the point in space defined by the vector vRotationPoint and travels through
// the angle defined by fRotAngle. This routine uses the function NormaliseAngle so
// you do not need to do so.
int RotOneAngle(object oHere, string sShapeName, float fRotAngle, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_X);
//--------------------------------------------------------------------------------
// RotTwoAngles rotates the shape sShapeName stored on oHere. Rotation is about two
// axis defined by iRotationAxis. These rotations are around the point in space defined
// by the vector vRotationPoint and travel through the angles defined by fRotAngle1
// and fRotAngle2. Due to the fact that the order in which the axis are rotated about
// is important and determines the final result of the rotations there are six
// different ROTATION_AXIS_* that can be used for iRotationAxis. This routine uses
// the function NormaliseAngle so you do not need to do so.
int RotTwoAngles(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_XY);
//--------------------------------------------------------------------------------
// RotThreeAngles rotates the shape sShapeName stored on oHere. Rotation is about 3
// axis defined by iRotationAxis. These rotation are around the point in space defined
// by the vector vRotationPoint and travel through the angles defined by fRotAngle1,
// fRotAngle2 and iRotAngle3. Due to the fact that the order in which the axis are
// rotated about is important and determines the final result of the rotations there
// are six different ROTATION_AXIS_* that can be used for iRotationAxis. This routine
// uses the function NormaliseAngle so you do not need to do so.
int RotThreeAngles(object oHere, string sShapeName, float iRotAngle1, float iRotAngle2, float iRotAngle3, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_XYZ);
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// The next three routines that start Spin* perform the rotation about the centre
// of the shape to be rotated. In other words calling these functions makes the
// shape spin around their own axis.
//--------------------------------------------------------------------------------

// SpinShapeOne spins shape sShapeName stored on object oHere about a single axis.
// The particular axis that is spun about is defined by iRotationAxis and travels
// through the angle held in fRotAngle. This function calls RotOneAngle to do the
// actual rotation.
int SpinShapeOne(object oHere, string sShapeName, float fRotAngle, int iRotationAxis = ROTATION_AXIS_X);
//--------------------------------------------------------------------------------
// SpinShapeTwo spins shape sShapeName stored on object oHere about two axis. The
// particular axis that are spun about is defined by iRotationAxis and travel
// through the angles held in fRotAngle1 and fRotAngle2. These angles must be in
// same order as specified by the particular ROTATION_AXIS_* constant used. For
// example if you use ROTATION_AXIS_ZY, fRotAngle1 must contain the angle of
// rotation to use for rotation around the Z axis and fRotAngle2 must contain
// the angle of rotation to use for rotation around the Y axis. This function
// calls RotTwoAngles to do the actual rotation.
int SpinShapeTwo(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, int iRotationAxis = ROTATION_AXIS_XY);
//--------------------------------------------------------------------------------
// SpinShapeThree spins shape sShapeName stored on object oHere about all three axis.
// The order that the axis are spun about is defined by iRotationAxis and travel
// through the angles held in fRotAngle1, fRotAngle2 and fRotAngle3. These angles
// must be in same order as specified by the particular ROTATION_AXIS_* constant
// used. For example if you use ROTATION_AXIS_ZYX, fRotAngle1 must contain the
// angle of rotation to use for rotation around the Z axis, fRotAngle2 must contain
// the angle of rotation to use for rotation around the Y axis and fRotAngle3
// must contain the angle of rotation to use for rotation around the Y axis. This
// function calls RotThreeAngles to do the actual rotation.
int SpinShapeThree(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, float fRotAngle3, int iRotationAxis = ROTATION_AXIS_XYZ);
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// These final three functions perform rotation of a shape around an arbitrary point
// in space. In other words they orbit this point like the Moon orbits the Earth
//(but in a more circular fashion.
//--------------------------------------------------------------------------------

// OrbitPointOne rotates the shape sShapeName stored on object oHere around the
// point in space defined by the vector vRotationPoint. Rotation is around a
// single axis defined by iRotationAxis and travels through fRotAngle degrees.
// This function calls RotOneAngle to do the actual rotation.
int OrbitPointOne(object oHere, string sShapeName, float fRotAngle, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_X);
//--------------------------------------------------------------------------------
// OrbitPointTwo rotates the shape sShapeName stored on object oHere around the
// point in space defined by the vector vRotationPoint. Rotation is around two
// axis defined by iRotationAxis and travels through angles fRotAngle1 and
// fRotAngle2. These angles must be in same order as specified by the particular
// ROTATION_AXIS_* constant used. For example if you use ROTATION_AXIS_ZY,
// fRotAngle1 must contain the angle of rotation to use for rotation around
// the Z axis and fRotAngle2 must contain the angle of rotation to use for rotation
// around the Y axis. This function calls RotTwoAngles to do the actual rotation.
int OrbitPointTwo(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_XY);
//--------------------------------------------------------------------------------
// OrbitPointThree rotates the shape sShapeName stored on object oHere around the
// point in space defined by the vector vRotationPoint. Rotation is around all
// three axis defined by iRotationAxis and travels through angles fRotAngle1,
// fRotAngle2 and fRotAngle3. These angles must be in same order as specified by
// the particular ROTATION_AXIS_* constant used. For example if you use
// ROTATION_AXIS_ZYX, fRotAngle1 must contain the angle of rotation to use for
// rotation around the Z axis, fRotAngle2 must contain the angle of rotation to use
// for rotation around the Y axis and fRotAngle3 must contain the angle of rotation
// to use for rotation around the Y axis. This function calls RotThreeAngles to do
// the actual rotation.
int OrbitPointThree(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, float fRotAngle3, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_XYZ);
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Vector Pseudo Array Routines
//--------------------------------------------------------------------------------

vector GetShapeCenter(object oTarget, string sShapeName)
{
    if (!GetIsObjectValid(oTarget) || sShapeName == "")
        return ERROR_VECTOR;
    else
        return GetListVector(oTarget, 0, sShapeName);
}

int SetShapeCenter(object oTarget, string sShapeName, vector vCenter)
{
    if(oHere == OBJECT_INVALID || sShapeName == "")
        return FALSE;
    else
        SetListVector(oTarget, 0, vCenter, sShapeName);

    return TRUE;
}

//TODO
int UpdateSingleElement(object oHere, string sShapeName, float fThisValue, int iThisElement = UPDATE_X)
{
    int iReturnThis = TRUE;

    if(oHere == OBJECT_INVALID || sShapeName == "" || iThisElement < UPDATE_X || iThisElement > UPDATE_Z)
        iReturnThis = FALSE;
    else
    {
        switch(iThisElement)
        {
            case UPDATE_X:
                SetLocalFloat(oHere, sShapeName + "X", fThisValue);
                break;
            case UPDATE_Y:
                SetLocalFloat(oHere, sShapeName + "Y", fThisValue);
                break;
            case UPDATE_Z:
                SetLocalFloat(oHere, sShapeName + "Z", fThisValue);
                break;
        }
    }
    return iReturnThis;
}

//TODO
int UpdateTwoElements(object oHere, string sShapeName, float fThisValue1, float fThisValue2, int iThisElement = UPDATE_XY)
{
    int iReturnThis = TRUE;

    if(oHere == OBJECT_INVALID || sShapeName == "" || iThisElement < UPDATE_XY || iThisElement > UPDATE_YZ)
        iReturnThis = FALSE;
    else
    {
        switch(iThisElement)
        {
            case UPDATE_XY:
                SetLocalFloat(oHere, sShapeName + "X", fThisValue1);
                SetLocalFloat(oHere, sShapeName + "Y", fThisValue2);
                break;
            case UPDATE_XZ:
                SetLocalFloat(oHere, sShapeName + "X", fThisValue1);
                SetLocalFloat(oHere, sShapeName + "Z", fThisValue2);
                break;
            case UPDATE_YZ:
                SetLocalFloat(oHere, sShapeName + "Y", fThisValue1);
                SetLocalFloat(oHere, sShapeName + "Z", fThisValue2);
                break;
        }
    }
    return iReturnThis;
}

//--------------------------------------------------------------------------------
// routine to create a new shape and populates it with the coordinates for
// that shape
//--------------------------------------------------------------------------------

int CreateShape(object oTarget, string sShapeName, int nVertices))
{
    if(!GetIsObjectValid(oTarget) || sShapeName == "" || nVertices < 3)
        return FALSE;

    float fAngle, fX, fY;
    int i;

    DeclareVectorList(oTarget, nVertices + 1, sShapeName);
    fAngle = 360.0f / nVertices;

    for (i = 1; i <= nVertices; i++)
    {
        fX = round(sin(fAngle), 5);
        fY = round(cos(fAngle), 5);

        SetListVector(oTarget, i, Vector(fX, fY, 0.0f), sShapeName);
        fAngle += fAngle;
    }

    return TRUE;
}

//--------------------------------------------------------------------------------
// routine uses trigonometry to calculate the fMultiplier to pass to Inflation() in
// order to enlarge a regular polygon so that each of its sides are a given size.
//--------------------------------------------------------------------------------
//TODO
float SideFactor(float fSideSize, int iNumberOfSides)
{
    float fAngle = 180.0f / IntToFloat(iNumberOfSides);
    return (fSideSize * 0.5) / sin(fAngle);
}

int DeleteShape(object oTarget, string sShapeName)
{
    DeleteVectorList(oTarget, sShapeName); 
}

//--------------------------------------------------------------------------------
// Split a shape into two halves and recentre both halves
//--------------------------------------------------------------------------------
//TODO
int SplitShape(object oTarget, string sSplitThis, string sNewShapeHalf)
{
    if (SplitVArray(oHere, sSplitThis, sNewShapeHalf))
        if (RecalculateShapeCenter(oHere, sSplitThis))
            return RecalculateShapeCenter(oHere, sNewShapeHalf);

    return FALSE;
}

//--------------------------------------------------------------------------------
// Three routines to convert 2D shapes into 3D shapes.
//--------------------------------------------------------------------------------
//TODO
int Extrude3DShape(object oHere, string sThis)
{
    int iIndex;
    int iReturnThis = TRUE;
    int iMaxIndex;
    string sIndexNumber;
    vector vTempVector;

    if(oHere == OBJECT_INVALID || sThis == "")
        iReturnThis = FALSE;
    else
    {
        iMaxIndex = GetLocalInt(oHere, sThis + "Max");

        if(iMaxIndex < 3 || iMaxIndex > 9)
            iReturnThis = FALSE;
        else
        {
            ExtendVArray(oHere, sThis, iMaxIndex);

            for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
            {
                vTempVector = RetrieveVector(oHere, sThis, iIndex);

                sIndexNumber = IntToPaddedString(iIndex);

                if(UpdateSingleElement(oHere, sThis + sIndexNumber, -1.0f, UPDATE_Z))
                {
                    vTempVector.z = 1.0f;

                    if(!(UpdateVector(oHere, sThis, vTempVector, iIndex + iMaxIndex)))
                    {
                        iReturnThis = FALSE;
                        break;
                    }
                }
                else
                {
                    iReturnThis = FALSE;
                    break;
                }
            }
        }
    }
    return iReturnThis;
}

int AddPyramidalNodes(object oTarget, string sShapeName, int nNodes = 1)
{
    if (oTarget == OBJECT_INVALID || sShapeName == "" || nNodes < 1 || nNodes > 2)
        return FALSE;

    vector v;

    v = GetShapeCenter(oTarget, sShapeName);
    v.z = 1.0f;
    AddListVector(oTarget, v, sShapeName)

    if (nNodes == 2)
    {
        v.z = -1.0f;
        AddListVector(oTarget, v, sShapeName);
    }
    RecalculateShapeCenter(oTarget, sShapeName);

    return TRUE;
}

int RecalculateShapeCenter(object oTarget, string sShapeName)
{
    float fMaxX, fMinX, fMaxY, fMinY, fMaxZ, fMinZ;
    float fNewX, fNewY, fNewZ;

    if (!GetIsObjectValid(OBJECT_INVALID) || sShapeName == "")
        return FALSE;

    int i, nCount = CountVectorList(oTarget, sShapeName);

    if (nCount < 2)
        return FALSE;
    else
    {
        vector v = GetListVector(oTarget, 1, sShapeName);

        fMaxX = vTestVector.x;
        fMinX = vTestVector.x;
        fMaxY = vTestVector.y;
        fMinY = vTestVector.y;
        fMaxZ = vTestVector.z;
        fMinZ = vTestVector.z;

        for(i = 2 ; i <= nCount ; i++)
        {
            v = GetListVector(oTarget, i, sShapeName);

            fMaxX = max(v.x, fMaxX);
            fMinX = min(v.x, fMinX);
            fMaxY = max(v.y, fMaxY);
            fMinY = min(v.y, fMinY);
            fMaxZ = max(v.z, fMaxZ);
            fMinz = min(v.z, fMinZ);
        }

        if (fMinX == fMaxX)
            fNewX = fMaxX;
        else
            fNewX = fMinX + ((fMaxX - fMinX) / 2);

        if (fMinY == fMaxY)
            fNewY = fMaxY;
        else
            fNewY = fMinY + ((fMaxY - fMinY) / 2);

        if (fMinZ == fMaxZ)
            fNewZ = fMaxZ;
        else
            fNewZ = fMinZ + ((fMaxZ - fMinZ) / 2);

        SetShapeCenter(oTarget, sShapeName, Vector(fNewX, fNewY, fNewZ));
    }

    return TRUE;
}

int _MoveShape(object oTarget, string sShapeName, float fByX, float fByY, float fByZ)
{
    if(oTarget == OBJECT_INVALID || sShapeName == "")
        return FALSE;

    int i, nCount = CountVectorList(oTarget, sShapeName);
    vector vUpdate, vShapeCenter;

    if(!nCount)
        return FALSE;

    vShapeCenter = GetShapeCenter(oTarget, sShapeName);
    vShapeCenter.x += fByX;
    vShapeCenter.y += fByY;
    vShapeCenter.z += fByZ;

    if (SetShapeCenter(oTarget, sShapeName, vShapeCenter))
    {
        for (i = 1 ; i <= nCount; i++)
        {
            vUpdate = GetListVector(oTarget, i, sShapeName);
            vUpdate.x += fByX;
            vUpdate.y += fByY;
            vUpdate.z += fByZ;
            SetListVector(oTarget, i, vUpdate, sShapeName);

            return TRUE;
        }
    }
    else
        return FALSE;
}

int MoveShape(object oTarget, string sShapeName, float fToX, float fToY, float fToZ)
{
    float fByX, fByY, fByZ;
    vector vShapeCenter;

    if(oHere == OBJECT_INVALID || sShapeName == "")
        return FALSE;
    else if(fToX < 0.0 || fToY < 0.0 || fToZ < 0.0)
        return FALSE;
    else
    {
        vShapeCenter = GetShapeCenter(oTarget, sShapeName);

        fByX = fToX - vShapeCenter.x;
        fByY = fToY - vShapeCenter.y;
        fByZ = fToZ - vShapeCenter.z;

        return _MoveShape(oTarget, sShapeName, fByX, fByY, fByZ);
    }   
}

int InflateShape(object oTarget, string sShapeName, float fMultiplier, int iInflationType)
{
    if (oTarget == OBJECT_INVALID || sShapeName == "" || fMultiplier < 0.0 || iInflationType < INFLATE_X || iInflationType > INFLATE_Z)
        return FALSE;

    int i, nCount = CountVectorList(oTarget, sShapeName);
    vector vInflate;

    if (!nCount)
        return FALSE;

    vShapeCenter = GetShapeCenter(oTarget, sShapeName);

    for (i = 0; i < nCount; i++)
    {
        vInflate = GetListVector(oTarget, i, sShapeName);

        if (nInflationType & INFLATE_X)
            vInflate.x = ((vInflate.x - vShapeCenter.x) * fMultiplier) + vShapeCenter.x;

        if (nInflationType & INFLATE_Y)
            vInflate.y = ((vInflate.y - vShapeCenter.y) * fMultiplier) + vShapeCenter.y;

        if (nInflationType & INFLATE_Z)
            vInflate.z = ((vInflate.z - vShapeCenter.z) * fMultiplier) + vShapeCenter.z;

        SetListVector(oTarget, i, vInflate, sShapeName);
    }

    return TRUE;
}

//--------------------------------------------------------------------------------
// Fast rotation for particular angles
//--------------------------------------------------------------------------------
//TODO
int FlipShape(object oHere, string sShapeName, int iFlipAngle = FLIP_ANGLE_090, int iFlipAxis = ROTATION_AXIS_X)
{
    float fTempX, fTempY, fTempZ;
    int iIndex;
    int iMaxIndex;
    int iReturnThis = TRUE;
    vector vTemp;
    vector vOldCentre;

    if(oHere == OBJECT_INVALID || sShapeName == "")
        iReturnThis = FALSE;
    else if(iFlipAngle < FLIP_ANGLE_090 || iFlipAngle > FLIP_ANGLE_270 || iFlipAxis < ROTATION_AXIS_X || iFlipAxis > ROTATION_AXIS_Z)
        iReturnThis = FALSE;
    else
    {
        iMaxIndex = GetLocalInt(oHere, sShapeName + "Max");

        if(iMaxIndex < 1)
            iReturnThis = FALSE;
        else
        {
            vOldCentre = GetLocalShapeCentre(oHere, sShapeName);

            if(MoveShape(oHere, sShapeName, 0.0, 0.0, 0.0))
            {
                switch(iFlipAngle)
                {
                    case FLIP_ANGLE_090 :
                        switch(iFlipAxis)
                        {
                            case ROTATION_AXIS_X :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempY = vTemp.z;
                                    fTempZ = vTemp.y * -1.0f;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempY, fTempZ, UPDATE_YZ);
                                }
                                break;
                            case ROTATION_AXIS_Y :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempX = vTemp.z * -1.0f;
                                    fTempZ = vTemp.x;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempX, fTempZ, UPDATE_XZ);
                                }
                                break;
                            case ROTATION_AXIS_Z :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempX = vTemp.y * -1.0f;
                                    fTempY = vTemp.x;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempX, fTempY);
                                }
                                break;
                        }
                        break;
                    case FLIP_ANGLE_180 :
                        switch(iFlipAxis)
                        {
                            case ROTATION_AXIS_X :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempY = vTemp.y * -1.0f;
                                    fTempZ = vTemp.z * -1.0f;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempY, fTempZ, UPDATE_YZ);
                                }
                                break;
                            case ROTATION_AXIS_Y :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempX = vTemp.x * -1.0f;
                                    fTempZ = vTemp.z * -1.0f;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempX, fTempZ, UPDATE_XZ);
                                }
                                break;
                            case ROTATION_AXIS_Z :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempX = vTemp.x * -1.0f;
                                    fTempY = vTemp.y * -1.0f;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempX, fTempY);
                                }
                                break;
                        }
                        break;
                    case FLIP_ANGLE_270 :
                        switch(iFlipAxis)
                        {
                            case ROTATION_AXIS_X :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempY = vTemp.z * -1.0f;
                                    fTempZ = vTemp.y;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempY, fTempZ, UPDATE_YZ);
                                }
                                break;
                            case ROTATION_AXIS_Y :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempX = vTemp.z;
                                    fTempZ = vTemp.x * -1.0f;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempX, fTempZ, UPDATE_XZ);
                                }
                                break;
                            case ROTATION_AXIS_Z :
                                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                                {
                                    vTemp = RetrieveVector(oHere, sShapeName, iIndex);
                                    fTempX = vTemp.y;
                                    fTempY = vTemp.x * -1.0f;
                                    UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), fTempX, fTempY);
                                }
                                break;
                        }
                        break;
                }
                if(!(MoveShape(oHere, sShapeName, vOldCentre.x, vOldCentre.y, vOldCentre.z)))
                    iReturnThis = FALSE;
            }
            else
                iReturnThis = FALSE;
        }
    }
    return iReturnThis;
}

//--------------------------------------------------------------------------------
// Routine to correct angles to a usable range
//--------------------------------------------------------------------------------
TODO
float NormaliseAngle(float fDegrees)
{
    while(fDegrees > 180.0f)
        fDegrees = fDegrees - 360.0f;

    while(fDegrees < -180.0f)
        fDegrees = fDegrees + 360.0f;

    return fDegrees;
}

//--------------------------------------------------------------------------------
// Internal routines to rotate a shape around 1 - 3 axis
//--------------------------------------------------------------------------------
//TODO
int _RotateShape(object oTarget, string sShapeName, float fAngle, vector vShapeCenter, int nAxis)
int RotOneAngle(object oHere, string sShapeName, float fRotAngle, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_X)
{
    float fTempX;
    float fTempY;
    float fTempZ;
    float fNewX;
    float fNewY;
    float fNewZ;
    float fC;
    float fS;
    int iIndex;
    vector v;

    fC = cos(NormaliseAngle(fAngle));
    fS = sin(NormaliseAngle(fAngle));

    //TODO check all these loops for the correct values given 1st vector is the centerpoint
    int i, nCount = CountVectorList(oTarget, sShapeName);

    switch(nAxis)
    {
        case ROTATION_AXIS_X :
            for (i = 1; i <= nCount; i++)
            {
                v = GetListVector(oTarget, i, sShapeName);

                fTempY = v.y - vShapeCenter.y;
                fTempZ = v.z - vShapeCenter.z;

                fNewY = fTempY * fC + fTempZ * fS;
                fNewZ = fTempZ * fC - fTempY * fS;

                v.y = fNewY + vShapeCenter.y;
                v.z = fNewZ + vShapeCenter.z;

// WORKING HERE

                UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), vTemp.y, vTemp.z, UPDATE_YZ);
            }
            break;
        case ROTATION_AXIS_Y :
            for (i = 1; i <= nCount; i++)
            {
                v = GetListVector(oTarget, i, sShapeName);

                fTempX = vTemp.x - vRotationPoint.x;
                fTempZ = vTemp.z - vRotationPoint.z;

                fNewX = fTempX * fC - fTempZ * fS;
                fNewZ = fTempX * fS + fTempZ * fC;

                vTemp.x = fNewX + vRotationPoint.x;
                vTemp.z = fNewZ + vRotationPoint.z;

                UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), vTemp.x, vTemp.z, UPDATE_XZ);
            }
            break;
        case ROTATION_AXIS_Z :
            for (i = 1; i <= nCount; i++)
            {
                v = GetListVector(oTarget, i, sShapeName);

                fTempX = vTemp.x - vRotationPoint.x;
                fTempY = vTemp.y - vRotationPoint.y;

                fNewX = fTempX * fC - fTempY * fS;
                fNewY = fTempX * fS + fTempY * fC;

                vTemp.x = fNewX + vRotationPoint.x;
                vTemp.y = fNewY + vRotationPoint.y;

                UpdateTwoElements(oHere, sShapeName + IntToPaddedString(iIndex), vTemp.x, vTemp.y);
            }
            break;
    }

    return TRUE;
}

int RotateShape(object oTarget, string sShapeName, vector vRotationAngles)
{
    if (!GetIsObjectValid(oTarget) || sShapeName == "")
        return FALSE;

    if (!CountVecotrList(oTarget, sShapeName))
        return FALSE;

    vector vCenter = GetListVector(oTarget, 0, sShapeName);

    if (vRotationAngles.x)
        _RotateShape(oTarget, sShapeName, vRotationAngles.x, vCenter, ROTATION_AXIS_X);

    if (vRotationAngles.y)
        _RotateShape(oTarget, sShapeName, vRotationAngles.y, vCenter, ROTATION_AXIS_Y);

    if (vRotationAngles.z)
        _RotateShape(oTarget, sShapeName, vRotationAngles.z, vCenter, ROTATION_AXIS_Z);

    RecalculateShapeCenter(oTarget, sShapeName);
    return TRUE;
}

int SpinShapeOne(object oHere, string sShapeName, float fRotAngle, int iRotationAxis = ROTATION_AXIS_X)
{
    vector vCentre = GetShapeCenter(oHere, sShapeName);

    int iDummy;

    int iReturnThis = RotOneAngle(oHere, sShapeName, fRotAngle, vCentre, iRotationAxis);

    if(iReturnThis)
        iDummy = RecalculateShapeCenter(oHere, sShapeName);

    return iReturnThis;
}

//TODO
int SpinShapeTwo(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, int iRotationAxis = ROTATION_AXIS_XY)
{
    vector vCentre = GetShapeCenter(oHere, sShapeName);

    int iDummy;

    int iReturnThis = RotTwoAngles(oHere, sShapeName, fRotAngle1, fRotAngle2, vCentre, iRotationAxis);

    if(iReturnThis)
        iDummy = RecalculateShapeCenter(oHere, sShapeName);

    return iReturnThis;
}

//TODO
int SpinShapeThree(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, float fRotAngle3, int iRotationAxis = ROTATION_AXIS_XYZ)
{
    vector vCentre = GetShapeCenter(oHere, sShapeName);

    int iDummy;

    int iReturnThis = RotThreeAngles(oHere, sShapeName, fRotAngle1, fRotAngle2, fRotAngle3, vCentre, iRotationAxis);

    if(iReturnThis)
        iDummy = ReCentreShape(oHere, sShapeName);

    return iReturnThis;
}

//--------------------------------------------------------------------------------
// routines to rotate a shape around an arbitrary point in space
//--------------------------------------------------------------------------------
//TODO
int OrbitPointOne(object oHere, string sShapeName, float fRotAngle, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_X)
{
    int iDummy;
    int iReturnThis = RotOneAngle(oHere, sShapeName, fRotAngle, vRotationPoint, iRotationAxis);

    if(iReturnThis)
        iDummy = RecalculateShapeCenter(oHere, sShapeName);

    return iReturnThis;
}

//TODO
int OrbitPointTwo(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_XY)
{
    int iDummy;
    int iReturnThis = RotTwoAngles(oHere, sShapeName, fRotAngle1, fRotAngle2, vRotationPoint, iRotationAxis);

    if(iReturnThis)
        iDummy = RecalculateShapeCenter(oHere, sShapeName);

    return iReturnThis;
}

//TODO
int OrbitPointThree(object oHere, string sShapeName, float fRotAngle1, float fRotAngle2, float fRotAngle3, vector vRotationPoint, int iRotationAxis = ROTATION_AXIS_XYZ)
{
    int iDummy;
    int iReturnThis = RotThreeAngles(oHere, sShapeName, fRotAngle1, fRotAngle2, fRotAngle3, vRotationPoint, iRotationAxis);

    if(iReturnThis)
        iDummy = RecalculateShapeCenter(oHere, sShapeName);

    return iReturnThis;
}

// inc_draw
//--------------------------------------------------------------------------------
// Encoded constant strings that define the lines to draw and the order to draw
// them in. See DrawConnected() for a slightly fuller explanation.
//--------------------------------------------------------------------------------

const string csPentagram = "010305020401";          //Only use with SHAPE_PENTAGON
const string csTriArrow =  "01020501030401";        //Only use with SHAPE_PENTAGON
const string csStarOfDavid = "01030501-102040602";  //Only use with SHAPE_HEXAGON

//--------------------------------------------------------------------------------
// Constant int that determines which beam vfx to use for drawing lines
//--------------------------------------------------------------------------------

const int ciThisBeamVFX = VFX_BEAM_FIRE_W_SILENT;

//--------------------------------------------------------------------------------

// Make sure that the shape to draw will actually all fit in an area. This area is
// the same one that object oHere is located within.
// The shape to be tested is held in pseudo-array sThis stored on the object oHere.
// This function returns either TRUE or FALSE. Be aware that it also tests for some
// error conditions (oHere == OBJECT_INVALID, sThis == "", sThis holding < 2 vectors)
// and returns FALSE if they are detected.
int ShapeIsDrawable(object oHere, string sThis);
//--------------------------------------------------------------------------------
// First part of the drawing routines. Must be called *BEFORE* any of the line
// drawing routines. This function creates objects specified by sThisResRef. It
// paints them at locations in an area. This area is the same one that object oHere
// is located in. The centre of each object that is to be painted at is defined by
// the vectors held in the pseudo-array sThisShape which is stored on object oHere.
//
// Note can be called on its own in order to display patterns of visible objects.
// Also it perfectly fine for object oHere to be the area in which the created
// objects are painted. This function tests for error conditions and returns a
// boolean value as appropriate.
int DrawPoints(object oHere, string sThisShape, string sThisResRef = "plc_invisobj");
//--------------------------------------------------------------------------------
// The converse  of the previous routine. This function completely destroys objects
// which have been created by DrawPoints(). Barring a tag-naming conflict, should
// it should not destroy any other objects. As a by-product this routine should
// also remove any lines drawn between these points.
//
// The objects to be destroyed are specified by the vectors held in the pseudo-array
// sThisShape which is stored on object oHere. fTimeDelay specifies how long after
// this function is called before the objects are destroyed. Tests for errors and
// returns a boolean depending on whether any were found.
int ErasePoints(object oHere, string sThisShape, float fTimeDelay = 0.001);
//--------------------------------------------------------------------------------
// A convenience function. This function first calls ErasePoints() and if that
// function completes successfully it calls DrawPoints. This function returns a
// boolean that depends on how successful the calls to those two functions were.
//
// Note, calling this routine when there are no points already drawn will result in
// an error being flagged by FALSE being returned.
int RedrawPoints(object oHere, string sThisShape, string sThisResRef = "plc_invisobj");
//--------------------------------------------------------------------------------
// Draw a single line between two already displayed points. Although really intended
// as an internal routine it still tests for error conditions. Should any be found it
// returns OBJECT_INVALID.
//
// sThisShape is the pseudo-array that defined the points that were previously drawn.
// In this instance it is only needed because its name was used as part of the tags
// that identify individual point objects. object oStartPoint is the object that the
// beam vfx, used for drawing the line, originates from. string sEndPoint holds a
// string representation of the number of the point that is the target for the vfx.
// this number must consist of exactly two digits. Numbers less than 10 must have a
// leading zero prepended to them (eg "9" must be represented by "09"). Upon
// successful completion this routine returns the object that sEndPoint represents.
object DrawLine(string sThisShape, object oStartPoint, string sEndPoint);
//--------------------------------------------------------------------------------
// Draw a single line between two already displayed points. Although really intended
// as an internal routine it still tests for error conditions. Should any be found it
// returns FALSE otherwise TRUE.
//
// object oStartPoint and object oEndPoint are the already displayed points.
int DrawLine2(object oStartPoint, object oEndPoint);
//--------------------------------------------------------------------------------
// Draws a simple closed 2d shape in 3d space (eg a polygon). The shape is held in
// the pseudo-array sThisShape stored on object oHere. Returns a boolean representing
// the non-presence of errors.
int DrawSimpleShape(object oHere, string sThisShape);
//--------------------------------------------------------------------------------
// A convenience function. Calls RedrawPoints() followed by DrawSimpleShape() and
// returns a boolean. This function is to be preferred over calling those functions
// individually.
int RedrawSimpleShape(object oHere, string sThisShape, string sThisResRef = "plc_invisobj");
//--------------------------------------------------------------------------------
// A convenience function. Calls DrawSimpleShape() followed by DrawRadials() and
// returns a boolean. This function is to be preferred over calling those functions
// individually.
int DrawPyramidal(object oHere, string sThisShape, int iSinglePoint = TRUE);
//--------------------------------------------------------------------------------
// A convenience function. Calls RedrawPoints() followed by DrawPyramidal() and
// returns a boolean. This function is to be preferred over calling those functions
// individually otherwise no guarantee on you achieving the correct shape.
int RedrawPyramidal(object oHere, string sThisShape, int iSinglePoint = TRUE, string sThisResRef = "plc_invisobj");
//--------------------------------------------------------------------------------
// Draws shapes that have been created by the use of the Extrude function. The shape
// is held in pseudo-array sThisShape held on object oHere. Returns a boolean.
int DrawExtruded(object oHere, string sThisShape);
//--------------------------------------------------------------------------------
// A convenience function. Calls RedrawPoints() followed by DrawExtruded() and
// returns a boolean. This function is to be preferred over calling those functions
// individually.
int RedrawExtruded(object oHere, string sThisShape, string sThisResRef = "plc_invisobj");
//--------------------------------------------------------------------------------
// Uses an encoded string to specify which points to connect together and the order in
// which to draw them. It is encoded in that it is a series of numbers combined together
// such that each number consists of 2 digits. Numbers less than 10 must have a leading
// zero. The number "-1" is used to signify that the "pen" is to be lifted and a new
// series of lines be drawn. See the predefined string constants at the start of this
// library for examples.
//
// string sThisShape specifies the pseudo-array that holds the vectors used. sThisShape
// is stored on object oHere. sConnectionList holds the encoded string. Returns a boolean.
int DrawConnected(object oHere, string sThisShape, string sConnectionList = csPentagram);
//--------------------------------------------------------------------------------
// A convenience function. Calls RedrawPoints() followed by DrawConnected() and
// returns a boolean. This function is to be preferred over calling those functions
// individually.
int RedrawConnected(object oHere, string sThisShape, string sConnectionList = csPentagram, string sThisResRef = "plc_invisobj");
//--------------------------------------------------------------------------------
//TODO
// Make sure that the shape to draw will actually all fit in the area
int ShapeIsDrawable(object oHere, string sThis)
{
    vector vTestVector;
    int iIndex;
    int iReturnThis = TRUE;
    int iMaxIndex;
    object oArea;
    float fWidth;
    float fHeight;

    if(oHere == OBJECT_INVALID || sThis == "")
        iReturnThis = FALSE;
    else
    {
        iMaxIndex = GetLocalInt(oHere, sThis + "Max");

        if(iMaxIndex < 2)
            iReturnThis = FALSE;
        else
        {
            oArea = GetArea(oHere);
            fWidth = IntToFloat(GetAreaSize(AREA_WIDTH, oArea)) * 10.0;
            fHeight = IntToFloat(GetAreaSize(AREA_HEIGHT, oArea)) * 10.0;

            vTestVector = GetLocalShapeCentre(oHere, sThis);

            if(vTestVector.x < 0.0 || vTestVector.y < 0.0 || vTestVector.z < 0.0)
                iReturnThis = FALSE;
            else if(vTestVector.x > fWidth || vTestVector.y > fHeight)
                iReturnThis = FALSE;
            else
            {
                for(iIndex = 1 ; iIndex <= iMaxIndex ; iIndex++)
                {
                    vTestVector = RetrieveVector(oHere, sThis, iIndex);

                    if(vTestVector.x < 0.0 || vTestVector.y < 0.0 || vTestVector.z < 0.0)
                    {
                        iReturnThis = FALSE;
                        break;
                    }
                    else if(vTestVector.x > fWidth || vTestVector.y > fHeight)
                    {
                        iReturnThis = FALSE;
                        break;
                    }
                }
            }
        }
    }
    return iReturnThis;
}

// First part of the drawing routines. Must be called *BEFORE* any of the line drawing routines
// Note can be called on its own in order to display patterns of visible objects
//DrawPoints
int CreateNodes(object oTarget, string sShapeName, string sPlaceable = "plc_invisobj")
{
    if(!GetIsObjectValid(oTarget) || sShapeName == "" || sPlaceable == "")
        return FALSE;

    if (_GetLocalInt(oTarget, SHAPE_DRAWN))
        return FALSE;

    if (ShapeIsDrawable(oTarget, sShapeName))
    {
        int i, nCount = CountVectorList(oTarget, sShapeName);

        if (!nCount)
            return FALSE;

        for (i = 1; i <= nCount; i++)
        {
            vector v = GetListVector(oTarget, i, sShapeName);
            location lShapeLocation = Location(GetArea(oTarget), v, DIRECTION_NORTH);
            object oPlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, sPlaceable, lShapeLocation);

            if (!GetIsObjectValid(oPlaceable))
                return FALSE;

            SetTag(oPlaceable, sShapeName + IntToString(i));
        }

        _SetLocalInt(oTarget, SHAPE_DRAWN + sShapeName, TRUE);
    }
    else
        return FALSE;

    return iReturnThis;
}

int DeleteNodes(object oTarget, string sShapeName, float fDelay = 0.001)
{
    if (oTarget == OBJECT_INVALID || sShapeName == "")
        return FALSE;

    if (!_GetLocalInt(oTarget, SHAPE_DRAWN))
        return FALSE;

    int i, nCount = CountVectorList(oTarget, sShapeName);
    object oPlaceable;

    if (!nCount)
        return FALSE;

    for (i = 1; i <= nCount; i++)
    {
        oPlaceable = GetObjectByTag(sShapeName + IntToString(i));

        if (GetIsObjectValid(oPlaceable))
            DestroyObject(oPlaceable, fDelay);
        else
            return FALSE;
    }

    _DeleteLocalInt(oTarget, SHAPE_DRAWN + sShapeName);
    return TRUE;
}

//RedrawPoints
int RedrawNodes(object oTarget, string sShapeName, string sPlaceable = "plc_invisobj")
{
    if (DeleteNodes(oTarget, sShapeName, 0.000000001))
        return CreateNoted(oTarget, sShapeName, sPlaceable);
    else
        return FALSE;
}

//WORKING HERE

// Draw a single line between two already displayed points represented by
// object oStartPoint and string sEndPoint.
object DrawLine(string sShapeName, object oStartNode, string sEndNode)
{
    string sBaseTag = sShapeName + "OBJ";
    object oEndPoint;
    object oReturnThis;

    if(oStartPoint == OBJECT_INVALID || sShapeName == "" || sEndPoint == "" || GetStringLength(sEndPoint) != 2)
        oReturnThis = OBJECT_INVALID;
    else if(StringToInt(sEndPoint) == 0)
        oReturnThis = OBJECT_INVALID;
    else
    {
        oEndPoint = GetObjectByTag(sBaseTag + sEndPoint);

        if(oEndPoint == OBJECT_INVALID)
            oReturnThis = OBJECT_INVALID;
        else
        {
            AssignCommand(oStartPoint, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(ciThisBeamVFX, oStartPoint, BODY_NODE_CHEST), oEndPoint));
            oReturnThis = oEndPoint;
        }
    }
    return oReturnThis;
}

// Draw a single line between two already displayed points represented by
// object oStartPoint and object oEndPoint
int DrawLine2(object oStartPoint, object oEndPoint)
{
    int iReturnThis = TRUE;

    if(oStartPoint == OBJECT_INVALID || oEndPoint == OBJECT_INVALID)
        iReturnThis = FALSE;
    else
        AssignCommand(oStartPoint, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(ciThisBeamVFX, oStartPoint, BODY_NODE_CHEST), oEndPoint));

    return iReturnThis;
}

// Draws a simple closed 2d shape in 3d space  //TODO
//DrawSimpleShape
int DrawShape(object oTarget, string sShapeName)
{
    int iIndex;
    int iMaxIndex;
    int iReturnThis = TRUE;
    string sBaseTag = sShapeName + "OBJ";
    object oStartPoint;
    object oEndPoint;

    if (!GetIsObjectValid(oTarget) || sShapeName == "")
        return FALSE;

    if (ShapeIsDrawable(oTarget, sShapeName))
    {
        int i, nCount = CountVectorList(oTarget, sShapeName);

        if (!nCount)
            return FALSE;

        oStartPoint = GetObjectByTag(sShapeName + IntToString(i));
        oEndPoint = GetObjectByTag(sBaseTag + IntToPaddedString(iMaxIndex));

        if (oStartPoint == OBJECT_INVALID || oEndPoint == OBJECT_INVALID)
            return FALSE;
        else
        {
            AssignCommand(oStartPoint, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(ciThisBeamVFX, oStartPoint, BODY_NODE_CHEST), oEndPoint));

            for(iIndex = 2 ; iIndex <= iMaxIndex ; iIndex++)
            {
                oStartPoint = DrawLine(sShapeName, oStartPoint, IntToPaddedString(iIndex));

                if(!GetIsObjectValid(oStartPoint))
                    return FALSE;
            }
        }
    }
    else
        return FALSE;

    return TRUE;
}

//RedrawSimpleShape  TODO - make the plc_invisobj a constant so it can be changed.
int RedrawShape(object oTarget, string sShapeName, string sPlaceable = "plc_invisobj")
{
    if (RedrawNodes(oTarget, sShapeName, sPlaceable))
        return DrawShape(oTarget, sShapeName);
    else
        return FALSE;
}

//DrawPyramidal
int DrawPyramidal(object oTarget, string sShapeName, int iSinglePoint = TRUE)
{
    int iIndex;
    int iMaxIndex;
    int iFinalIndex;
    int iReturnThis = TRUE;
    string sBaseTag = sThisShape + "OBJ";
    object oStartPoint;
    object oEndPoint;
    object oApex1;
    object oApex2;

    if(!GetIsObjectValid(oTarget) || sShapeName == "")
        return FALSE;

    if (ShapeIsDrawable(oHere, sThisShape))
    {
        //iMaxIndex = LastIndex(oHere, sThisShape);
        iMaxIndex = CountVectorList(oHere, sThisShape);

        if(iMaxIndex < 0)
           return FALSE;

        oStartPoint = GetObjectByTag(sBaseTag + "01");
        oApex1 = GetObjectByTag(sBaseTag + IntToPaddedString(iMaxIndex));

        if(iSinglePoint)
            iFinalIndex = iMaxIndex -1;
        else
        {
            iFinalIndex = iMaxIndex -2;
            oApex2 = GetObjectByTag(sBaseTag + IntToPaddedString(iMaxIndex -1));

            if(oApex2 == OBJECT_INVALID)
                iReturnThis = FALSE;
        }

        oEndPoint = GetObjectByTag(sBaseTag + IntToPaddedString(iFinalIndex));

        if(oStartPoint == OBJECT_INVALID || oEndPoint == OBJECT_INVALID || oApex1 == OBJECT_INVALID || !(iReturnThis))
            iReturnThis = FALSE;
        else
        {
            AssignCommand(oStartPoint, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(ciThisBeamVFX, oStartPoint, BODY_NODE_CHEST), oEndPoint));
            DrawLine2(oStartPoint, oApex1);

            if(!(iSinglePoint))
                DrawLine2(oStartPoint, oApex2);

            for(iIndex = 2 ; iIndex <= iFinalIndex ; iIndex++)
            {
                oStartPoint = DrawLine(sThisShape, oStartPoint, IntToPaddedString(iIndex));

                if(oStartPoint == OBJECT_INVALID)
                {
                    iReturnThis = FALSE;
                    break;
                }

                DrawLine2(oStartPoint, oApex1);

                if(!(iSinglePoint))
                    DrawLine2(oStartPoint, oApex2);

            }
        }
    }
    else
        iReturnThis = FALSE;

    return iReturnThis;
}

int RedrawPyramidal(object oTarget, string sShapeName, int iSinglePoint = TRUE, string sPlaceable = "plc_invisobj")
{
    if (RedrawNodes(oTarget, sShapeName, sPlaceable))
        return DrawPyramidal(oTarget, sShapeName, iSinglePoint);
    else
        return FALSE;
}

//TODO
// Draws shapes that have been created by the use of the Extrude function
int DrawExtruded(object oHere, string sThisShape)
{
    int iHalfShape;
    int iMaxIndex;
    int iIndex;
    int iReturnThis = TRUE;
    object oStartPoint1;
    object oStartPoint2;
    object oEndPoint1;
    object oEndPoint2;
    string sIndex;
    string sBaseTag = sThisShape + "OBJ";

    if(oHere == OBJECT_INVALID || sThisShape == "")
        iReturnThis = FALSE;
    else
    {
        //iMaxIndex = LastIndex(oHere, sThisShape);
        iMaxIndex = CountVectorList(oHere, sThisShape);

        if(iMaxIndex & 1 || iMaxIndex < 3 || iMaxIndex > 9)
            iReturnThis = FALSE;
        else
        {
            iHalfShape = iMaxIndex / 2;
            oStartPoint1 = GetObjectByTag(sBaseTag + "01");
            oStartPoint2 = DrawLine(sThisShape, oStartPoint1, IntToPaddedString(iHalfShape + 1));
            oEndPoint1 = GetObjectByTag(sBaseTag + IntToPaddedString(iHalfShape));
            oEndPoint2 = GetObjectByTag(sBaseTag + IntToPaddedString(iMaxIndex));
            DrawLine2(oStartPoint1, oEndPoint1);
            DrawLine2(oStartPoint2, oEndPoint2);

            for(iIndex = 2 ; iIndex <= iHalfShape ; iIndex++)
            {
                oStartPoint1 = DrawLine(sThisShape, oStartPoint1, IntToPaddedString(iIndex));
                oStartPoint2 = DrawLine(sThisShape, oStartPoint2, IntToPaddedString(iHalfShape + iIndex));
                AssignCommand(oStartPoint1, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(ciThisBeamVFX, oStartPoint1, BODY_NODE_CHEST), oStartPoint2));
            }
        }
    }
    return iReturnThis;
}

int RedrawExtruded(object oTarget, string sShapeName, string sPlaceable = "plc_invisobj")
{
    if (RedrawNodes(oTarget, sShapeName, sPlaceable))
        return DrawExtruded(oTarget, sShapeName);
    else
        return FALSE;
}

// Uses an encoded string to specify which points to connect together and the order in
// which to draw them. It is encoded in that it is a series of numbers combined together
// such that each number consists of 2 digits. Numbers less than 10 must have a leading
// zero. The number "-1" is used to signify that the "pen" is to be lifted and a new
// series of lines be drawn.
//DrawConnected
int DrawOrderedShape(object oTarget, string sShapeName, string sConnectionList)
{
    int iReturnThis = TRUE;
    int iStart;
    int iEnd;
    string sStartPoint;
    string sEndPoint;
    string sBaseTag = sThisShape + "OBJ";
    object oStartPoint;
    object oEndPoint;

    if (oTarget == OBJECT_INVALID || sShapeName == "" || sConnectionList == "")
        return FALSE;

    //TODO Grab from list instead of parsing.
    int i, nCount = CountList(sConnectList);

    if (nCount < 2)
        return FALSE;
    
    nStart = StringToInt(GetListItem(sConnectionList, i));
    nEnd = StringToInt(GetListItem(sConnectionList, i + 1));

    if(sStartPoint == "-1" || sEndPoint == "" || sEndPoint == "-1")
        return FALSE;


    oStartPoint = GetObjectByTag(sBaseTag + sStartPoint);
    oEndPoint = GetObjectByTag(sBaseTag + sEndPoint);

    //TODO work from here.  Need loop above.

    while (TRUE)
    {
        AssignCommand(oStartPoint, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(ciThisBeamVFX, oStartPoint, BODY_NODE_CHEST), oEndPoint));

        if(sConnectionList == "")
            break;

        oStartPoint = oEndPoint;

        sEndPoint = GetStringLeft(sConnectionList, 2);
        sConnectionList = GetStringRight(sConnectionList, GetStringLength(sConnectionList) - 2);

        if(sEndPoint == "-1")
        {
            sStartPoint = GetStringLeft(sConnectionList, 2);
            sConnectionList = GetStringRight(sConnectionList, GetStringLength(sConnectionList) - 2);

            sEndPoint = GetStringLeft(sConnectionList, 2);
            sConnectionList = GetStringRight(sConnectionList, GetStringLength(sConnectionList) - 2);

            oStartPoint = GetObjectByTag(sBaseTag + sStartPoint);
            oEndPoint = GetObjectByTag(sBaseTag + sEndPoint);
        }
        else if(sEndPoint == "")
            break;
        else
            oEndPoint = GetObjectByTag(sBaseTag + sEndPoint);
    }

    return iReturnThis;
}

//RedrawConnected
int RedrawOrderedShape(object oTarget, string sShapeName, string sConnectionList, string sPlaceable = "plc_invisobj")
{
    if (RedrawNodes(oTarget, sShapeName, sPlaceable))
        return DrawOrderedShape(oTarget, sShapeName, sConnectionList);
    else
        return FALSE;
}
