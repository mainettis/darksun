// -----------------------------------------------------------------------------
//    File: util_i_math.nss
//  System: Utilities
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This file contains useful math utility functions. Note than some of the float
// functions (notably fmod) may be slightly off (+/- a millionth) due to the
// nature of floating point arithmetic.
// -----------------------------------------------------------------------------

#include "util_i_math"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< round >---
// ---< dsutil_i_math >---
// Rounds fValue to nPrecision decimal places.
int round(float fValue, nPrecision = 2);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

float round(float fValue, nPrecision = 2) 
{
    nPrecision = 10 ^ nPrecision;
    return IntToFloat(FloatToInt(fValue * nPrecision + 0.5f)) / nPrecision;
} 
