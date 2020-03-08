// Get correct ramp texture and contrast, intensity and saturation based on the ramp mask texture
void GetToonVars(inout float IntensityVar, inout float SaturationVar, inout float ToonContrastVar, inout float ToonRampOffsetVar, inout sampler2D RampTex)
{
    #if defined(_RAMPMASK_ON)
        float4 maskColor = tex2D(_RampMaskTex, i.uv);
        
        if(maskColor.r > 0.5)
        {
            IntensityVar = _IntensityR;
            SaturationVar = _SaturationR;
            ToonContrastVar = _ToonContrastR;
            ToonRampOffsetVar = _ToonRampOffsetR;
            RampTex = _RampR;
        }
        else if(maskColor.g > 0.5)
        {
            IntensityVar = _IntensityG;
            SaturationVar = _SaturationG;
            ToonContrastVar = _ToonContrastG;
            ToonRampOffsetVar = _ToonRampOffsetG;
            RampTex = _RampG;
        }
        else if(maskColor.b > 0.5)
        {
            IntensityVar = _IntensityB;
            SaturationVar = _SaturationB;
            ToonContrastVar = _ToonContrastB;
            ToonRampOffsetVar = _ToonRampOffsetB;
            RampTex = _RampB;
        }
        else
        {
            IntensityVar = _Intensity;
            SaturationVar = _Saturation;
            ToonContrastVar = _ToonContrast;
            ToonRampOffsetVar = _ToonRampOffset;
            RampTex = _Ramp;
        }
    #else
        IntensityVar = _Intensity;
        SaturationVar = _Saturation;
        ToonContrastVar = _ToonContrast;
        ToonRampOffsetVar = _ToonRampOffset;
        RampTex = _Ramp;
    #endif
}