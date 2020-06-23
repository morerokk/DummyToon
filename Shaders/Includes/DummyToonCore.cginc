#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

float _Cutoff;

#if defined(_NORMALMAP)
    sampler2D _BumpMap;
    float4 _BumpMap_ST;
    float _BumpScale;
#endif

#if defined(_DETAILNORMAL_UV0) || defined(_DETAILNORMAL_UV1)
    #define DETAILNORMALMAP

    sampler2D _DetailNormalMap;
    float4 _DetailNormalMap_ST;
    float _DetailNormalMapScale;
#endif

sampler2D _Ramp;
float4 _Ramp_TexelSize;
float _ToonContrast;
float _ToonRampOffset;
float3 _StaticToonLight;

float _Intensity;
float _Saturation;

float _DirectLightBoost;
float _IndirectLightBoost;

float _IndirectLightDirMergeMin;
float _IndirectLightDirMergeMax;

#if defined(_RAMPMASK_ON)
    sampler2D _RampMaskTex;

    sampler2D _RampR;
    float4 _RampR_TexelSize;
    float _ToonContrastR;
    float _ToonRampOffsetR;
    float _IntensityR;
    float _SaturationR;
    
    sampler2D _RampG;
    float4 _RampG_TexelSize;
    float _ToonContrastG;
    float _ToonRampOffsetG;
    float _IntensityG;
    float _SaturationG;
    
    sampler2D _RampB;
    float4 _RampB_TexelSize;
    float _ToonContrastB;
    float _ToonRampOffsetB;
    float _IntensityB;
    float _SaturationB;
#endif

#if defined(_ADDITIVERAMP_FORWARDADD_ONLY) || defined(_ADDITIVERAMP_ALWAYS)
    sampler2D _AdditiveRamp;
    float4 _AdditiveRamp_TexelSize;
#endif

#if defined(_METALLICGLOSSMAP)
    sampler2D _MetallicGlossMap;
#endif

float _Metallic;
float _Glossiness;

#if defined(_SPECGLOSSMAP)
    // _SpecColor is already defined somewhere
    //float4 _SpecColor;
    sampler2D _SpecGlossMap;
#endif

#if defined(_EMISSION)
    sampler2D _EmissionMap;
    float4 _EmissionColor;

    float _EmissionMapIsTint;
#endif

#if defined(_MATCAP_ADD) || defined(_MATCAP_MULTIPLY)
    sampler2D _MatCap;
    float _MatCapStrength;
#endif

#if defined(_RIMLIGHT_ADD) || defined(_RIMLIGHT_MIX)
    sampler2D _RimTex;
    float4 _RimLightColor;
    float _RimLightMode;
    float _RimWidth;
    float _RimInvert;
#endif

#ifdef OUTLINE_PASS
    uniform sampler2D _OutlineTex;
    uniform float4 _OutlineTex_ST;
    uniform float _OutlineWidth;
    uniform float4 _OutlineColor;

    uniform float _ScreenSpaceMinDist;
    uniform float _ScreenSpaceMaxDist;
#else
    sampler2D _MainTex;
    float4 _Color;
#endif

// Most textures reuse the tiling and offset values of the main texture, so this should always be available
float4 _MainTex_ST;

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
    #if defined(_DETAILNORMAL_UV1)
        float2 uv1 : TEXCOORD1;
    #endif
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 pos : SV_POSITION;
    float3 normalDir : TEXCOORD1;
    float3 tangentDir : TEXCOORD2;
    float3 bitangentDir : TEXCOORD3;
    float4 worldPos : TEXCOORD4;
    SHADOW_COORDS(5)
    #if defined(_DETAILNORMAL_UV1)
        float2 uv1 : TEXCOORD6;
    #endif
};

#include "DummyToonLighting.cginc"
#include "DummyToonRamping.cginc"

#if defined(_METALLICGLOSSMAP) || defined(_SPECGLOSSMAP)
    #include "DummyToonMetallicSpecular.cginc"
#endif

#if defined(_MATCAP_ADD) || defined(_MATCAP_MULTIPLY)
    #include "DummyToonMatcap.cginc"
#endif

#if defined(_RIMLIGHT_ADD) || defined(_RIMLIGHT_MIX)
    #include "DummyToonRimlight.cginc"
#endif

