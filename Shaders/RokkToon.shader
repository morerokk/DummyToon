Shader "Rokk/Toon"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)

        [Normal] _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Float) = 1.0

        [Toggle(_ALPHATEST_ON)] _Mode ("Cutout", Float) = 0
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        
        _EmissionMap("Emission Map", 2D) = "white" {}
        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0)
        
        _Ramp ("Toon Ramp", 2D) = "white" {}
        _ToonContrast ("Toon Contrast", Range(0, 1)) = 0.5
        _ToonRampOffset ("Toon Ramp Offset", Range(-1,1)) = 0.33
        _StaticToonLight ("Fallback Light Direction", Vector) = (0,1,0,0)
        
        _Intensity ("Intensity", Range(0, 5)) = 1.3
        _Saturation ("Saturation", Range(0, 5)) = 1
        
        [Enum(Both,0,Front,2,Back,1)] _Cull("Sidedness", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode"="ForwardBase" }
            
            Cull [_Cull]
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile _ VERTEXLIGHT_ON
            
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _EMISSION
            
            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif          

            #include "RokkToonCore.cginc"
            ENDCG
        }
        
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode"="ForwardAdd" }
            
            Blend One One
            ZWrite Off
            
            Cull [_Cull]
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdadd_fullshadows
            
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local _NORMALMAP
            
            #ifndef UNITY_PASS_FORWARDADD
                #define UNITY_PASS_FORWARDADD
            #endif          

            #include "RokkToonCore.cginc"
            ENDCG
        }

        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma multi_compile_shadowcaster
            
            #pragma shader_feature_local _ALPHATEST_ON

            #pragma vertex vertShadow
            #pragma fragment fragShadow
            
            #include "RokkToonShadowcaster.cginc"
            
            ENDCG
        }
    }
}
