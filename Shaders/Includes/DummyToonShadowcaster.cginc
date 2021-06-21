#include "UnityCG.cginc"
#include "AutoLight.cginc"

#if defined(_ALPHATEST_ON)
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float _Cutoff;
#endif

#if defined(_VERTEXOFFSET_ON)
	float3 _VertexOffsetPos;
	float3 _VertexOffsetRot;
	float3 _VertexOffsetScale;
	float3 _VertexOffsetPosWorld;
#endif

struct VertexInputShadow {
	float4 vertex : POSITION;
	float2 texcoord0 : TEXCOORD0;
};

struct VertexOutputShadow {
	V2F_SHADOW_CASTER;
	float2 uv0 : TEXCOORD1;
};

// Code below copypasted from vertex offset section, except the parameter was modified to use VertexInputShadow
#if defined(_VERTEXOFFSET_ON)
	inline float3x3 xRotation3dRadiansShadow(float rad) {
		float s = sin(rad);
		float c = cos(rad);
		return float3x3(
			1, 0, 0,
			0, c, s,
			0, -s, c);
	}

	inline float3x3 yRotation3dRadiansShadow(float rad) {
		float s = sin(rad);
		float c = cos(rad);
		return float3x3(
			c, 0, -s,
			0, 1, 0,
			s, 0, c);
	}

	inline float3x3 zRotation3dRadiansShadow(float rad) {
		float s = sin(rad);
		float c = cos(rad);
		return float3x3(
			c, s, 0,
			-s, c, 0,
			0, 0, 1);
	}

	void VertexOffset(inout VertexInputShadow v)
	{
		//Apply scale
		v.vertex.xyz *= _VertexOffsetScale;

		// Apply rotation
		float3 vertexPos = v.vertex.xyz;
		vertexPos = mul(xRotation3dRadiansShadow(radians(_VertexOffsetRot.x)), vertexPos);
		vertexPos = mul(yRotation3dRadiansShadow(radians(_VertexOffsetRot.y)), vertexPos);
		vertexPos = mul(zRotation3dRadiansShadow(radians(_VertexOffsetRot.z)), vertexPos);
		v.vertex = float4(vertexPos, v.vertex.w);

		//Apply local offset
		v.vertex.xyz += _VertexOffsetPos;
		
		// Convert to world space, apply world offset, convert back.
		float4 worldPosition = mul(unity_ObjectToWorld, v.vertex);
		worldPosition.xyz += _VertexOffsetPosWorld;
		v.vertex = mul(unity_WorldToObject, worldPosition);
	}
#endif

// Vert shader
VertexOutputShadow vertShadow (VertexInputShadow v) {
	// If vertex offset is enabled, apply that first
	#if defined(_VERTEXOFFSET_ON)
		VertexOffset(v);
	#endif

	VertexOutputShadow o = (VertexOutputShadow)0;
	o.uv0 = v.texcoord0;                
	o.pos = UnityObjectToClipPos(v.vertex);
	TRANSFER_SHADOW_CASTER(o)
	return o;
}

float4 fragShadow(VertexOutputShadow i, float facing : VFACE) : COLOR {
	#if defined(_ALPHATEST_ON)
		float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
		float SurfaceAlpha = _MainTex_var.a;
		clip(SurfaceAlpha - _Cutoff);
	#endif
	SHADOW_CASTER_FRAGMENT(i)
}
