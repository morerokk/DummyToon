#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "UnityPBSLighting.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Color;
float _Cutoff;

#if defined(_NORMALMAP)
    sampler2D _BumpMap;
    float4 _BumpMap_ST;
    float _BumpScale;
#endif

sampler2D _Ramp;
float _ToonContrast;
float _ToonRampOffset;
float3 _StaticToonLight;

float _Intensity;
float _Saturation;

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
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
};

#include "RokkToonLighting.cginc"

float3 NormalDirection(v2f i)
{
    float3 normalDir = normalize(i.normalDir);
    
    // Perturb normals with a normal map
    #if defined(_NORMALMAP)
        float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
        float3 bumpTex = UnpackScaleNormal(tex2D(_BumpMap,TRANSFORM_TEX(i.uv, _BumpMap)), _BumpScale);
        float3 normalLocal = bumpTex.rgb;
        normalDir = normalize(mul(normalLocal, tangentTransform));
    #endif
    
    return normalDir;
}

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
    return o;
}

float4 frag (v2f i) : SV_Target
{
    // sample the texture
    float4 mainTex = tex2D(_MainTex, i.uv);
    mainTex *= _Color;
    
    #if defined(_ALPHATEST_ON)
        clip(mainTex.a - _Cutoff);
    #endif
    
    // Obtain albedo from main texture and multiply by intensity
    float3 albedo = mainTex.rgb * _Intensity;
    float lum = Luminance(albedo);
    albedo = lerp(float3(lum, lum, lum), albedo, _Saturation);

    float3 normalDir = NormalDirection(i);
    
    // Lighting
    UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);
    
    float3 lightDirection;
    float3 lightColor;
    float3 finalColor;
    
    // Fill finalColor with indirect lighting, fill lightDirection and lightColor with current light data
    GetLightData(albedo, normalDir, i.worldPos.xyz, attenuation, finalColor, lightDirection, lightColor);
    
    // Apply current light
    finalColor += ToonLighting(albedo, normalDir, lightDirection, _LightColor0.rgb) * attenuation;

    return float4(finalColor, 1);
}