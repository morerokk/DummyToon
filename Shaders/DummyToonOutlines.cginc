v2f vertOutline(appdata v)
{
    v2f o;
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

    float outlineWidth = (_OutlineWidth*0.001);
    #if defined(_OUTLINE_ALPHA_WIDTH_ON) && !defined(NO_TEXLOD)
        // Scale outline by outline tex alpha
        float4 outlineTex = tex2Dlod(_OutlineTex, float4(o.uv, 0, 0));
        outlineTex *= _OutlineColor;
        outlineWidth *= outlineTex.a;
    #endif
    
    #if defined(_OUTLINE_SCREENSPACE)
        float dist = clamp(distance(_WorldSpaceCameraPos,mul(unity_ObjectToWorld, v.vertex).xyz), _ScreenSpaceMinDist, _ScreenSpaceMaxDist);
        float OutlineScale = dist * outlineWidth;
    #else
        float OutlineScale = outlineWidth;
    #endif
    
    o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + v.normal*OutlineScale,1));

    o.normalDir = UnityObjectToWorldNormal(v.normal);
    o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
    o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_SHADOW(o);
    return o;
}