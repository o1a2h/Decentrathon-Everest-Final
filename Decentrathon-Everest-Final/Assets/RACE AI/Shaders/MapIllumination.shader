Shader "CPM/Self-Illumin/Diffuse"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Illum ("Illumin (R)", 2D) = "white" {}
		[HDR] _EmissionColor ("Illumin Color", Color) = (1,1,1,1)
		_Emission ("Emission (Lightmapper)", Float) = 1.0
		[Toggle(LIGHTS_ON)] _LightsOn("Enable lights", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf BlinnPhong fullforwardshadows vertex:vert //finalcolor:mycolor nofog
        #pragma multi_compile_fog
		#pragma multi_compile _ LIGHTS_ON

		sampler2D _MainTex;
		sampler2D _Illum;
		fixed4 _Color;
		fixed _Emission;
		fixed4 _EmissionColor;
        fixed _depth;

		struct Input
		{
            fixed4 vertex;
			float2 uv_MainTex;
			float2 uv_Illum;
		};

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.vertex = v.vertex;
        }

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
#if LIGHTS_ON
			o.Emission = c.rgb * tex2D(_Illum, IN.uv_Illum).r * _EmissionColor;
	#if defined (UNITY_PASS_META)
			o.Emission *= _Emission.rrr;
	#endif
#endif
			o.Alpha = c.a;

			_depth = distance(mul(unity_ObjectToWorld, IN.vertex), _WorldSpaceCameraPos);
		}

		/*void mycolor (Input IN, SurfaceOutput o, inout fixed4 color)
		{
			fixed fogFactor = 1;

#if defined(FOG_LINEAR)
			fogFactor = _depth * unity_FogParams.z + unity_FogParams.w;
#elif defined(FOG_EXP)
			fogFactor = unity_FogParams.y * _depth;
			fogFactor = exp2(-fogFactor);
#elif defined(FOG_EXP2)
			fogFactor = unity_FogParams.x * _depth;
			fogFactor = exp2(-fogFactor*fogFactor);
#endif

			color = lerp(unity_FogColor, color, saturate(fogFactor));
		}*/
ENDCG
}
FallBack "Legacy Shaders/Self-Illumin/VertexLit"
CustomEditor "LegacyIlluminShaderGUI"
}