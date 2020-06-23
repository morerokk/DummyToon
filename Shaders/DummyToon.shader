Shader "Dummy Toon/Toon"
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
        _DirectLightBoost ("Direct Light Boost", Range(0,2)) = 0.8
        _IndirectLightBoost ("Indirect Light Boost", Range (0,2)) = 1.3
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
        
        // Alpha to coverage
        [Toggle(_ALPHATOCOVERAGE_ON)] _AlphaToCoverage ("Alpha To Coverage", Float) = 0
        
        // Detail normal
        [Normal] _DetailNormalMap ("Detail Normal Map", 2D) = "bump" {}
        _DetailNormalMapScale ("Detail Normal Scale", Float) = 1.0
        [Enum(UV0,0,UV1,1)] _UVSec ("UV Map for detail normals", Float) = 0
        
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
            
            Cull [_Cull]
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend]
            
            AlphaToMask [_AlphaToCoverage]
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 5.0

            #pragma multi_compile_fwdbase_fullshadows
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

            #pragma shader_feature_local _ _DETAILNORMAL_UV0 _DETAILNORMAL_UV1
            #pragma shader_feature_local _ _METALLICGLOSSMAP _SPECGLOSSMAP
            #pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _ADDITIVERAMP_FORWARDADD_ONLY _ADDITIVERAMP_ALWAYS
            
            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif          

            #include "Includes/DummyToonCore.cginc"
            ENDCG
        }
        
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode"="ForwardAdd" }
            
            Blend [_SrcBlend] One
            ZWrite Off
            
            Cull [_Cull]
            
            AlphaToMask [_AlphaToCoverage]
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 5.0

            #pragma multi_compile_fwdadd_fullshadows
            
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _ALPHABLEND_ON
            #pragma shader_feature_local _ALPHATOCOVERAGE_ON
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _RAMPMASK_ON
            #pragma shader_feature_local _RAMPTINT_ON
            #pragma shader_feature_local _RAMPANTIALIASING_ON
            #pragma shader_feature_local _OVERRIDEWORLDLIGHTDIR_ON

            #pragma shader_feature_local _ _DETAILNORMAL_UV0 _DETAILNORMAL_UV1
            #pragma shader_feature_local _ _METALLICGLOSSMAP _SPECGLOSSMAP
            #pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _ADDITIVERAMP_FORWARDADD_ONLY _ADDITIVERAMP_ALWAYS
            
            #ifndef UNITY_PASS_FORWARDADD
                #define UNITY_PASS_FORWARDADD
            #endif          

            #include "Includes/DummyToonCore.cginc"
            ENDCG
        }

        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            Cull [_Cull]
            
            CGPROGRAM
            #pragma target 5.0
            
            #pragma multi_compile_shadowcaster
            
            #pragma shader_feature_local _ALPHATEST_ON

            #pragma vertex vertShadow
            #pragma fragment fragShadow
            
            #include "Includes/DummyToonShadowcaster.cginc"
            
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode"="ForwardBase" }
            
            Cull [_Cull]
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend]
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 2.0

            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile _ VERTEXLIGHT_ON
            
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _ALPHABLEND_ON
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _EMISSION
            #pragma shader_feature_local _RAMPMASK_ON
            #pragma shader_feature_local _RAMPTINT_ON
            #pragma shader_feature_local _OVERRIDEWORLDLIGHTDIR_ON

            #pragma shader_feature_local _ _DETAILNORMAL_UV0 _DETAILNORMAL_UV1
            #pragma shader_feature_local _ _METALLICGLOSSMAP _SPECGLOSSMAP
            #pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _ADDITIVERAMP_FORWARDADD_ONLY _ADDITIVERAMP_ALWAYS
            
            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif
            
            #define NO_DERIVATIVES

            #include "Includes/DummyToonCore.cginc"
            ENDCG
        }
        
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode"="ForwardAdd" }
            
            Blend [_SrcBlend] One
            ZWrite Off
            
            Cull [_Cull]
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 2.0

            #pragma multi_compile_fwdadd_fullshadows
            
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _ALPHABLEND_ON
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _RAMPMASK_ON
            #pragma shader_feature_local _RAMPTINT_ON
            #pragma shader_feature_local _OVERRIDEWORLDLIGHTDIR_ON

            #pragma shader_feature_local _ _DETAILNORMAL_UV0 _DETAILNORMAL_UV1
            #pragma shader_feature_local _ _METALLICGLOSSMAP _SPECGLOSSMAP
            #pragma shader_feature_local _ _MATCAP_ADD _MATCAP_MULTIPLY
            #pragma shader_feature_local _ _RIMLIGHT_ADD _RIMLIGHT_MIX
            #pragma shader_feature_local _ _ADDITIVERAMP_FORWARDADD_ONLY _ADDITIVERAMP_ALWAYS
            
            #ifndef UNITY_PASS_FORWARDADD
                #define UNITY_PASS_FORWARDADD
            #endif
            
            #define NO_DERIVATIVES

            #include "Includes/DummyToonCore.cginc"
            ENDCG
        }

        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            Cull [_Cull]
            
            CGPROGRAM
            #pragma target 2.0
            
            #pragma multi_compile_shadowcaster
            
            #pragma shader_feature_local _ALPHATEST_ON

            #pragma vertex vertShadow
            #pragma fragment fragShadow
            
            #include "Includes/DummyToonShadowcaster.cginc"
            
            ENDCG
        }
    }
    CustomEditor "DummyToonEditorGUI"
}
