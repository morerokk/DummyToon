Shader "Dummy Toon/Addons/Toon (Penetration)"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)

        [NoScaleOffset] [Normal] _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Float) = 1.0
        
        [Enum(Opaque,0,Transparent,2)] _Mode ("Rendering Mode", Float) = 0
        
        [Toggle(_ALPHATEST_ON)] _CutoutEnabled ("Cutout", Float) = 0
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        
        [Toggle(_)] _ZWrite ("ZWrite", Float) = 1.0
        [Enum(Both,0,Front,2,Back,1)] _Cull("Sidedness", Float) = 0
        
        [NoScaleOffset] _EmissionMap("Emission Map", 2D) = "white" {}
        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0)
        [Toggle(_)] _EmissionMapIsTint("Emission Map is tint", Float) = 0
        
        // Toon lighting
        [NoScaleOffset] _Ramp ("Toon Ramp", 2D) = "white" {}
        _ToonContrast ("Toon Contrast", Range(0, 1)) = 0.5
        _ToonRampOffset ("Toon Ramp Offset", Range(-2,2)) = 0
        _StaticToonLight ("Fallback Light Direction", Vector) = (0,1,0,0)
        _DirectLightBoost ("Direct Light Boost", Range(0,2)) = 1
        _IndirectLightBoost ("Indirect Light Boost", Range (0,2)) = 1
        [Toggle(_RAMPTINT_ON)] _RampTinting ("Ramp Tinting", Float) = 0
        [Toggle(_RAMPANTIALIASING_ON)] _RampAntiAliasingEnabled ("Ramp Anti-Aliasing", Float) = 0
        [Toggle(_OVERRIDEWORLDLIGHTDIR_ON)] _OverrideWorldLightDir ("Always use fallback", Float) = 0
        [Enum(None,0,Additive Only,1,Always,2)] _AdditiveRampMode ("Additive Ramp Mode", Float) = 0
        [NoScaleOffset] _AdditiveRamp ("Additive Toon Ramp", 2D) = "white" {}
        
        _Intensity ("Intensity", Range(0, 5)) = 1.3
        _Saturation ("Saturation", Range(0, 5)) = 1

        _IndirectLightDirMergeMin ("Indirect Light Direction Merge Minimum", Range(0, 1)) = 0.65
        _IndirectLightDirMergeMax ("Indirect Light Direction Merge Maximum", Range(0, 1)) = 0.75

        // Metallic and specular
        [Enum(None,0,Metallic,1,Specular,2)] _MetallicMode("Metallic Mode", Float) = 0
        [NoScaleOffset] _MetallicGlossMap("Metallic Map", 2D) = "white" {}
        _Metallic("Metallic", Range( 0 , 1)) = 1
        _Glossiness("Smoothness", Range( 0 , 1)) = 1
        [NoScaleOffset] _SpecGlossMap("Specular Map", 2D) = "white" {}
        [HDR] _SpecColor("Specular Color", Color) = (1,1,1,1)
        
        // Toon ramp masking
        [Toggle(_RAMPMASK_ON)] _RampMaskEnabled ("Ramp Masking", Float) = 0
        [NoScaleOffset] _RampMaskTex ("Ramp Mask", 2D) = "black"
        [NoScaleOffset] _RampR ("Ramp (R)", 2D) = "white" {}
        _ToonContrastR ("Toon Contrast (R)", Range(0, 1)) = 0.5
        _ToonRampOffsetR ("Toon Ramp Offset (R)", Range(-2,2)) = 0
        _IntensityR ("Intensity (R)", Range(0, 5)) = 1.3
        _SaturationR ("Saturation (R)", Range(0, 5)) = 1
        [NoScaleOffset] _RampG ("Ramp (G)", 2D) = "white" {}
        _ToonContrastG ("Toon Contrast (G)", Range(0, 1)) = 0.5
        _ToonRampOffsetG ("Toon Ramp Offset (G)", Range(-2,2)) = 0
        _IntensityG ("Intensity (G)", Range(0, 5)) = 1.3
        _SaturationG ("Saturation (G)", Range(0, 5)) = 1
        [NoScaleOffset] _RampB ("Ramp (B)", 2D) = "white" {}
        _ToonContrastB ("Toon Contrast (B)", Range(0, 1)) = 0.5
        _ToonRampOffsetB ("Toon Ramp Offset (B)", Range(-2,2)) = 0
        _IntensityB ("Intensity (B)", Range(0, 5)) = 1.3
        _SaturationB ("Saturation (B)", Range(0, 5)) = 1
        
        // Rimlight
        [Enum(Off,0,Add,1,Mix,2)] _RimLightMode ("Rimlight Mode", Float) = 0
        [HDR] _RimLightColor ("Rimlight Tint", Color) = (1,1,1,0.4)
        [NoScaleOffset] _RimTex ("Rimlight Texture", 2D) = "white" {}
        _RimWidth ("Rimlight Width", Range(0,1)) = 0.75
        [Toggle(_)] _RimInvert ("Invert Rimlight", Float) = 0
        
        // Matcap
        [NoScaleOffset] _MatCap ("Matcap Texture", 2D) = "white" {}
        [Enum(Off,0,Additive (spa),1,Multiply (sph),2)] _MatCapMode ("Matcap Mode", Float) = 0
        _MatCapStrength ("Matcap Strength", Range(0, 1)) = 1
        _MatCapColor ("Matcap Color Tint", Color) = (1,1,1,1)
        _MatCapTintTex ("Matcap Color Texture", 2D) = "white" {}
        [Enum(Surface,0,Object,1)] _MatCapOrigin("Matcap Origin", Float) = 0
        
        // Alpha to coverage
        [Toggle(_ALPHATOCOVERAGE_ON)] _AlphaToCoverage ("Alpha To Coverage", Float) = 0
        
        // Detail normal
        [Normal] _DetailNormalMap ("Detail Normal Map", 2D) = "bump" {}
        _DetailNormalMapScale ("Detail Normal Scale", Float) = 1.0
        [Enum(UV0,0,UV1,1)] _UVSec ("UV Map for detail normals", Float) = 0

        // Stencils
        [IntRange] _StencilRef ("Stencil Value", Range(0, 255)) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp ("Pass Op", Float) = 0 // Keep
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFailOp ("Fail Op", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp ("ZFail Op", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompareFunction ("Compare Function", Float) = 8 // Always

        // ZTest
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4 // LEqual

        // Vertex Offset
        [Toggle(_VERTEXOFFSET_ON)] _VertexOffsetEnabled ("Enable Vertex Offset", Float) = 0
        _VertexOffsetPos ("Local Position Offset", Vector) = (0,0,0,0)
        _VertexOffsetRot ("Rotation", Vector) = (0,0,0,0)
        _VertexOffsetScale ("Scale", Vector) = (1,1,1,0)
        _VertexOffsetPosWorld ("World Position Offset", Vector) = (0,0,0,0)
        
        // Hue Shift
        [Toggle(_HUESHIFT_ON)] _HueShiftEnabled ("Enable Hue Shift", Float) = 0
        _HueShiftAmount ("Hue Shift Amount", Range(0,1)) = 0
        _HueShiftMask ("Hue Shift Mask", 2D) = "white" {}
        _HueShiftAmountOverTime ("Hue Shift Amount Over Time", Float) = 0
        
        // Penetration
        [Header(Penetration Entry Deformation)]_squeeze("Squeeze Minimum Size", Range( 0 , 0.2)) = 0
        _SqueezeDist("Squeeze Smoothness", Range( 0 , 0.1)) = 0
        _BulgePower("Bulge Amount", Range( 0 , 0.01)) = 0
        _BulgeOffset("Bulge Length", Range( 0 , 0.3)) = 0
        _Length("Length of Penetrator Model", Range( 0 , 3)) = 0
        [Header(Alignment Adjustment)]_EntranceStiffness("Entrance Stiffness", Range( 0.01 , 1)) = 0.01
        [Header(Resting Curvature)]_Curvature("Curvature", Range( -1 , 1)) = 0
        _ReCurvature("ReCurvature", Range( -1 , 1)) = 0
        [Header(Movement)]_Wriggle("Wriggle Amount", Range( 0 , 1)) = 0
        _WriggleSpeed("Wriggle Speed", Range( 0.1 , 30)) = 0.28
        
        // Kaj shader optimizer
        [ShaderOptimizerLockButton] _ShaderOptimized ("", Int) = 0
        
        // Internal blend mode properties
        //[HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode"="ForwardBase" }
            
            Stencil {
                Ref [_StencilRef]
                Comp [_StencilCompareFunction]
                Pass [_StencilPassOp]
                Fail [_StencilFailOp]
                ZFail [_StencilZFailOp]
            }
            
            Cull [_Cull]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Blend [_SrcBlend] [_DstBlend]
            
            AlphaToMask [_AlphaToCoverage]
        
            CGPROGRAM
            #pragma vertex vert_penetration
            #pragma fragment frag
            
            #pragma target 5.0

            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma multi_compile _ VERTEXLIGHT_ON
            
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _ALPHABLEND_ON
            #pragma shader_feature_local _ALPHATOCOVERAGE_ON
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _EMISSION
            #pragma shader_feature_local _RAMPMASK_ON
            #pragma shader_feature_local _RAMPTINT_ON
            #pragma shader_feature_local _RAMPANTIALIASING_ON
            #pragma shader_feature_local _OVERRIDEWORLDLIGHTDIR_ON
            #pragma shader_feature_local _MATCAPTINTTEX_ON
            #pragma shader_feature_local _VERTEXOFFSET_ON
            #pragma shader_feature_local _HUESHIFT_ON

            #pragma shader_feature_local _ _DETAILNORMAL_UV0 _DETAILNORMAL_UV1
            #pragma shader_feature_local _ _METALLICGLOSSMAP _SPECGLOSSMAP
            #pragma shader_feature_local _MATCAP_ON
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _ADDITIVERAMP_FORWARDADD_ONLY _ADDITIVERAMP_ALWAYS
            
            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif

            #include "../../../Shaders/Includes/DummyToonCore.cginc"

            uniform float _SqueezeDist;
            uniform float _Length;
            uniform float _Wriggle;
            uniform float _BulgePower;
            uniform float _BulgeOffset;
            uniform float _WriggleSpeed;
            uniform float _ReCurvature;
            uniform float _Curvature;
            uniform float _squeeze;
            uniform float _EntranceStiffness;
            uniform float _OrificeChannel;
            
            void GetBestLights( float Channel, inout int orificeType, inout float3 orificePositionTracker, inout float3 orificeNormalTracker, inout float3 penetratorPositionTracker, inout float penetratorLength ) {
                float ID = step( 0.5 , Channel );
                float baseID = ( ID * 0.02 );
                float holeID = ( baseID + 0.01 );
                float ringID = ( baseID + 0.02 );
                float normalID = ( 0.05 + ( ID * 0.01 ) );
                float penetratorID = ( 0.09 + ( ID * -0.01 ) );
                float4 orificeWorld;
                float4 orificeNormalWorld;
                float4 penetratorWorld;
                float penetratorDist=100;
                for (int i=0;i<4;i++) {
                    float range = (0.005 * sqrt(1000000 - unity_4LightAtten0[i])) / sqrt(unity_4LightAtten0[i]);
                    if (length(unity_LightColor[i].rgb) < 0.01) {
                        if (abs(fmod(range,0.1)-holeID)<0.005) {
                            orificeType=0;
                            orificeWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
                            orificePositionTracker = mul( unity_WorldToObject, orificeWorld ).xyz;
                        }
                        if (abs(fmod(range,0.1)-ringID)<0.005) {
                            orificeType=1;
                            orificeWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
                            orificePositionTracker = mul( unity_WorldToObject, orificeWorld ).xyz;
                        }
                        if (abs(fmod(range,0.1)-normalID)<0.005) {
                            orificeNormalWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
                            orificeNormalTracker = mul( unity_WorldToObject, orificeNormalWorld ).xyz;
                        }
                        if (abs(fmod(range,0.1)-penetratorID)<0.005) {
                            float3 tempPenetratorPositionTracker = penetratorPositionTracker;
                            penetratorWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
                            penetratorPositionTracker = mul( unity_WorldToObject, penetratorWorld ).xyz;
                            if (length(penetratorPositionTracker)>length(tempPenetratorPositionTracker)) {
                                penetratorPositionTracker = tempPenetratorPositionTracker;
                            } else {
                                penetratorLength=unity_LightColor[i].a;
                            }
                        }
                    }
                }
            }

            void penetrationVertexTransform(inout appdata v)
            {
                float orificeType = 0;
                float3 orificePositionTracker = float3(0,0,100);
                float3 orificeNormalTracker = float3(0,0,99);
                float3 penetratorPositionTracker = float3(0,0,1);
                float pl = 0;
                GetBestLights(_OrificeChannel, orificeType, orificePositionTracker, orificeNormalTracker, penetratorPositionTracker, pl);
                float3 orificeNormal = normalize(lerp((orificePositionTracker - orificeNormalTracker) , orificePositionTracker , max(_EntranceStiffness , 0.01)));
                float3 PhysicsNormal = normalize(penetratorPositionTracker.xyz) * _Length * 0.3;
                float wriggleTime = _Time.y * _WriggleSpeed;
                float temp_output_257_0 = (_Length * ((cos(wriggleTime) * _Wriggle) + _Curvature));
                float wiggleTime = _Time.y * (_WriggleSpeed * 0.39);
                float distanceToOrifice = length(orificePositionTracker);
                float enterFactor = smoothstep((_Length + -0.05) , _Length , distanceToOrifice);
                float3 finalOrificeNormal = normalize(lerp(orificeNormal , (PhysicsNormal + ((float3(0,1,0) * (temp_output_257_0 + (_Length * (_ReCurvature + ((sin(wriggleTime) * 0.3) * _Wriggle)) * 2.0))) + (float3(0.5,0,0) * (cos(wiggleTime) * _Wriggle)))) , enterFactor));
                float smoothstepResult186 = smoothstep(_Length , (_Length + 0.05) , distanceToOrifice);
                float3 finalOrificePosition = lerp(orificePositionTracker , ((normalize(penetratorPositionTracker) * _Length) + (float3(0,0.2,0) * (sin((wriggleTime + UNITY_PI)) * _Wriggle) * _Length) + (float3(0.2,0,0) * _Length * (sin((wiggleTime + UNITY_PI)) * _Wriggle))) , smoothstepResult186);
                float finalOrificeDistance = length(finalOrificePosition);
                float3 bezierBasePosition = float3(0,0,0);
                float temp_output_59_0 = (finalOrificeDistance / 3.0);
                float3 lerpResult274 = lerp(float3(0,0,0) , (float3(0,1,0) * (temp_output_257_0 * -0.2)) , saturate((distanceToOrifice / _Length)));
                float3 temp_output_267_0 = ((temp_output_59_0 * float3(0,0,1)) + lerpResult274);
                float3 bezierBaseNormal = temp_output_267_0;
                float3 temp_output_63_0 = (finalOrificePosition - (temp_output_59_0 * finalOrificeNormal));
                float3 bezierOrificeNormal = temp_output_63_0;
                float3 bezierOrificePosition = finalOrificePosition;
                float vertexBaseTipPosition = (v.vertex.z / finalOrificeDistance);
                float t = saturate(vertexBaseTipPosition);
                float oneMinusT = 1 - t;
                float3 bezierPoint = oneMinusT * oneMinusT * oneMinusT * bezierBasePosition + 3 * oneMinusT * oneMinusT * t * bezierBaseNormal + 3 * oneMinusT * t * t * bezierOrificeNormal + t * t * t * bezierOrificePosition;
                float3 straightLine = (float3(0.0 , 0.0 , v.vertex.z));
                float baseFactor = smoothstep(0.05 , -0.05 , v.vertex.z);
                bezierPoint = lerp(bezierPoint , straightLine , baseFactor);
                bezierPoint = lerp(((finalOrificeNormal * (v.vertex.z - finalOrificeDistance)) + finalOrificePosition) , bezierPoint , step(vertexBaseTipPosition , 1.0));
                float3 bezierDerivitive = 3 * oneMinusT * oneMinusT * (bezierBaseNormal - bezierBasePosition) + 6 * oneMinusT * t * (bezierOrificeNormal - bezierBaseNormal) + 3 * t * t * (bezierOrificePosition - bezierOrificeNormal);
                bezierDerivitive = normalize(lerp(bezierDerivitive , float3(0,0,1) , baseFactor));
                float bezierUpness = dot(bezierDerivitive , float3(0,1,0));
                float3 bezierUp = lerp(float3(0,1,0) , float3(0,0,-1) , saturate(bezierUpness));
                float bezierDownness = dot(bezierDerivitive , float3(0,-1,0));
                bezierUp = normalize(lerp(bezierUp , float3(0,0,1) , saturate(bezierDownness)));
                float3 bezierSpaceX = normalize(cross(bezierDerivitive , bezierUp));
                float3 bezierSpaceY = normalize(cross(bezierDerivitive , -bezierSpaceX));
                float3 bezierSpaceVertexOffset = ((v.vertex.y * bezierSpaceY) + (v.vertex.x * -bezierSpaceX));
                float3 bezierSpaceVertexOffsetNormal = normalize(bezierSpaceVertexOffset);
                float distanceFromTip = (finalOrificeDistance - v.vertex.z);
                float squeezeFactor = smoothstep(0.0 , _SqueezeDist , -distanceFromTip);
                squeezeFactor = max(squeezeFactor , smoothstep(0.0 , _SqueezeDist , distanceFromTip));
                float3 bezierSpaceVertexOffsetSqueezed = lerp((bezierSpaceVertexOffsetNormal * min(length(bezierSpaceVertexOffset) , _squeeze)) , bezierSpaceVertexOffset , squeezeFactor);
                float bulgeFactor = smoothstep(0.0 , _BulgeOffset , abs((finalOrificeDistance - v.vertex.z)));
                float bulgeFactorBaseClip = smoothstep(0.0 , 0.05 , v.vertex.z);
                float bezierSpaceVertexOffsetBulged = lerp(1.0 , (1.0 + _BulgePower) , ((1.0 - bulgeFactor) * 100.0 * bulgeFactorBaseClip));
                float3 bezierSpaceVertexOffsetFinal = lerp((bezierSpaceVertexOffsetSqueezed * bezierSpaceVertexOffsetBulged) , bezierSpaceVertexOffset , enterFactor);
                float3 bezierConstructedVertex = (bezierPoint + bezierSpaceVertexOffsetFinal);
                float3 sphereifyDistance = (bezierConstructedVertex - finalOrificePosition);
                float3 sphereifyNormal = normalize(sphereifyDistance);
                float sphereifyFactor = smoothstep(0.05 , -0.05 , distanceFromTip);
                float killSphereifyForRing = lerp(sphereifyFactor , 0.0 , orificeType);
                bezierConstructedVertex = lerp(bezierConstructedVertex , ((min(length(sphereifyDistance) , _squeeze) * sphereifyNormal) + finalOrificePosition) , killSphereifyForRing);
                float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 ase_worldViewDir = normalize(UnityWorldSpaceViewDir(ase_worldPos));
                bezierConstructedVertex = lerp(bezierConstructedVertex , (-ase_worldViewDir * float3(10000,10000,10000)) , _WorldSpaceLightPos0.w);
                v.normal = normalize(((-bezierSpaceX * v.normal.x) + (bezierSpaceY * v.normal.y) + (bezierDerivitive * v.normal.z)));
                v.vertex.xyz = bezierConstructedVertex;
                v.vertex.w = 1;
            }

            v2f vert_penetration(appdata v)
            {
                v2f o;

                // If vertex offset is enabled, apply that first
                #if defined(_VERTEXOFFSET_ON)
                    VertexOffset(v);
                #endif

                // Perform penetration shader offset
                penetrationVertexTransform(v);
                
                o.pos = UnityObjectToClipPos(v.vertex);
                // If UV1 is used, pack UV0 and UV1 into a single float4
                #if defined(_DETAILNORMAL_UV1)
                    float2 uv0 = TRANSFORM_TEX(v.uv, _MainTex);
                    float2 uv1 = TRANSFORM_TEX(v.uv1, _DetailNormalMap);
                    o.uv = float4(uv0, uv1);
                #else
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                #endif
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.objWorldPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
                TRANSFER_SHADOW(o);
                UNITY_TRANSFER_FOG(o, o.pos);

                return o;
            }

            ENDCG
        }
        
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode"="ForwardAdd" }
            
            Stencil {
                Ref [_StencilRef]
                Comp [_StencilCompareFunction]
                Pass [_StencilPassOp]
                Fail [_StencilFailOp]
                ZFail [_StencilZFailOp]
            }
            
            Blend [_SrcBlend] One
            ZTest [_ZTest]
            ZWrite Off
            
            Cull [_Cull]
            
            AlphaToMask [_AlphaToCoverage]
            
            CGPROGRAM
            #pragma vertex vert_penetration
            #pragma fragment frag
            
            #pragma target 5.0

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _ALPHABLEND_ON
            #pragma shader_feature_local _ALPHATOCOVERAGE_ON
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _RAMPMASK_ON
            #pragma shader_feature_local _RAMPTINT_ON
            #pragma shader_feature_local _RAMPANTIALIASING_ON
            #pragma shader_feature_local _OVERRIDEWORLDLIGHTDIR_ON
            #pragma shader_feature_local _MATCAPTINTTEX_ON
            #pragma shader_feature_local _VERTEXOFFSET_ON
            #pragma shader_feature_local _HUESHIFT_ON

            #pragma shader_feature_local _ _DETAILNORMAL_UV0 _DETAILNORMAL_UV1
            #pragma shader_feature_local _ _METALLICGLOSSMAP _SPECGLOSSMAP
            #pragma shader_feature_local _MATCAP_ON
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _ADDITIVERAMP_FORWARDADD_ONLY _ADDITIVERAMP_ALWAYS
            
            #ifndef UNITY_PASS_FORWARDADD
                #define UNITY_PASS_FORWARDADD
            #endif          

            #include "../../../Shaders/Includes/DummyToonCore.cginc"
            
            uniform float _SqueezeDist;
            uniform float _Length;
            uniform float _Wriggle;
            uniform float _BulgePower;
            uniform float _BulgeOffset;
            uniform float _WriggleSpeed;
            uniform float _ReCurvature;
            uniform float _Curvature;
            uniform float _squeeze;
            uniform float _EntranceStiffness;
            uniform float _OrificeChannel;
            
            void GetBestLights( float Channel, inout int orificeType, inout float3 orificePositionTracker, inout float3 orificeNormalTracker, inout float3 penetratorPositionTracker, inout float penetratorLength ) {
                float ID = step( 0.5 , Channel );
                float baseID = ( ID * 0.02 );
                float holeID = ( baseID + 0.01 );
                float ringID = ( baseID + 0.02 );
                float normalID = ( 0.05 + ( ID * 0.01 ) );
                float penetratorID = ( 0.09 + ( ID * -0.01 ) );
                float4 orificeWorld;
                float4 orificeNormalWorld;
                float4 penetratorWorld;
                float penetratorDist=100;
                for (int i=0;i<4;i++) {
                    float range = (0.005 * sqrt(1000000 - unity_4LightAtten0[i])) / sqrt(unity_4LightAtten0[i]);
                    if (length(unity_LightColor[i].rgb) < 0.01) {
                        if (abs(fmod(range,0.1)-holeID)<0.005) {
                            orificeType=0;
                            orificeWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
                            orificePositionTracker = mul( unity_WorldToObject, orificeWorld ).xyz;
                        }
                        if (abs(fmod(range,0.1)-ringID)<0.005) {
                            orificeType=1;
                            orificeWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
                            orificePositionTracker = mul( unity_WorldToObject, orificeWorld ).xyz;
                        }
                        if (abs(fmod(range,0.1)-normalID)<0.005) {
                            orificeNormalWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
                            orificeNormalTracker = mul( unity_WorldToObject, orificeNormalWorld ).xyz;
                        }
                        if (abs(fmod(range,0.1)-penetratorID)<0.005) {
                            float3 tempPenetratorPositionTracker = penetratorPositionTracker;
                            penetratorWorld = float4(unity_4LightPosX0[i], unity_4LightPosY0[i], unity_4LightPosZ0[i], 1);
                            penetratorPositionTracker = mul( unity_WorldToObject, penetratorWorld ).xyz;
                            if (length(penetratorPositionTracker)>length(tempPenetratorPositionTracker)) {
                                penetratorPositionTracker = tempPenetratorPositionTracker;
                            } else {
                                penetratorLength=unity_LightColor[i].a;
                            }
                        }
                    }
                }
            }

            void penetrationVertexTransform(inout appdata v)
            {
                float orificeType = 0;
                float3 orificePositionTracker = float3(0,0,100);
                float3 orificeNormalTracker = float3(0,0,99);
                float3 penetratorPositionTracker = float3(0,0,1);
                float pl = 0;
                GetBestLights(_OrificeChannel, orificeType, orificePositionTracker, orificeNormalTracker, penetratorPositionTracker, pl);
                float3 orificeNormal = normalize(lerp((orificePositionTracker - orificeNormalTracker) , orificePositionTracker , max(_EntranceStiffness , 0.01)));
                float3 PhysicsNormal = normalize(penetratorPositionTracker.xyz) * _Length * 0.3;
                float wriggleTime = _Time.y * _WriggleSpeed;
                float temp_output_257_0 = (_Length * ((cos(wriggleTime) * _Wriggle) + _Curvature));
                float wiggleTime = _Time.y * (_WriggleSpeed * 0.39);
                float distanceToOrifice = length(orificePositionTracker);
                float enterFactor = smoothstep((_Length + -0.05) , _Length , distanceToOrifice);
                float3 finalOrificeNormal = normalize(lerp(orificeNormal , (PhysicsNormal + ((float3(0,1,0) * (temp_output_257_0 + (_Length * (_ReCurvature + ((sin(wriggleTime) * 0.3) * _Wriggle)) * 2.0))) + (float3(0.5,0,0) * (cos(wiggleTime) * _Wriggle)))) , enterFactor));
                float smoothstepResult186 = smoothstep(_Length , (_Length + 0.05) , distanceToOrifice);
                float3 finalOrificePosition = lerp(orificePositionTracker , ((normalize(penetratorPositionTracker) * _Length) + (float3(0,0.2,0) * (sin((wriggleTime + UNITY_PI)) * _Wriggle) * _Length) + (float3(0.2,0,0) * _Length * (sin((wiggleTime + UNITY_PI)) * _Wriggle))) , smoothstepResult186);
                float finalOrificeDistance = length(finalOrificePosition);
                float3 bezierBasePosition = float3(0,0,0);
                float temp_output_59_0 = (finalOrificeDistance / 3.0);
                float3 lerpResult274 = lerp(float3(0,0,0) , (float3(0,1,0) * (temp_output_257_0 * -0.2)) , saturate((distanceToOrifice / _Length)));
                float3 temp_output_267_0 = ((temp_output_59_0 * float3(0,0,1)) + lerpResult274);
                float3 bezierBaseNormal = temp_output_267_0;
                float3 temp_output_63_0 = (finalOrificePosition - (temp_output_59_0 * finalOrificeNormal));
                float3 bezierOrificeNormal = temp_output_63_0;
                float3 bezierOrificePosition = finalOrificePosition;
                float vertexBaseTipPosition = (v.vertex.z / finalOrificeDistance);
                float t = saturate(vertexBaseTipPosition);
                float oneMinusT = 1 - t;
                float3 bezierPoint = oneMinusT * oneMinusT * oneMinusT * bezierBasePosition + 3 * oneMinusT * oneMinusT * t * bezierBaseNormal + 3 * oneMinusT * t * t * bezierOrificeNormal + t * t * t * bezierOrificePosition;
                float3 straightLine = (float3(0.0 , 0.0 , v.vertex.z));
                float baseFactor = smoothstep(0.05 , -0.05 , v.vertex.z);
                bezierPoint = lerp(bezierPoint , straightLine , baseFactor);
                bezierPoint = lerp(((finalOrificeNormal * (v.vertex.z - finalOrificeDistance)) + finalOrificePosition) , bezierPoint , step(vertexBaseTipPosition , 1.0));
                float3 bezierDerivitive = 3 * oneMinusT * oneMinusT * (bezierBaseNormal - bezierBasePosition) + 6 * oneMinusT * t * (bezierOrificeNormal - bezierBaseNormal) + 3 * t * t * (bezierOrificePosition - bezierOrificeNormal);
                bezierDerivitive = normalize(lerp(bezierDerivitive , float3(0,0,1) , baseFactor));
                float bezierUpness = dot(bezierDerivitive , float3(0,1,0));
                float3 bezierUp = lerp(float3(0,1,0) , float3(0,0,-1) , saturate(bezierUpness));
                float bezierDownness = dot(bezierDerivitive , float3(0,-1,0));
                bezierUp = normalize(lerp(bezierUp , float3(0,0,1) , saturate(bezierDownness)));
                float3 bezierSpaceX = normalize(cross(bezierDerivitive , bezierUp));
                float3 bezierSpaceY = normalize(cross(bezierDerivitive , -bezierSpaceX));
                float3 bezierSpaceVertexOffset = ((v.vertex.y * bezierSpaceY) + (v.vertex.x * -bezierSpaceX));
                float3 bezierSpaceVertexOffsetNormal = normalize(bezierSpaceVertexOffset);
                float distanceFromTip = (finalOrificeDistance - v.vertex.z);
                float squeezeFactor = smoothstep(0.0 , _SqueezeDist , -distanceFromTip);
                squeezeFactor = max(squeezeFactor , smoothstep(0.0 , _SqueezeDist , distanceFromTip));
                float3 bezierSpaceVertexOffsetSqueezed = lerp((bezierSpaceVertexOffsetNormal * min(length(bezierSpaceVertexOffset) , _squeeze)) , bezierSpaceVertexOffset , squeezeFactor);
                float bulgeFactor = smoothstep(0.0 , _BulgeOffset , abs((finalOrificeDistance - v.vertex.z)));
                float bulgeFactorBaseClip = smoothstep(0.0 , 0.05 , v.vertex.z);
                float bezierSpaceVertexOffsetBulged = lerp(1.0 , (1.0 + _BulgePower) , ((1.0 - bulgeFactor) * 100.0 * bulgeFactorBaseClip));
                float3 bezierSpaceVertexOffsetFinal = lerp((bezierSpaceVertexOffsetSqueezed * bezierSpaceVertexOffsetBulged) , bezierSpaceVertexOffset , enterFactor);
                float3 bezierConstructedVertex = (bezierPoint + bezierSpaceVertexOffsetFinal);
                float3 sphereifyDistance = (bezierConstructedVertex - finalOrificePosition);
                float3 sphereifyNormal = normalize(sphereifyDistance);
                float sphereifyFactor = smoothstep(0.05 , -0.05 , distanceFromTip);
                float killSphereifyForRing = lerp(sphereifyFactor , 0.0 , orificeType);
                bezierConstructedVertex = lerp(bezierConstructedVertex , ((min(length(sphereifyDistance) , _squeeze) * sphereifyNormal) + finalOrificePosition) , killSphereifyForRing);
                float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 ase_worldViewDir = normalize(UnityWorldSpaceViewDir(ase_worldPos));
                bezierConstructedVertex = lerp(bezierConstructedVertex , (-ase_worldViewDir * float3(10000,10000,10000)) , _WorldSpaceLightPos0.w);
                v.normal = normalize(((-bezierSpaceX * v.normal.x) + (bezierSpaceY * v.normal.y) + (bezierDerivitive * v.normal.z)));
                v.vertex.xyz = bezierConstructedVertex;
                v.vertex.w = 1;
            }

            v2f vert_penetration(appdata v)
            {
                v2f o;

                // If vertex offset is enabled, apply that first
                #if defined(_VERTEXOFFSET_ON)
                    VertexOffset(v);
                #endif

                // Perform penetration shader offset
                penetrationVertexTransform(v);
                
                o.pos = UnityObjectToClipPos(v.vertex);
                // If UV1 is used, pack UV0 and UV1 into a single float4
                #if defined(_DETAILNORMAL_UV1)
                    float2 uv0 = TRANSFORM_TEX(v.uv, _MainTex);
                    float2 uv1 = TRANSFORM_TEX(v.uv1, _DetailNormalMap);
                    o.uv = float4(uv0, uv1);
                #else
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                #endif
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.objWorldPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
                TRANSFER_SHADOW(o);
                UNITY_TRANSFER_FOG(o, o.pos);

                return o;
            }
            
            ENDCG
        }
    }
    CustomEditor "Rokk.DummyToon.Editor.DummyToonPenetrationEditorGUI"
}
