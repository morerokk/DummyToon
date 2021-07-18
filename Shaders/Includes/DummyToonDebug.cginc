uniform float _DebugEnabled;
uniform float _DebugMinLightBrightness;
uniform float _DebugMaxLightBrightness;
uniform float _DebugNormals;
uniform float _DebugUVs;
uniform float3 _DebugUVsOffset;

float3 DebugNormalColor(float3 normal)
{
    return normal * 0.5 + 0.5;
}

float4 DebugUVs(float2 uv, float4 vertex)
{
    float4 uvVertex = float4(uv, vertex.z * 0.01, 1);

    uvVertex.xyz += _DebugUVsOffset;

    vertex = lerp(vertex, uvVertex, _DebugUVs);

    return vertex;
}
