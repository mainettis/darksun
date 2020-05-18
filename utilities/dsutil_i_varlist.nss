// -----------------------------------------------------------------------------
//    File: dsutil_i_varlist.nss
//  System: Utilities (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file holds utility functions for manipulating local variable lists.
// Because these lists are zero-indexed and maintain a count of their length,
// they can be used to approximate arrays.
//
// Local variable lists are specific to a variable type: string lists and int
// lists can be maintained separately even when you give them the same name.
// This is because the variables are saved in a table with VarNames in the
// format Ref:<varname><index>. Each list maintains its own count in the format
// <type>:<varname>, where <type> is one of the following:
//   VC: Vector Count
// You should not manipulate these variables directly. Rather, use the *List*()
// functions contained in this library.
// -----------------------------------------------------------------------------
// Acknowledgements: these functions are adapted from those in Memetic AI.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

#include "util_i_varlists"
#include "dsutil_i_data"

// Prefixes used to keep list variables from colliding with other locals.
const string LIST_COUNT_VECTOR   = "VC:";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< AddListVector >---
// ---< util_i_varlists >---
// Adds vValue to a vector list on oTarget given the list name sListName. If
// bAddUnique is TRUE, this only adds to the list if it is not already there.
// Returns whether the addition was successful.
int AddListVector(object oTarget, vector vValue, string sListName = "", int bAddUnique = FALSE);

// ---< SetListVector >---
// ---< util_i_varlists >---
// Sets item nIndex in the vector list of sListName on oTarget to vValue. If the
// index is at the end of the list, it will be added. If it exceeds the length
// of the list, nothing is added.
void SetListVector(object oTarget, int nIndex, vector vValue, string sListName = "");

// ---< GetListVector >---
// ---< util_i_varlists >---
// Returns the vector at nIndex in oTarget's vector list sListName. If no vector is
// found at that index, 0.0 is returned.
vector GetListVector(object oTarget, int nIndex = 0, string sListName = "");

// ---< DeleteListVector >---
// ---< util_i_varlists >---
// Removes the vector at nIndex on oTarget's vector list sListName and returns the
// number of items remaining in the list. If bMaintainOrder is TRUE, this will
// shift up all entries after nIndex in the list. If FALSE, it will replace the
// removed item with the last entry in the list. If the order of items in the
// list doesn't matter, this will save a lot of cycles.
int DeleteListVector(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

// ---< RemoveListVector >---
// ---< util_i_varlists >---
// Removes a vector of vValue from the vector list sListName on oTarget and
// returns the number of items remaining in the list. If this vector was added
// more than once, only the first reference is removed. If bMaintainOrder is
// TRUE, this will his shift up all entries after nIndex in the list. If FALSE,
// it will replace the removed item with the last entry in the list. If the
// order of items in the list doesn't matter, this will save a lot of cycles.
int RemoveListVector(object oTarget, vector vValue, string sListName = "", int bMaintainOrder = FALSE);

// ---< FindListVector >---
// ---< util_i_varlists >---
// Returns the index of the first reference of the vector vValue in the vector
// list sListName on oTarget. If it is not in the list, returns -1.
int FindListVector(object oTarget, vector vValue, string sListName = "");

// ---< HasListVector >---
// ---< util_i_varlists >---
// Returns whether oTarget has a vector with the value vValue in its vector list
// sListName.
int HasListVector(object oTarget, vector vValue, string sListName = "");

// ---< DeleteVectorList >---
// ---< util_i_varlists >---
// Deletes the vector list sListName from oTarget.
void DeleteVectorList(object oTarget, string sListName = "");

// ---< DeclareVectorList >---
// ---< util_i_varlists >---
// Creates a vector list of sListName on oTarget with nCount null items. If
// oTarget already had a list with this name, that list is deleted before the
// new one is created.
void DeclareVectorList(object oTarget, int nCount, string sListName = "");

// ---< CopyVectorList >---
// ---< util_i_varlists >---
// Copies the vector list sSourceName from oSource to oTarget, renamed
// sTargetName. If bAddUnique is TRUE, will only copy items from the source list
// that are not already present in the target list.
void CopyVectorList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

// ---< CountVectorList >---
// ---< util_i_varlists >---
// Returns the number of items in oTarget's vector list sListName.
int CountVectorList(object oTarget, string sListName = "");

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

int AddListVector(object oTarget, vector vValue, string sListName = "", int bAddUnique = FALSE)
{
    int nCount = CountVectorList(oTarget, sListName);

    // If we're adding unique we should check to see if this entry already exists
    if (bAddUnique)
    {
        int i;
        for (i = nCount-1; i >= 0; i--)
        {
            float fX = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(i) + "X");
            float fY = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(i) + "Y");
            float fZ = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(i) + "Z");
            
            if (vValue.x == fX && vValue.y == fY && vValue.z == fZ)
                return FALSE;
        }
    }

    _SetLocalFloat(oTarget, LIST_REF          + sListName + IntToString(nCount) + "X", vVector.x);
    _SetLocalFloat(oTarget, LIST_REF          + sListName + IntToString(nCount) + "Y", vVector.y);
    _SetLocalFloat(oTarget, LIST_REF          + sListName + IntToString(nCount) + "Z", vVector.z);
    _SetLocalInt  (oTarget, LIST_COUNT_VECTOR + sListName, nCount + 1);
    return TRUE;
}

