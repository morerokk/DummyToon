Shader "Dummy Toon/Mobile/Toon Ramped (Vertex Lit)"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        [NoScaleOffset] _Ramp ("Toon Ramp", 2D) = "white" {}
        [Toggle(_GUESSLIGHTDIR_ON)] _GuessLightDir ("Guess Light Dir", Float) = 1.0
        [Toggle(_VERTEXCOLOR_ON)] _UseVertexColor ("Use Vertex Colors", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode"="ForwardBase" }
            
            Cull Back
            ZWrite On
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            // LOD sampling is needed for this shader
            #pragma require samplelod
            
            #include "UnityCG.cginc"

            #pragma multi_compile_fwdbase
            #pragma multi_compile _ VERTEXLIGHT_ON
            
            // Same as _GUESSLIGHTDIR_ON but can be set globally through script.
            #pragma multi_compile _ _GUESSLIGHTDIR_GLOBAL_ON
            
            #pragma shader_feature _GUESSLIGHTDIR_ON
            
            #pragma shader_feature _COLOR_ON
            #pragma shader_feature _MAINTEX_ON
            #pragma shader_feature _VERTEXCOLOR_ON
            
            #ifndef UNITY_PASS_FORWARDBASE
                #define UNITY_PASS_FORWARDBASE
            #endif
            
            #if defined(_MAINTEX_ON)
                uniform sampler2D _MainTex;
            #endif
            
            uniform fixed4 _Color;
            
            uniform sampler2D _Ramp;
            
            uniform fixed4 _LightColor0;
            
            // "Safe" normalize function taken from Unity source, does not cause issues on zero-length vectors
            inline half3 Unity_SafeNormalize(half3 inVec)
            {
                half dp3 = max(0.001f, dot(inVec, inVec));
                return inVec * rsqrt(dp3);
            }
            
            struct appdata
            {
                float3 pos : POSITION;
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                #if defined(_VERTEXCOLOR_ON)
                    fixed4 color : COLOR;
                #endif
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                half3 lighting : TEXCOORD1;
                #if defined(_VERTEXCOLOR_ON)
                    fixed4 vertexColor : TEXCOORD2;
                #endif
            };
            
            v2f vert(appdata i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.uv = i.uv;
                
                #if defined(_VERTEXCOLOR_ON)
                    o.vertexColor = i.color;
                #endif
                
                // Calculate lighting
                // Start with flat SH
                // half3 is used instead of fixed3 because ShadeSH9 already works with and returns half3's
                half3 baseLightCol = ShadeSH9(half4(0,0,0,1));
                half3 lighting = baseLightCol;
                
                // Add vertex lights to base lighting
                // Since this shader lacks a forwardadd pass, "important" or auto realtime lights might find their way in here, which is intended.
                #if defined(VERTEXLIGHT_ON)
                    float3 worldPos = mul(unity_ObjectToWorld, float4(i.pos, 1)).xyz;
                
                    lighting += Shade4PointLights(
                        unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                        unity_LightColor[0].rgb, unity_LightColor[1].rgb,
                        unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                        unity_4LightAtten0, worldPos, i.normal
                    );
                #endif
                
                #if defined(_GUESSLIGHTDIR_ON) || defined(_GUESSLIGHTDIR_GLOBAL_ON)
                    // Try to guess the light dir and color from SH
                    float3 lightDir = Unity_SafeNormalize(unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
                    float3 lightColor = baseLightCol;
                #else
                    // Just take the directional light
                    // This will fail to be meaningful if there is no directional light
                    float3 lightDir = _WorldSpaceLightPos0.xyz;
                    float3 lightColor = _LightColor0.rgb;
                #endif
                
                // Use half lambert to apply the ramp
                half dotProduct = dot(i.normal, lightDir) * 0.5 + 0.5;
                
                // Sample the ramp
                lighting += lightColor * tex2Dlod(_Ramp, half4(dotProduct, dotProduct, 0, 0)).rgb;
                
                o.lighting = lighting;
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_TARGET
            {
                #if defined(_MAINTEX_ON) && defined(_COLOR_ON)
                    // Both color and tex are used
                    fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                #elif defined(_MAINTEX_ON)
                    // Only tex is used
                    fixed4 col = tex2D(_MainTex, i.uv);
                #else
                    // Using the color property or using a default color makes no performance difference, so the color property is always used.
                    fixed4 col = _Color;
                #endif
                
                #if defined(_VERTEXCOLOR_ON)
                    col *= i.vertexColor;
                #endif
                
                // Multiply by the lighting calculated in the vertex shader
                col.rgb *= i.lighting;

                // Return the final color
                return col;
            }

            
            ENDCG
        }

        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma target 2.0
            
            #pragma multi_compile_shadowcaster

            #pragma vertex vertShadow
            #pragma fragment fragShadow
            
            #include "../Includes/DummyToonShadowcaster.cginc"
            
            ENDCG
        }
    }
    CustomEditor "Rokk.DummyToon.Editor.DummyToonMobileEditorGUI"
}
