//********************************************************* 
// 
// Copyright (c) Microsoft. All rights reserved. 
// This code is licensed under the MIT License (MIT). 
// THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF 
// ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY 
// IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR 
// PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT. 
// 
//*********************************************************

// Change file names
// change every mention in class of MaxLuminanceEffect
// Create new GUID
// in renderer add new switch statement
// expose it in UI (look at SDR overlay effect, in XAML or UI code)
// import to Simon's app or publish? 


// Custom effects using pixel shaders should use HLSL helper functions defined in
// d2d1effecthelpers.hlsli to make use of effect shader linking.
#define D2D_INPUT_COUNT 1           // The pixel shader takes exactly 1 input.

// Note that the custom build step must provide the correct path to find d2d1effecthelpers.hlsli when calling fxc.exe.
#include "d2d1effecthelpers.hlsli"

cbuffer constants : register(b0)
{
    float dpi : packoffset(c0.x); // Ignored - there is no position-dependent behavior in the shader.
    float maxLuminance : packoffset(c0.y);
};

D2D_PS_ENTRY(main)
{
    float magicConstant = maxLuminance;
    float4 output = D2DGetInput(0);

    // Calculate luminance in nits
    float nits = dot(float3(0.2126f, 0.7152f, 0.0722f), output.rgb) * 80.0f;

    // Detect if luminance is outside the max luminance of display
    float isOutsideMaxLum = step(magicConstant - nits, nits - magicConstant); // 1 = out, 0 = in, inclusive of magicConstant
    float isInsideMaxLum = 1 - isOutsideMaxLum;

    float4 outsideMaxLumColor = float4(0.0f, 0.0f, 0.0f, 1.0f); // outside range is black
    //float4 outsideMaxLumColor = float4(1.0f, 0.0f, 1.0f, 1.0f); // outside range is magenta
    //float lum = dot(float3(0.3f, 0.59f, 0.11f), output.rgb);
    //float4 outsideMaxLumColor = float4(lum, lum, lum, 1.0f); // outside range is grayscale, this operation isn't very noticable
    //float4 outsideMaxLumColor = float4(1.0f, 1.0f, 1.0f, 0.0f) - saturate(output); // outside range is inverted colors, if in HDR range it clamps to it to an SDR range and then inverts 

    float4 insideMaxLumColor = float4(output.rgb, 1.0f);

    return isInsideMaxLum * insideMaxLumColor + isOutsideMaxLum * outsideMaxLumColor;


    //// Detect if any color component is outside of [0, 1] SDR numeric range.
    //float4 isOutsideSdrVec = abs(sign(output - saturate(output)));
    //float isOutsideSdr = max(max(isOutsideSdrVec.r, isOutsideSdrVec.g), isOutsideSdrVec.b); // 1 = out, 0 = in
    //float isInsideSdr = 1 - isOutsideSdr;                                                   // 0 = out, 1 = in



    //// Convert all sRGB/SDR colors to grayscale.
    //float lum = dot(float3(0.3f, 0.59f, 0.11f), output.rgb);
    //float4 insideSdrColor = float4(lum, lum, lum, 1.0f);

    //// Pass through wide gamut and high dynamic range colors.
    //float4 outsideSdrColor = float4(output.rgb, 1.0f);

    //return insideSdrColor * isInsideSdr + outsideSdrColor * isOutsideSdr;
}