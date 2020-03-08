// Indirect lighting, consists of SH and vertex lights
// In ForwardAdd, there is no indirect lighting.
float3 IndirectToonLighting(float3 albedo, float3 normalDir, float3 worldPos)
{
    #ifdef UNITY_PASS_FORWARDBASE
        // Apply SH
        // The sample direction is zero to sample flatly, for a toonier look
        float3 lighting = albedo * ShadeSH9(float4(0,0,0,1));
        
        // Apply vertex lights
        #if defined(VERTEXLIGHT_ON)
            lighting += albedo * Shade4PointLights(
                    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                    unity_LightColor[0].rgb, unity_LightColor[1].rgb,
                    unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                    unity_4LightAtten0, worldPos, normalDir
            );
        #endif
    
    #else
        // In additive passes, start with zero as base
        float3 lighting = float3(0,0,0);
    #endif
    
    return lighting;
}

// Obtain a light direction from baked lighting.
float3 GIsonarDirection()
{
    float3 dir = Unity_SafeNormalize(unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
    if(all(dir == 0))
    {
        dir = _StaticToonLight;
    }
    return dir;
}

// Simple lambert lighting
float3 ToonLighting(float3 albedo, float3 normalDir, float3 lightDir, float3 lightColor, sampler2D rampTex, float toonContrast, float toonRampOffset)
{
    float dotProduct = saturate(dot(normalDir, lightDir));
    
    // Turn ndotl into UV's for toon ramp
    // Sample toon ramp diagonally to cover horizontal and vertical ramps (thanks Rero)
    float2 rampUV = saturate(float2(dotProduct, dotProduct) + toonRampOffset);
    float4 ramp = tex2D(rampTex, rampUV);
    
    // Multiply by toon ramp color value rather than ndotl
    return albedo * lightColor * ramp.rgb * toonContrast;
}

// Fill the light direction and light color parameters.
void GetLightData(float3 albedo, float3 normalDir, float3 worldPos, float attenuation, inout float3 lightDirection, inout float3 lightColor)
{        
    #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
        #ifdef UNITY_PASS_FORWARDBASE
            // Pass is forwardbase, realtime directional light may or may not exist, or may be obscured in shadow.
            // Check if the attenuation is 0 (surface is in shadow), or if there is no realtime directional light.
            if(all(_WorldSpaceLightPos0.xyz == 0) || attenuation == 0)
            {
                // No realtime directional light, use GI sonar to obtain a light direction.
                // Use SH for color.
                lightDirection = GIsonarDirection();
                lightColor = ShadeSH9(float4(0,0,0,1));
            }
            else
            {
                // Realtime directional light exists, take directional light direction and color
                lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                lightColor = _LightColor0.rgb;
            }
        #else
            // Pass is forwardadd, take realtime directional light direction and color
            lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            lightColor = _LightColor0.rgb;
        #endif
    #else
        // Pass is forwardadd, calculate direction from worldspace pos and take the color.
        lightDirection = normalize(_WorldSpaceLightPos0.xyz - worldPos);
        lightColor = _LightColor0.rgb;
    #endif
}