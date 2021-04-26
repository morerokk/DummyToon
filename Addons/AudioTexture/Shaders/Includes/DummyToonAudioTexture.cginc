#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)

UNITY_DECLARE_TEX2D_NOSAMPLER(_AudioTexture);
uniform float4 _AudioTexture_ST;
SamplerState sampler_point_repeat;
bool AudioTextureExists()
{
    float w; 
    float h; 
    float res = 0;
    _AudioTexture.GetDimensions(w, h);
    return w == 32;
}

sampler2D _AudioTextureMask;
float4 _AudioTextureSampleLocation;

float4 fragAudio(v2f i, bool facing : SV_IsFrontFace) : SV_Target
{
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

    // Sample main texture
    #ifdef OUTLINE_PASS
        float4 mainTex = tex2D(_OutlineTex, i.uv.xy);
        mainTex *= _OutlineColor;
    #else
        float4 mainTex = tex2D(_MainTex, i.uv.xy);
        mainTex *= _Color;
    #endif
    
    // Alpha to coverage
    #if defined(_ALPHATOCOVERAGE_ON) && !defined(NO_DERIVATIVES)
        mainTex.a = (mainTex.a - _Cutoff) / max(fwidth(mainTex.a), 0.00001) + 0.5;
    #endif
    
    // Cutout
    #if defined(_ALPHATEST_ON)
        clip(mainTex.a - _Cutoff);
    #endif
    
    // Hue shift
    #if defined(_HUESHIFT_ON)
        ApplyHueShift(i.uv.xy, mainTex.rgb);
    #endif
    
    // Audio texture stuff
    // Does the audio texture exist?
    UNITY_BRANCH
    if(AudioTextureExists())
    {
        float4 audioMaskTex = tex2D(_AudioTextureMask, i.uv.xy);

        float4 audioTex = SAMPLE_TEXTURE2D(_AudioTexture, sampler_point_repeat, _AudioTextureSampleLocation.xy);

        float3 modifiedRGB = mainTex.rgb * audioTex.rgb;
        mainTex.rgb = lerp(mainTex.rgb, modifiedRGB, audioMaskTex.rgb);
    }

    // Get all vars related to toon ramping
    float IntensityVar;
    float SaturationVar;
    float ToonContrastVar;
    float ToonRampOffsetVar;
    float4 ToonRampMaskColor;
    GetToonVars(i.uv.xy, IntensityVar, SaturationVar, ToonContrastVar, ToonRampOffsetVar, ToonRampMaskColor);
    
    // Obtain albedo from main texture and multiply by intensity
    float3 albedo = mainTex.rgb * IntensityVar;
    
    // Apply saturation modifier
    float lum = Luminance(albedo);
    albedo = lerp(float3(lum, lum, lum), albedo, SaturationVar);

    // Get normal direction from vertex normals (and normal maps if applicable)
    float3 normalDir = NormalDirection(i);

    // If this is a backface, reverse the normal direction
    #ifndef NO_ISFRONTFACE
        float faceSign = facing ? 1 : -1;
        normalDir *= faceSign;
    #endif
    
    // Matcap
    #if defined(_MATCAP_ON)
        // Matcap origin
        // If 0, viewdir to surface is used
        // If 1, viewdir to object center is used
        float3 matcapViewDir;
        if (_MatCapOrigin == 1)
        {
            matcapViewDir = normalize(_WorldSpaceCameraPos.xyz - i.objWorldPos.xyz);
        }
        else
        {
            matcapViewDir = viewDir;
        }
        Matcap(matcapViewDir, normalDir, i.uv.xy, albedo);
    #endif
    
    // Rimlight
    #if defined(_RIMLIGHT_ADD) || defined(_RIMLIGHT_MIX)
        Rimlight(i.uv.xy, viewDir, normalDir, albedo);
    #endif
    
    // Lighting
    
    // Get light attenuation
    UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);
    
    float3 lightDirection;
    float3 lightColor;
    
    // Fill the finalcolor with indirect light data (SH and vertex lights)
    float3 finalColor = IndirectToonLighting(albedo, normalDir, i.worldPos.xyz);
    
    #ifdef UNITY_PASS_FORWARDBASE
        // Run the lighting function with non-realtime data first       
        GetBaseLightData(lightDirection, lightColor);
        
        // If the ambient light direction is too close to the actual realtime directional light direction (happens with mixed lights),
        // the direction will be smoothly merged.
        // This makes the lighting look better with sharp toon ramps.
        #if !defined(_OVERRIDEWORLDLIGHTDIR_ON)
            if(any(_WorldSpaceLightPos0))
            {
                SmoothBaseLightData(lightDirection);
            }
        #endif
        
        finalColor += ToonLightingBase(albedo, normalDir, lightDirection, lightColor, ToonRampMaskColor, ToonContrastVar, ToonRampOffsetVar) * _IndirectLightBoost;
    #endif
    
    // Fill lightDirection and lightColor with current light data
    GetLightData(i.worldPos.xyz, lightDirection, lightColor);
    
    // Apply current light
    // If the current light is black, it will have no effect. Skip it to save on calculations and texture samples.
    #ifdef UNITY_PASS_FORWARDBASE
        UNITY_BRANCH
        if(any(_LightColor0.rgb))
        {
            finalColor += ToonLighting(albedo, normalDir, lightDirection, lightColor, ToonRampMaskColor, ToonContrastVar, ToonRampOffsetVar) * attenuation * _DirectLightBoost;
        }
    #else
        finalColor += ToonLighting(albedo, normalDir, lightDirection, lightColor, ToonRampMaskColor, ToonContrastVar, ToonRampOffsetVar) * attenuation * _DirectLightBoost;
    #endif
    
    // Apply metallic
    #if defined(_METALLICGLOSSMAP) || defined(_SPECGLOSSMAP)
        MetallicSpecularGloss(i.worldPos.xyz, i.uv.xy, normalDir, albedo, finalColor);
    #endif
    
    // Apply emission
    #if defined(UNITY_PASS_FORWARDBASE) && defined(_EMISSION)
        float4 emissive = tex2D(_EmissionMap, i.uv.xy);
        emissive *= _EmissionColor;
        
        UNITY_BRANCH
        if(_EmissionMapIsTint == 1)
        {
            emissive.rgb *= mainTex.rgb;
        }
        
        finalColor += emissive.rgb;
    #endif
    
    #if defined(_ALPHABLEND_ON) || defined(_ALPHATOCOVERAGE_ON)
        float finalAlpha = mainTex.a;
    #else
        float finalAlpha = 1;
    #endif

    float4 finalOutput = float4(finalColor, finalAlpha);
    UNITY_APPLY_FOG(i.fogCoord, finalOutput);

    return finalOutput;
}
