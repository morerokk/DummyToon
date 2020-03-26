void Rimlight(float2 uv, float3 viewDir, float3 normalDir, inout float3 albedo)
{
    float rim = 1.0 - saturate(dot(normalize(viewDir), normalDir));
    if(_RimInvert == 1)
    {
        rim = 1 - rim;
    }
    
    float4 rimTex = tex2D(_RimTex, uv);
    rimTex *= _RimLightColor;
    
    float3 rimColor = rimTex.rgb * smoothstep(1 - _RimWidth, 1.0, rim);
    
    #if defined(_RIMLIGHT_ADD)
        albedo += (rimColor * rimTex.a);
    #else   
        albedo = lerp(albedo, rimColor, rim * rimTex.a);
    #endif
}