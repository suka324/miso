﻿Shader "custom/ForceField"
{
	Properties
	{
		_Color("Color", Color) = (0,0,0,0)
		_NoiseTex("NoiseTexture", 2D) = "white" {}
		_DistortStrength("DistortStrength", Range(0,1)) = 0.2
		_DistortTimeFactor("DistortTimeFactor", Range(0,1)) = 0.2
		_RimStrength("RimStrength",Range(0, 10)) = 2
		_IntersectPower("IntersectPower", Range(0, 3)) = 2
		_CullTex("CullTexture", 2D) = "white" {}
		_Range("Range", Range(0,100)) = 1.0
	}

	SubShader
	{
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		GrabPass
		{
			"_GrabTempTex"
		}

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
				float4 grabPos : TEXCOORD2;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD3;
			};

			sampler2D _GrabTempTex;
			float4 _GrabTempTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _DistortStrength;
			float _DistortTimeFactor;
			float _RimStrength;
			float _IntersectPower;
			float _Range;

			sampler2D _CameraDepthTexture;
			sampler2D _CullTex;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.grabPos = ComputeGrabScreenPos(o.vertex);

				o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);

				o.screenPos = ComputeScreenPos(o.vertex);

				COMPUTE_EYEDEPTH(o.screenPos.z);

				o.normal = UnityObjectToWorldNormal(v.normal);

				o.viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));

				return o;
			}

			fixed4 _Color;

			fixed4 frag(v2f i) : SV_Target
			{
				// 色
				float3 viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, i.vertex)));
				float glow = 1 - abs(dot(i.normal, normalize(i.viewDir))) * _RimStrength;

				// 歪み
				float4 offset = tex2D(_NoiseTex, i.uv - _Time.xy * _DistortTimeFactor);
				i.grabPos.xy -= offset.xy * _DistortStrength;
				fixed4 color = tex2Dproj(_GrabTempTex, i.grabPos);

				// 結果
				fixed4 col = _Color * glow + color;

				// 強さを指定
				float2 p0 = float2(0.0f, 0.0f);
				float2 p1 = float2(1.0f, 0.0f);
				float2 p2 = float2(1.0f, 1.0f);
				float t = _Range * 0.01f;
//				float x = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
				float y = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;

				//  一定ならこっち
//				col.a = _Range * 0.01f;
				col.a = y;	

				// 特定のオブジェクトは反映させない(カリングテクスチャ)
				float2 uv2 = i.uv;
				uv2.y = 1.0f - uv2.y;
				uv2.y = abs(uv2.y);
				if (tex2D(_CullTex, uv2).a >= 0.01f)
				{
					col.a = 0.0f;
				}
	
				return col;
			}
			ENDCG
		}
	}
}