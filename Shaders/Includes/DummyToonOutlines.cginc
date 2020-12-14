v2f vertOutline(appdata v)
{
    v2f o;

    // If used, pack UV0 and UV1 into a single float4
    #if defined(_DETAIL_MULX2)
        float2 uv0 = TRANSFORM_TEX(v.uv, _MainTex);
        float2 uv1 = TRANSFORM_TEX(v.uv1, _DetailNormalMap);
        o.uv = float4(uv0, uv1);
    #else
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    #endif

    float outlineWidth = (_OutlineWidth*0.001);
    #if defined(_PARALLAXMAP) && !defined(NO_TEXLOD)
        // Scale outline by outline tex alpha
        float4 outlineTex = tex2Dlod(_OutlineTex, float4(o.uv.xy, 0, 0));
        outlineTex *= _OutlineColor;
        outlineWidth *= outlineTex.a;
    #endif
    
    #if defined(_MAPPING_6_FRAMES_LAYOUT)
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
    o.objWorldPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
    TRANSFER_SHADOW(o);
    return o;
}