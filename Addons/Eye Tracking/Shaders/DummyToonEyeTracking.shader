Shader "Dummy Toon/Addons/Toon (Eye Tracking)"
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
		[Toggle(_)] _EmissionPremultiply("Premultiply Emission by Alpha", Float) = 0

		[NoScaleOffset] _OcclusionMap ("Ambient Occlusion Map", 2D) = "white" {}
		_OcclusionStrength ("AO Strength", Range(0,1)) = 1
		
		// Toon lighting
		[NoScaleOffset] _Ramp ("Toon Ramp", 2D) = "white" {}
		_ToonContrast ("Toon Contrast", Range(0, 1)) = 0.5
		_ToonRampOffset ("Toon Ramp Offset", Range(-2,2)) = 0
		_StaticToonLight ("Fallback Light Direction", Vector) = (0,1,0,0)
		_DirectLightBoost ("Direct Light Boost", Range(0,2)) = 0.8
		_IndirectLightBoost ("Indirect Light Boost", Range (0,2)) = 1.3
		[Toggle(_COLORCOLOR_ON)] _RampTinting ("Ramp Tinting", Float) = 0
		[Toggle(_COLOROVERLAY_ON)] _RampAntiAliasingEnabled ("Ramp Anti-Aliasing", Float) = 0
		[Toggle(_FADING_ON)] _OverrideWorldLightDir ("Always use fallback", Float) = 0
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

		// New specular
		[Toggle(ETC1_EXTERNAL_ALPHA)] _SpecularEnabled ("Specular Enabled", Float) = 0
		[Enum(Blinn,0,Blinn Phong,1,Blinn Phong View,2)] _SpecularMode ("Specular Mode", Float) = 1
		[NoScaleOffset] _SpecMap ("_Specular Map", 2D) = "white" {}
		[HDR] _SpecularColor ("Specular Color", Color) = (1,1,1,1)
		[Toggle(_)] _SpecularToonyEnabled ("Toony Specular", Float) = 1
		_SpecularToonyCutoff ("Specular Cutoff", Range(0,1)) = 1
		_SpecularIndirectBoost ("Specular Indirect Light Boost", Range(0,3)) = 1
		
		// Toon ramp masking
		[Toggle(_COLORADDSUBDIFF_ON)] _RampMaskEnabled ("Ramp Masking", Float) = 0
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
		[Toggle(_ALPHAMODULATE_ON)] _AlphaToCoverage ("Alpha To Coverage", Float) = 0
		_AlphaToCoverageCutoff ("Cutoff", Range(0,1)) = 0.5
		
		// Detail normal
		[Normal] _DetailNormalMap ("Detail Normal Map", 2D) = "bump" {}
		_DetailNormalMapScale ("Detail Normal Scale", Float) = 1.0
		[Enum(UV0,0,UV1,1)] _UVSec ("UV Map for detail normals", Float) = 0
		_DetailMask ("Detail Mask", 2D) = "white" {}

		// Vertex Offset
		[Toggle(_PARALLAXMAP)] _VertexOffsetEnabled ("Enable Vertex Offset", Float) = 0
		_VertexOffsetPos ("Local Position Offset", Vector) = (0,0,0,0)
		_VertexOffsetRot ("Rotation", Vector) = (0,0,0,0)
		_VertexOffsetScale ("Scale", Vector) = (1,1,1,0)
		_VertexOffsetPosWorld ("World Position Offset", Vector) = (0,0,0,0)
		
		// Hue Shift
		[Toggle(EFFECT_HUE_VARIATION)] _HueShiftEnabled ("Enable Hue Shift", Float) = 0
		_HueShiftAmount ("Hue Shift Amount", Range(0,1)) = 0
		_HueShiftMask ("Hue Shift Mask", 2D) = "white" {}
		_HueShiftAmountOverTime ("Hue Shift Amount Over Time", Float) = 0

		// Debug options
		[Toggle(UNITY_UI_ALPHACLIP)] _DebugOptionsEnabled ("Enable Debug Options", Float) = 0 // Turns this entire category on/off using a keyword.
		[Toggle(_)] _DebugEnabled ("Debug Enabled", Float) = 1 // Turns the feature on/off in the shader itself. Allows the debug options to be "inactive" even if the keyword is enabled, allowing you to switch it on/off.
		_DebugMinLightBrightness ("Minimum Light Brightness", Float) = 0
		_DebugMaxLightBrightness ("Maximum Light Brightness", Float) = 10
		[Toggle(_)] _DebugNormals ("Show Normals", Float) = 0
		_DebugUVs ("Visualize UV's", Range(0,1)) = 0
		_DebugUVsOffset ("UV Visualization Offset", Vector) = (-0.5,-0.5,0,0)
		
		// Kaj shader optimizer
		[ShaderOptimizerLockButton] _ShaderOptimized ("Shader Optimized", Int) = 0

		// Stencils
		[IntRange] _StencilRef ("Stencil Value", Range(0, 255)) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp ("Pass Op", Float) = 0 // Keep
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilFailOp ("Fail Op", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp ("ZFail Op", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilCompareFunction ("Compare Function", Float) = 8 // Always

		// ZTest
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4 // LEqual
		
		// Eye tracking
		[Enum(Left,0,Center,1,Right,2)] _TargetEye("Target Eye", Float) = 1
		_MaxLookRange ("Max Look Range", Range(0,1)) = 0.4
		_EyeTrackingPatternTex ("Eye Tracking Pattern Texture", 2D) = "white" {}
		_EyeTrackingScrollSpeed ("Eye Tracking Pattern Speed", Range(-100, 100)) = 1
		_EyeTrackingBlur ("Eye Tracking Pattern Blur", Range(0,6)) = 0
		[Toggle(_)] _EyeTrackingRotationCorrection ("Blender Rotation Correction", Float) = 1
		_MaxLookDistance ("Maximum Look Distance", Float) = 3.5
		
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
			#pragma vertex vertEyeTracking
			#pragma fragment frag
			
			#pragma target 5.0

			#pragma multi_compile_fwdbase_fullshadows
			#pragma multi_compile_fog
			#pragma multi_compile _ VERTEXLIGHT_ON
			
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _ALPHAMODULATE_ON
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _EMISSION
			#pragma shader_feature _COLORADDSUBDIFF_ON
			#pragma shader_feature _COLORCOLOR_ON
			#pragma shader_feature _COLOROVERLAY_ON
			#pragma shader_feature _FADING_ON
			#pragma shader_feature _PARALLAXMAP
			#pragma shader_feature EFFECT_HUE_VARIATION
			#pragma shader_feature ETC1_EXTERNAL_ALPHA
			#pragma shader_feature EFFECT_BUMP
			#pragma shader_feature UNITY_UI_ALPHACLIP

			#pragma shader_feature _ _DETAIL_MULX2 _REQUIRE_UV2
			#pragma shader_feature _ _METALLICGLOSSMAP _SPECGLOSSMAP
			#pragma shader_feature _SUNDISK_NONE
			#pragma shader_feature _ _SUNDISK_SIMPLE _SUNDISK_HIGH_QUALITY
			#pragma shader_feature _ _TERRAIN_NORMAL_MAP _MAPPING_6_FRAMES_LAYOUT
			
			#ifndef UNITY_PASS_FORWARDBASE
				#define UNITY_PASS_FORWARDBASE
			#endif

			#include "../../../Shaders/Includes/DummyToonCore.cginc"
			
			#include "Includes/EyeTracking.cginc"
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
			ZWrite Off
			ZTest [_ZTest]
			
			Cull [_Cull]
			
			AlphaToMask [_AlphaToCoverage]
			
			CGPROGRAM
			#pragma vertex vertEyeTracking
			#pragma fragment frag
			
			#pragma target 5.0

			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _ALPHAMODULATE_ON
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _COLORADDSUBDIFF_ON
			#pragma shader_feature _COLORCOLOR_ON
			#pragma shader_feature _COLOROVERLAY_ON
			#pragma shader_feature _FADING_ON
			#pragma shader_feature _PARALLAXMAP
			#pragma shader_feature EFFECT_HUE_VARIATION
			#pragma shader_feature ETC1_EXTERNAL_ALPHA
			#pragma shader_feature UNITY_UI_ALPHACLIP

			#pragma shader_feature _ _DETAIL_MULX2 _REQUIRE_UV2
			#pragma shader_feature _ _METALLICGLOSSMAP _SPECGLOSSMAP
			#pragma shader_feature _ _MATCAP_ADD _MATCAP_MULTIPLY
			#pragma shader_feature _ _SUNDISK_SIMPLE _SUNDISK_HIGH_QUALITY
			#pragma shader_feature _ _TERRAIN_NORMAL_MAP _MAPPING_6_FRAMES_LAYOUT
			
			#ifndef UNITY_PASS_FORWARDADD
				#define UNITY_PASS_FORWARDADD
			#endif          

			#include "../../../Shaders/Includes/DummyToonCore.cginc"
			
			#include "Includes/EyeTracking.cginc"
			ENDCG
		}
		Pass {
			Name "ShadowCaster"
			Tags {
				"LightMode"="ShadowCaster"
			}
			Offset 1, 1
			
			Stencil {
				Ref [_StencilRef]
				Comp [_StencilCompareFunction]
				Pass [_StencilPassOp]
				Fail [_StencilFailOp]
				ZFail [_StencilZFailOp]
			}
			
			Cull [_Cull]
			
			CGPROGRAM
			#pragma target 5.0
			
			#pragma multi_compile_shadowcaster
			
			#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _PARALLAXMAP

			#pragma vertex vertShadowEye
			#pragma fragment fragShadow

			#define EYE_TRACKING
			
			#include "../../../Shaders/Includes/DummyToonShadowcaster.cginc"

			#include "Includes/EyeTrackingShadow.cginc"
			ENDCG
		}
	}
	CustomEditor "Rokk.DummyToon.Editor.DummyToonEyeTrackingEditorGUI"
}
