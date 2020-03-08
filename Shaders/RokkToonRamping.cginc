// Get correct ramp texture and contrast, intensity and saturation based on the ramp mask texture
void GetToonVars(float2 uv, inout float IntensityVar, inout float SaturationVar, inout float ToonContrastVar, inout float ToonRampOffsetVar, inout float4 ToonRampMaskColor)
{
    #if defined(_RAMPMASK_ON)
        ToonRampMaskColor = tex2D(_RampMaskTex, uv);
        
        if(ToonRampMaskColor.r > 0.5)
        {
            IntensityVar = _IntensityR;
            SaturationVar = _SaturationR;
            ToonContrastVar = _ToonContrastR;
            ToonRampOffsetVar = _ToonRampOffsetR;
        }
        else if(ToonRampMaskColor.g > 0.5)
        {
            IntensityVar = _IntensityG;
            SaturationVar = _SaturationG;
            ToonContrastVar = _ToonContrastG;
            ToonRampOffsetVar = _ToonRampOffsetG;
        }
        else if(ToonRampMaskColor.b > 0.5)
        {
            IntensityVar = _IntensityB;
            SaturationVar = _SaturationB;
            ToonContrastVar = _ToonContrastB;
            ToonRampOffsetVar = _ToonRampOffsetB;
        }
        else
        {
            IntensityVar = _Intensity;
            SaturationVar = _Saturation;
            ToonContrastVar = _ToonContrast;
            ToonRampOffsetVar = _ToonRampOffset;
        }
    #else
        IntensityVar = _Intensity;
        SaturationVar = _Saturation;
        ToonContrastVar = _ToonContrast;
        ToonRampOffsetVar = _ToonRampOffset;
        ToonRampMaskColor = float4(0,0,0,0);
    #endif
}