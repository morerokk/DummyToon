inline float3x3 xRotation3dRadians(float rad) {
	float s = sin(rad);
	float c = cos(rad);
	return float3x3(
		1, 0, 0,
		0, c, s,
		0, -s, c);
}
 
inline float3x3 yRotation3dRadians(float rad) {
	float s = sin(rad);
	float c = cos(rad);
	return float3x3(
		c, 0, -s,
		0, 1, 0,
		s, 0, c);
}
 
inline float3x3 zRotation3dRadians(float rad) {
	float s = sin(rad);
	float c = cos(rad);
	return float3x3(
		c, s, 0,
		-s, c, 0,
		0, 0, 1);
}

void VertexOffset(inout appdata v)
{
	//Apply scale
	v.vertex.xyz *= _VertexOffsetScale;

	// Apply rotation
	float3 vertexPos = v.vertex.xyz;
	vertexPos = mul(xRotation3dRadians(radians(_VertexOffsetRot.x)), vertexPos);
	vertexPos = mul(yRotation3dRadians(radians(_VertexOffsetRot.y)), vertexPos);
	vertexPos = mul(zRotation3dRadians(radians(_VertexOffsetRot.z)), vertexPos);
	v.vertex = float4(vertexPos, v.vertex.w);

	//Apply local offset
	v.vertex.xyz += _VertexOffsetPos;
	
	// Convert to world space, apply world offset, convert back.
	float4 worldPosition = mul(unity_ObjectToWorld, v.vertex);
	worldPosition.xyz += _VertexOffsetPosWorld;
	v.vertex = mul(unity_WorldToObject, worldPosition);
}
