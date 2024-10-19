Shader "CPM/Mobile Specular Detail"
{
    Properties
    {
        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
        _Shininess ("Shininess", Range (0.01, 1)) = 0.078125
        _MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
        _BumpMap ("Normal map (RGB Trans)", 2D) = "bump" {}
        _SpecTex ("_SpecTex", 2D) = "white" {}
        _SpecularPower("Specular Power",Float) = 4
        _DiffusePower("Diffuse Power",Float) = 1.4
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 400

        CGPROGRAM
        #pragma surface surf BlinnPhong vertex:vert// finalcolor:mycolor nofog
        #pragma multi_compile_fog
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SpecTex;
        sampler2D _BumpMap;
        half _Shininess;
        half _SpecularPower;
        half _DiffusePower;
        fixed _depth;

        struct Input
        {
            fixed4 vertex;
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 customUV;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.customUV = v.texcoord.xy * 70;
            o.vertex = v.vertex;
        }


        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 tex = tex2D(_MainTex, IN.uv_MainTex);
            half4 s_tex = tex2D(_SpecTex, IN.uv_MainTex);

            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Albedo = tex.rgb * _DiffusePower;
            o.Gloss = s_tex.rgb * tex.a * _SpecularPower;
            o.Specular = clamp(s_tex.rgb, 0.0001, 0.9999) * _Shininess;
            _depth = distance(mul(unity_ObjectToWorld, IN.vertex), _WorldSpaceCameraPos);
        }

        void mycolor (Input IN, SurfaceOutput o, inout fixed4 color)
        {
            fixed fogFactor = 0;

#if defined(FOG_LINEAR)
            fogFactor = _depth * unity_FogParams.z + unity_FogParams.w;
#elif defined(FOG_EXP)
            fogFactor = unity_FogParams.y * _depth;
            fogFactor = exp2(-fogFactor);
#elif defined(FOG_EXP2)
            fogFactor = unity_FogParams.x * _depth;
            fogFactor = exp2(-fogFactor*fogFactor);
#endif
            #if USING_FOG

            color = lerp(unity_FogColor, color, saturate(fogFactor));
            #endif
            
        }
        ENDCG
    }
   /* SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        CGPROGRAM
        #pragma surface surf BlinnPhong vertex:vert// finalcolor:mycolor nofog
        #pragma multi_compile_fog

        sampler2D _MainTex;
        half _DiffusePower;
        fixed _depth;

        struct Input
        {
            fixed4 vertex;
            float2 uv_MainTex;
            float2 customUV;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.customUV = v.texcoord.xy * 70;
            o.vertex = v.vertex;
        }


        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb * _DiffusePower;
            //_depth = distance(mul(unity_ObjectToWorld, IN.vertex), _WorldSpaceCameraPos);
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
    }*/
    Fallback "Diffuse"
}