float3 NormalDirection(v2f i)
{
    float3 normalDir = normalize(i.normalDir);
    
    // Perturb normals with a normal map
    #if defined(_NORMALMAP) && defined(DETAILNORMALMAP) // Both normal and detail normal
        float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
        
        float3 bumpTex = UnpackScaleNormal(tex2D(_BumpMap, i.uv), _BumpScale);
        
        // Choose the correct UV map set
        #if defined(_DETAILNORMAL_UV0)
            // Sample the detail normal using UV0, and re-apply the tiling. This may result in stacked tiling if the main texture is also transformed.
            float3 detailBumpTex = UnpackScaleNormal(tex2D(_DetailNormalMap,TRANSFORM_TEX(i.uv, _DetailNormalMap)), _DetailNormalMapScale);
        #else
            // Sample the detail normal with UV1
            float3 detailBumpTex = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv1), _DetailNormalMapScale);
        #endif
        
        float3 normalLocal = BlendNormals(bumpTex, detailBumpTex);
        normalDir = normalize(mul(normalLocal, tangentTransform));  
    #elif defined(_NORMALMAP) // Only normal
        float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
        float3 bumpTex = UnpackScaleNormal(tex2D(_BumpMap, i.uv), _BumpScale);
        float3 normalLocal = bumpTex.rgb;
        normalDir = normalize(mul(normalLocal, tangentTransform));  
    #elif defined(DETAILNORMALMAP) // Only detail normal
        float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
        
        // Choose the correct UV map set
        #if defined(_DETAILNORMAL_UV0)
            // Sample the detail normal, and re-apply the tiling. This may result in stacked tiling if the main texture is also transformed.
            float3 bumpTex = UnpackScaleNormal(tex2D(_DetailNormalMap,TRANSFORM_TEX(i.uv, _DetailNormalMap)), _DetailNormalMapScale);
        #else
            float3 bumpTex = UnpackScaleNormal(tex2D(_DetailNormalMap, i.uv1), _DetailNormalMapScale);
        #endif
        
        float3 normalLocal = bumpTex.rgb;
        normalDir = normalize(mul(normalLocal, tangentTransform));  
    #endif
    
    return normalDir;
}

// Prevent name conflict in outline pass
#ifndef OUTLINE_PASS
    v2f vert (appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.normalDir = UnityObjectToWorldNormal(v.normal);
        o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
        o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex);
        TRANSFER_SHADOW(o);
        
        #if defined(_DETAILNORMAL_UV1)
            o.uv1 = TRANSFORM_TEX(v.uv1, _DetailNormalMap);
        #endif
        
        return o;
    }
#endif

float4 frag (v2f i) : SV_Target
{
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

    // Sample main texture
    #ifdef OUTLINE_PASS
        float4 mainTex = tex2D(_OutlineTex, i.uv);
        mainTex *= _OutlineColor;
    #else
        float4 mainTex = tex2D(_MainTex, i.uv);
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

    // Get all vars related to toon ramping
    float IntensityVar;
    float SaturationVar;
    float ToonContrastVar;
    float ToonRampOffsetVar;
    float4 ToonRampMaskColor;
    GetToonVars(i.uv, IntensityVar, SaturationVar, ToonContrastVar, ToonRampOffsetVar, ToonRampMaskColor);
    
    // Obtain albedo from main texture and multiply by intensity
    float3 albedo = mainTex.rgb * IntensityVar;
    
    // Apply saturation modifier
    float lum = Luminance(albedo);
    albedo = lerp(float3(lum, lum, lum), albedo, SaturationVar);

    // Get normal direction from vertex normals (and normal maps if applicable)
    float3 normalDir = NormalDirection(i);
    
    // Matcap
    #if defined(_MATCAP_ADD) || defined(_MATCAP_MULTIPLY)
        Matcap(viewDir, normalDir, albedo);
    #endif
    
    // Rimlight
    #if defined(_RIMLIGHT_ADD) || defined(_RIMLIGHT_MIX)
        Rimlight(i.uv, viewDir, normalDir, albedo);
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
        MetallicSpecularGloss(i.worldPos.xyz, i.uv, normalDir, albedo, finalColor);
    #endif
    
    // Apply emission
    #if defined(UNITY_PASS_FORWARDBASE) && defined(_EMISSION)
        float4 emissive = tex2D(_EmissionMap, i.uv);
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

    return float4(finalColor, finalAlpha);
}