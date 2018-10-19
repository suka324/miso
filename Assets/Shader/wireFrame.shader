Shader "Custom/Wireframe"
{
	Properties
	{
		[PowerSlider(3.0)]
		_WireframeVal("Wireframe width", Range(0., 0.5)) = 0.05
		_Color("color", color) = (1, 1, 1, 1)
		_WireColor("WireColor", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_Range("Range", Range(0,100)) = 1.0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
			"ForceNoShadowCasting" = "True"
			"LightMode" = "ForwardBase"
		}

		// 1pass wire
		Pass
		{

			Cull off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom

			// Change "shader_feature" with "pragma_compile" if you want set this keyword from c# code
			#pragma shader_feature __ _REMOVEDIAG_ON

			#include "UnityCG.cginc"

			struct v2g {
				float4 worldPos : SV_POSITION;
			};

			struct g2f {
				float4 pos : SV_POSITION;
				float3 bary : TEXCOORD0;
				float4 worldPos : POSITION1;
			};

			v2g vert(appdata_base v) {
				v2g o;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream) {
				float3 param = float3(0., 0., 0.);

				// 斜辺消す
				float EdgeA = length(IN[0].worldPos - IN[1].worldPos);
				float EdgeB = length(IN[1].worldPos - IN[2].worldPos);
				float EdgeC = length(IN[2].worldPos - IN[0].worldPos);

				if (EdgeA > EdgeB && EdgeA > EdgeC)
					param.y = 1.;
				else if (EdgeB > EdgeC && EdgeB > EdgeA)
					param.x = 1.;
				else
					param.z = 1.;

				// 反映
				g2f o;
				o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos);
				o.worldPos = IN[0].worldPos;
				o.bary = float3(1., 0., 0.) + param;
				triStream.Append(o);
				o.pos = mul(UNITY_MATRIX_VP, IN[1].worldPos);
				o.worldPos = IN[1].worldPos;
				o.bary = float3(0., 0., 1.) + param;
				triStream.Append(o);
				o.pos = mul(UNITY_MATRIX_VP, IN[2].worldPos);
				o.worldPos = IN[2].worldPos;
				o.bary = float3(0., 1., 0.) + param;
				triStream.Append(o);
			}

			float _WireframeVal;
			fixed4 _WireColor;
			float _Range;

			fixed4 frag(g2f i) : SV_Target
			{
				float3 dis = i.worldPos - float3(0, 0, 0);		// 中心座標からの距離

				if (abs(dis.x) > _Range |
					abs(dis.y) > _Range |
					abs(dis.z) > _Range)
				{
					discard;
				}	

				if (!any(bool3(i.bary.x <= _WireframeVal, i.bary.y <= _WireframeVal, i.bary.z <= _WireframeVal)))
					discard;

				return _WireColor;
			}

			ENDCG
		}

		// 2pass mesh
		Pass
		{
			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			LOD 100
	
			Blend SrcAlpha OneMinusSrcAlpha
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;			
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float4 worldPos : POSITION1;
				UNITY_FOG_COORDS(1)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float _Range;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord) * _Color;

				float3 dis = i.worldPos - float3(0, 0, 0);		// 中心座標からの距離

				if (abs(dis.x) < _Range &&
					abs(dis.y) < _Range &&
					abs(dis.z) < _Range)
				{
					float gray = col.r * 0.3 + col.g * 0.6 + col.b * 0.1;
					col = col * 0.2f;
					col.r += gray * 0.675f;
					col.g += gray * 0.675f;
					col.b += gray * 0.675f + 0.125f;
				}

				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}		
			ENDCG
		}

/* lighting
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata_t {
				float4 pos : POSITION;
				float3 nml : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 nml : NORMAL;
				float2 uv : TEXCOORD0;
				float3 lgt : TEXCOORD2;
				float3 eye : TEXCOORD3;
			};

			fixed4 _Color;
			float	_Shininess;
			sampler2D _MainTex;
			fixed4 _MainTex_ST;

			v2f vert(appdata_t v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);			//mul(UNITY_MATRIX_MVP, float4(v.pos, 1.0)) と同等
				o.nml = UnityObjectToWorldNormal(v.nml);		//法線 mul((float3x3)UNITY_MATRIX_M, v.nml) と同等
				o.lgt = normalize(WorldSpaceLightDir(v.pos));	//ライトベクトル
				o.eye = normalize(WorldSpaceViewDir(v.pos));	//視線ベクトル
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);			//+v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw と同等
				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				float3 n = normalize(i.nml);		//法線ベクトル		※線形補完後のベクトルは単位ベクトルではないので正規化が必要
				float3 l = normalize(i.lgt);		//ライトベクトル	※線形補完後のベクトルは単位ベクトルではないので正規化が必要
													//デフューズ
				float d = saturate(dot(n,l));
				//スぺキュラ
				float3 e = normalize(i.eye);			//視線ベクトル
				float3 h = normalize(e + l);
				float specularReflection = saturate(dot(n, h));
				float s = pow(specularReflection, _Shininess);
				float lgt = d + s;
				float4 Out = _Color;
				Out.rgb *= lgt;

				Out.rgb *= tex2D(_MainTex, i.uv);
				return Out;
			}
			ENDCG
		}
		*/
	}
	Fallback "Legacy Shaders/VertexLit"
}