vector GetListVector(oTarget, int nIndex = 0, string sListName = "")
{
    int nCount = CountVectorList(oTarget, sListName);
    if (nIndex >= nCount) return Vector(0.0, 0.0, 0.0);
    
    float fX = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(nIndex) + "X");
    float fY = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(nIndex) + "Y");
    float fZ = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(nIndex) + "Z");

    return Vector(fX, fY, fZ);
}

int DeleteListVector(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    int nCount = CountFloatList(oTarget, sListName);

    if (nCount == 0 || nIndex >= nCount || nIndex < 0) return nCount;

    float fRefX, fRefY, fRefZ;
    if (bMaintainOrder)
    {
        // Shift all entries up
        for (nIndex; nIndex < nCount; nIndex++)
        {
            fRefX = _GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex + 1) + "X");
                    _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex)     + "X", fRefX);
            fRefY = _GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex + 1) + "Y");
                    _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex)     + "Y", fRefY);
            fRefZ = _GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex + 1) + "Z");
                    _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex)     + "Z", fRefZ);            
        }
    }
    else
    {
        // Replace this item with the last one in the list
        fRefX = _GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nCount - 1) + "X");
                _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex)     + "X", fRefX);
        fRefY = _GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nCount - 1) + "Y");
                _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex)     + "Y", fRefY);
        fRefZ = _GetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nCount - 1) + "Z");
                _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex)     + "Z", fRefZ);
    }

    // Delete the last item in the list and set the new count
    _DeleteLocalFloat(oTarget, LIST_REF          + sListName + IntToString(--nCount) + "X");
    _DeleteLocalFloat(oTarget, LIST_REF          + sListName + IntToString(--nCount) + "Y");
    _DeleteLocalFloat(oTarget, LIST_REF          + sListName + IntToString(--nCount) + "Z");
    _SetLocalInt     (oTarget, LIST_COUNT_VECTOR + sListName, nCount);

    return nCount;
}

int RemoveListVector(oTarget, vector vValue, string sListName = "", int bMaintainOrder = FALSE)
{
    int nIndex = FindListVector(oTarget, vValue, sListName);
    return DeleteListVector(oTarget, nIndex, sListName, bMaintainOrder);
}

int FindListVector(object oTarget, vector vValue, string sListName = "")
{
    int i, nCount = CountVectorList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
    {
        float fX = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(i) + "X");
        float fY = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(i) + "Y");
        float fZ = _GetLocalFloat(oTarget, LIST_REF + sListName = IntToSTring(i) + "Z");
        
        if (vValue.x == fX && vValue.y == fY && vValue.z == fZ)
            return i;
    }

    return -1; 
}

int HasListVector(object oTarget, vector vValue, string sListName = "")
{
    if (FindListVector(oTarget, vValue, sListName) != -1) return TRUE;
    else                                                  return FALSE;  
}

void SetListVector(object oTarget, int nIndex, vector vValue, string sListName = "")
{
    int nCount = CountVectorList(oTarget, sListName);

    if (nIndex > nCount)
        return;

    if (nIndex == nCount)
        AddListVector(oTarget, vValue, sListName);
    else
    {
        _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex) + "X", vValue.x);
        _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex) + "Y", vValue.y);
        _SetLocalFloat(oTarget, LIST_REF + sListName + IntToString(nIndex) + "Z", vValue.z);
    }
}

void DeleteVectorList(object oTarget, string sListName = "")
{
    int i, nCount = CountFloatList(oTarget, sListName);

    for (i = 0; i < nCount; i++)
    {
        _DeleteLocalFloat(oTarget, LIST_REF + sListName + IntToString(i) + "X");
        _DeleteLocalFloat(oTarget, LIST_REF + sListName + IntToString(i) + "Y");
        _DeleteLocalFloat(oTarget, LIST_REF + sListName + IntToString(i) + "Z");
    }

    _DeleteLocalInt(oTarget, LIST_COUNT_VECTOR + sListName);
}

void DeclareVectorList(object oTarget, int nCount, string sListName = "")
{
    DeleteVectorList(oTarget, sListName);
    _SetLocalInt(oTarget, LIST_COUNT_VECTOR + sListName, nCount);  
}

void CopyVectorList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    vector vValue;
    int  i, nCount = CountVectorList(oSource, sSourceName);

    for (i = 0; i < nCount; i++)
    {
        vValue = GetListVector(oSource, i, sSourceName);
        AddListVector(oTarget, vValue, sTargetName, bAddUnique);
    }   
}

int CountVectorList(object oTarget, string sListName = "")
{
    return _GetLocalInt(oTarget, LIST_COUNT_VECTOR + sListName);
}
