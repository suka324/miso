Shader "Custom/SearchShader" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Range("Range", Range(0,100)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _Range;

		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutputStandard o)
		{				
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;

			/* 球
				float dis = distance(IN.worldPos, float3(0, 0, 0));
				if (dis < _Range)
				{
					o.Albedo += fixed3(1, 0, 0);
				}
				*/

			// ボックスの内側
			float3 dis = IN.worldPos - float3(0, 0, 0);		// 中心座標からの距離
			if (abs(dis.x) < _Range && 
				abs(dis.y) < _Range && 
				abs(dis.z) < _Range)
			{				
				float gray = c.r * 0.3 + c.g * 0.6 + c.b * 0.1;
				o.Albedo = o.Albedo * 0.2f +
					fixed3(gray, gray, gray) * 0.675f +
					fixed3(0.0f, 0.0f, 1.0f) * 0.125f;
			}
		}
		ENDCG
	}
	FallBack "Diffuse"
}
