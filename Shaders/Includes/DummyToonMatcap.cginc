float2 matcapSample(float3 worldUp, float3 viewDirection, float3 normalDirection)
{
    float3 worldViewUp = normalize(worldUp - viewDirection * dot(viewDirection, worldUp));
    float3 worldViewRight = normalize(cross(viewDirection, worldViewUp));
    float2 matcapUV = float2(dot(worldViewRight, normalDirection), dot(worldViewUp, normalDirection)) * 0.5 + 0.5;
    return matcapUV;
}

void Matcap(float3 viewDir, float3 normalDir, float2 uv, inout float3 albedo)
{
    float3 upVector = float3(0,1,0);
    float2 matcapUv = matcapSample(upVector, viewDir, normalDir);
    float4 matcapCol = tex2D(_MatCap, matcapUv);
    
    #if defined(_SUNDISK_NONE)
        float4 matcapTint = tex2D(_MatCapTintTex, uv);
        matcapCol.rgb *= matcapTint.rgb * _MatCapColor.rgb;
        float strength = _MatCapStrength * matcapTint.a * _MatCapColor.a;
    #else
        matcapCol.rgb *= _MatCapColor.rgb;
        float strength = _MatCapStrength * _MatCapColor.a;
    #endif

    #if defined(_SUNDISK_SIMPLE)
        float3 matcapResult = albedo + matcapCol.rgb;
    #else
        float3 matcapResult = albedo * matcapCol.rgb;
    #endif

    albedo = lerp(albedo, matcapResult, strength);
}