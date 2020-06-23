void MetallicSpecularGloss(float3 worldPos, float2 uv, float3 normalDirection, float3 albedo, inout float3 color)
{
    // In forwardbase, apply the metallic or specular.
    // But in forwardadd, dim the final color as the metallic value increases.
    #ifdef UNITY_PASS_FORWARDBASE
    
        float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - worldPos);
    
        //Metallic
        #if defined(_METALLICGLOSSMAP)
            //Metallic workflow
            float4 metallicTex = tex2D(_MetallicGlossMap, uv);
            float metallic = metallicTex.r * _Metallic;
            
            #ifdef UNITY_PASS_FORWARDBASE
                //Unlit reflections in ForwardBase
                float roughness = 1 - (metallicTex.a * _Glossiness);
                roughness *= 1.7 - 0.7 * roughness;
                
                float3 reflectedDir = reflect(-viewDirection, normalDirection);
                
                float3 reflectionColor;
                
                //Sample second probe if available.
                float interpolator = unity_SpecCube0_BoxMin.w;
                UNITY_BRANCH
                if(interpolator < 0.99999)
                {
                    //Probe 1
                    float4 reflectionData0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectedDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
                    float3 reflectionColor0 = DecodeHDR(reflectionData0, unity_SpecCube0_HDR);

                    //Probe 2
                    float4 reflectionData1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectedDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
                    float3 reflectionColor1 = DecodeHDR(reflectionData1, unity_SpecCube1_HDR);

                    reflectionColor = lerp(reflectionColor1, reflectionColor0, interpolator);
                }
                else
                {
                    float4 reflectionData = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectedDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
                    reflectionColor = DecodeHDR(reflectionData, unity_SpecCube0_HDR);
                }
                
                reflectionColor *= albedo;
            #endif
        #elif defined(_SPECGLOSSMAP)
            //Specular workflow
            float4 specularTex = tex2D(_SpecGlossMap, uv);
            float3 specular = specularTex.rgb * _SpecColor.rgb;
            
            //Not actually metallic, but this saves some work.
            //Defines how much of the final color and reflection color is used.
            float metallic = max(specular.r, max(specular.g, specular.b));
            
            #ifdef UNITY_PASS_FORWARDBASE
                //Unlit reflections in ForwardBase
                float roughness = 1 - (specularTex.a * _Glossiness);
                roughness *= 1.7 - 0.7 * roughness;
                
                float3 reflectedDir = reflect(-viewDirection, normalDirection);
                float3 reflectionColor;
                
                //Sample second probe if available.
                float interpolator = unity_SpecCube0_BoxMin.w;
                UNITY_BRANCH
                if(interpolator < 0.99999)
                {
                    //Probe 1
                    float4 reflectionData0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectedDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
                    float3 reflectionColor0 = DecodeHDR(reflectionData0, unity_SpecCube0_HDR);

                    //Probe 2
                    float4 reflectionData1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectedDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
                    float3 reflectionColor1 = DecodeHDR(reflectionData1, unity_SpecCube1_HDR);

                    reflectionColor = lerp(reflectionColor1, reflectionColor0, interpolator);
                }
                else
                {
                    float4 reflectionData = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectedDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
                    reflectionColor = DecodeHDR(reflectionData, unity_SpecCube0_HDR);
                }
                
                // For specular, use the specular color instead of the albedo color to tint the reflection
                reflectionColor *= specular;
            #endif
        #endif
        
        // Apply the reflection color
        color = lerp(color, reflectionColor, metallic);
    #else
        // Dim the color based on the metallic value
        #if defined(_METALLICGLOSSMAP)
            float4 metallicTex = tex2D(_MetallicGlossMap, uv);
            float metallic = metallicTex.r * _Metallic;
        #elif defined(_SPECGLOSSMAP)
            float4 specularTex = tex2D(_SpecGlossMap, uv);
            float3 specular = specularTex.rgb * _SpecColor.rgb;
            
            //Not actually metallic, but this saves some work.
            //Defines how much of the final color and reflection color is used.
            float metallic = max(specular.r, max(specular.g, specular.b));
        #endif
        
        color *= (1 - metallic);
    #endif
}