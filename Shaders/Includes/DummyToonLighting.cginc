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


float3 blendSoftLight(float3 base, float3 blend) {
    return lerp(
        sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend), 
        2.0 * base * blend + base * base * (1.0 - 2.0 * blend),
        step(base, 0.5)
    );
}

float2 AAToonRampUV(float dotProduct, float4 texelsize)
{
    float pixelSize = max(texelsize.z, texelsize.w);
    dotProduct *= pixelSize;
    float2 duv = float2(ddx(dotProduct), ddy(dotProduct));
    float rf = rsqrt(dot(duv, duv));
    float x = floor(dotProduct);
    x = x - max(0, .5 - rf * (dotProduct - floor(dotProduct)));
    x = x + max(0, .5 - rf * (ceil(dotProduct) - dotProduct));
    x = (x + .5) / pixelSize;
    return x.xx;
}

float2 GetToonRampUV(float dotProduct, float4 texelsize, float offset)
{
    // Turn ndotl into UV's for toon ramp
    // Sample toon ramp diagonally to cover horizontal and vertical ramps (thanks Rero)
    #if defined(_RAMPANTIALIASING_ON) && !defined(NO_DERIVATIVES)
        return saturate(AAToonRampUV(dotProduct, texelsize) + offset);
    #else
        return saturate(float2(dotProduct, dotProduct) + offset);
    #endif
}

// Simple lambert lighting
float3 ToonLighting(float3 albedo, float3 normalDir, float3 lightDir, float3 lightColor, float4 ToonRampMaskColor, float toonContrast, float toonRampOffset)
{
    // Get dot product
    // Remap -1,1 range to 0,1
    float dotProduct = dot(normalDir, lightDir) * 0.5 + 0.5;
    
    // If additive ramping is used, always sample the additive ramp
    #if defined(_ADDITIVERAMP_ALWAYS) || (defined(_ADDITIVERAMP_FORWARDADD_ONLY) && defined(UNITY_PASS_FORWARDADD))
        float2 rampUV = GetToonRampUV(dotProduct, _AdditiveRamp_TexelSize, toonRampOffset);
        float4 ramp = tex2D(_AdditiveRamp, rampUV);
    #else
        #if defined(_RAMPMASK_ON)
            float4 ramp;
            float2 rampUV;
            if(ToonRampMaskColor.r > 0.5)
            {
                rampUV = GetToonRampUV(dotProduct, _RampR_TexelSize, toonRampOffset);
                ramp = tex2D(_RampR, rampUV);
            }
            else if(ToonRampMaskColor.g > 0.5)
            {
                rampUV = GetToonRampUV(dotProduct, _RampG_TexelSize, toonRampOffset);
                ramp = tex2D(_RampG, rampUV);
            }
            else if(ToonRampMaskColor.b > 0.5)
            {
                rampUV = GetToonRampUV(dotProduct, _RampB_TexelSize, toonRampOffset);
                ramp = tex2D(_RampB, rampUV);
            }
            else
            {
                rampUV = GetToonRampUV(dotProduct, _Ramp_TexelSize, toonRampOffset);
                ramp = tex2D(_Ramp, rampUV);
            }
        #else
            float2 rampUV = GetToonRampUV(dotProduct, _Ramp_TexelSize, toonRampOffset);
            float4 ramp = tex2D(_Ramp, rampUV);
        #endif
    #endif
    
    #if defined(_RAMPTINT_ON)
        // Soft-blend the ramp and albedo
        return blendSoftLight(albedo * lightColor, ramp.rgb) * toonContrast;
    #else
        // Multiply by toon ramp color value
        return albedo * lightColor * ramp.rgb * toonContrast;
    #endif
}

// Same as above, but without additive ramping support (only used for base lighting function)
float3 ToonLightingBase(float3 albedo, float3 normalDir, float3 lightDir, float3 lightColor, float4 ToonRampMaskColor, float toonContrast, float toonRampOffset)
{
    // Get dot product
    // Remap -1,1 range to 0,1
    float dotProduct = dot(normalDir, lightDir) * 0.5 + 0.5;

    #if defined(_RAMPMASK_ON)
        float4 ramp;
        float2 rampUV;
        if(ToonRampMaskColor.r > 0.5)
        {
            rampUV = GetToonRampUV(dotProduct, _RampR_TexelSize, toonRampOffset);
            ramp = tex2D(_RampR, rampUV);
        }
        else if(ToonRampMaskColor.g > 0.5)
        {
            rampUV = GetToonRampUV(dotProduct, _RampG_TexelSize, toonRampOffset);
            ramp = tex2D(_RampG, rampUV);
        }
        else if(ToonRampMaskColor.b > 0.5)
        {
            rampUV = GetToonRampUV(dotProduct, _RampB_TexelSize, toonRampOffset);
            ramp = tex2D(_RampB, rampUV);
        }
        else
        {
            rampUV = GetToonRampUV(dotProduct, _Ramp_TexelSize, toonRampOffset);
            ramp = tex2D(_Ramp, rampUV);
        }
    #else
        float2 rampUV = GetToonRampUV(dotProduct, _Ramp_TexelSize, toonRampOffset);
        float4 ramp = tex2D(_Ramp, rampUV);
    #endif
    
    #if defined(_RAMPTINT_ON)
        // Soft-blend the ramp and albedo
        return blendSoftLight(albedo * lightColor, ramp.rgb) * toonContrast;
    #else
        // Multiply by toon ramp color value
        return albedo * lightColor * ramp.rgb * toonContrast;
    #endif
}

// Fill the light direction and light color parameters with data from SH.
// This ensures that there is always some toon shading going on.
void GetBaseLightData(inout float3 lightDirection, inout float3 lightColor)
{
    #if defined(_OVERRIDEWORLDLIGHTDIR_ON)
        lightDirection = _StaticToonLight;
    #else
        lightDirection = GIsonarDirection();
    #endif
    lightColor = ShadeSH9(float4(0,0,0,1));
}

// Fill the light direction and light color parameters.
void GetLightData(float3 worldPos, inout float3 lightDirection, inout float3 lightColor)
{
    #if defined(_OVERRIDEWORLDLIGHTDIR_ON)
        lightDirection = _StaticToonLight;
        lightColor = _LightColor0.rgb;
    #else
        #ifdef UNITY_PASS_FORWARDBASE
            // Take directional light direction and color
            lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            lightColor = _LightColor0.rgb;
        #else
            // Pass is forwardadd
            // Check if the light is directional or point/spot.
            // Directional lights get their pos interpreted as direction
            // Other lights get their direction calculated from their pos
            #if defined(DIRECTIONAL) || defined(DIRECTIONAL_COOKIE)
                lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                lightColor = _LightColor0.rgb;
            #else
                lightDirection = normalize(_WorldSpaceLightPos0.xyz - worldPos);
                lightColor = _LightColor0.rgb;
            #endif
        #endif
    #endif
}

// If the direction of the baked light is too close to that of the ForwardBase realtime directional light,
// merge the baked light direction into it.
// This is a workaround to prevent mixed directional lights from falsely acting like two separate lights in outdoor scenes.
void SmoothBaseLightData(inout float3 lightDirection)
{
    float dotProduct = dot(lightDirection, _WorldSpaceLightPos0) * 0.5 + 0.5;
    float lerpValue = smoothstep(_IndirectLightDirMergeMin, _IndirectLightDirMergeMax, dotProduct);
    
    lightDirection = normalize(lerp(lightDirection, _WorldSpaceLightPos0, lerpValue));
}
