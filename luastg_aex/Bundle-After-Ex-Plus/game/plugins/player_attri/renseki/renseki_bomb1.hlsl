// 引擎参数

SamplerState screen_texture_sampler : register(s4); // RenderTarget 纹理的采样器
Texture2D screen_texture            : register(t4); // RenderTarget 纹理
cbuffer engine_data : register(b1)
{
    float4 screen_texture_size; // 纹理大小
    float4 viewport;            // 视口
};

// 用户传递的参数

cbuffer user_data : register(b0)
{
    float4 center_pos;   // 指定效果的中心坐标
    //float4 effect_color; // 指定效果的中心颜色,着色时使用colorburn算法 //to be deprecated
    float4 effect_param; // 多个参数：effect_size 指定效果的影响大小、effect_arg 变形系数、effect_color_size 颜色的扩散大小、timer 外部计时器
};

#define effect_size       effect_param.x
//#define effect_arg        effect_param.y//to be deprecated
//#define effect_color_size effect_param.z//to be deprecated
#define timer             effect_param.y

static const float PI=3.1415926535;


// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd

// 随机函数，根据输入返回 [0,1) 范围内的随机数
// float random(float2 st)
// {
//     return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453123);
// }

// float noise(float2 st)
// {
//     float2 i = floor(st);
//     float2 f = frac(st);

//     float a = random(i);
//     float b = random(i + float2(1.0, 0.0));
//     float c = random(i + float2(0.0, 1.0));
//     float d = random(i + float2(1.0, 1.0));

//     float2 u = f * f * (3.0 - 2.0 * f);

// 	return lerp(a, b, u.x) +
//             (c - a)* u.y * (1.0 - u.x) +
//             (d - b) * u.x * u.y;
// }

// #define OCTAVES 6
// float fbm(float2 st)
// {
//     float value = 0.0;
//     float amplitude = 0.5;
//     float frequency = 0.0; // 保留原代码中的变量，实际未使用

//     for (int i = 0; i < OCTAVES; i++)
//     {
//         value += amplitude * noise(st);
//         st *= 2.0;
//         amplitude *= 0.5;
//     }
//     return value;
// }

//fbm 3d

float hash3D(float3 p) {
    return frac(sin(dot(p, float3(12.9898, 78.233, 45.164))) * 43758.5453);
}

float noise3D(float3 p) {
    float3 i = floor(p);
    float3 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);

    float n000 = hash3D(i);
    float n100 = hash3D(i + float3(1, 0, 0));
    float n010 = hash3D(i + float3(0, 1, 0));
    float n110 = hash3D(i + float3(1, 1, 0));
    float n001 = hash3D(i + float3(0, 0, 1));
    float n101 = hash3D(i + float3(1, 0, 1));
    float n011 = hash3D(i + float3(0, 1, 1));
    float n111 = hash3D(i + float3(1, 1, 1));

    float res = lerp(
        lerp(lerp(n000, n100, f.x), lerp(n010, n110, f.x), f.y),
        lerp(lerp(n001, n101, f.x), lerp(n011, n111, f.x), f.y),
        f.z
    );

    return res;
}

float fbm3D(float3 p) {
    float f = 0.0;
    float w = 0.5;
    for (int i = 0; i < 4; i++) {
        f += w * noise3D(p);
        p = p * 2.0 + 100.0;
        w *= 0.5;
    }
    return f;
}

struct PS_Input
{
    float4 sxy : SV_Position;
    float2 uv  : TEXCOORD0;
    float4 col : COLOR0;
};
struct PS_Output
{
    float4 col : SV_Target;
};

PS_Output main(PS_Input input)
{
    // PS_Output test;
    // test.col = input.col;
    // return test;

    float2 xy = input.uv * screen_texture_size.xy;  // 屏幕上真实位置
    if (xy.x < viewport.x || xy.x > viewport.z || xy.y < viewport.y || xy.y > viewport.w)
    {
        discard; // 抛弃不需要的像素，防止意外覆盖画面
    }
    float2 uv2 = input.uv;
    float2 delta = xy - center_pos.xy;  // 计算效果中心到纹理采样点的向量
    float delta_len = length(delta);
    delta = normalize(delta);

    float4 tex_color = screen_texture.Sample(screen_texture_sampler, input.uv);
    float4 result = tex_color;
    if(delta_len <= effect_size)
    {    
        //line part
        float r=delta_len;
        float standard=(viewport.w-viewport.y)/2;
        r=r/standard;
        float es=effect_size/standard;

        float a=atan2(xy.y-center_pos.y,xy.x-center_pos.x);
        
        float ca_bar=a*3+timer*2-4*r;
        float ca=a*3+timer*(-1.1)+4*r;
        float cr=pow(r,2);
        float base=fbm3D(float3(cos(ca),sin(ca),cr+3*timer));
        base=(1-cos(PI*base*base))/2;

        float base2=fbm3D(float3(cos(ca_bar),sin(ca_bar),cr+4*timer));
        base2=(1-cos(PI*base2*base2))/2;

        float4 mask=float4(0.0,0.6,0.9,1);
        float4 mask2=float4(0.4,0.0,0.9,1);
        float weight=1-smoothstep(0,es,sqrt(r*es));
        float weight1=1-smoothstep(0,es,sqrt(r*es));
        
        result=result+max(weight,0)*float4(0.05,0.4,0.8,1);
        result=result+base*mask*weight1;
        result=result+base2*mask2*(weight);
        //solid part
        float la=a;
        float base3=fbm3D(float3(cos(la),sin(la),cr*2+4*timer));
        result=result+weight*base3*float4(0.4,0,0.8,1);

        //light line
        float base4=fbm3D(float3(cos(13*a),sin(7*a),cr*1.7+timer*5));
        base4=(1-cos(PI*base4*base4))/2;
        base4=(1-cos(PI*base4))/2;

        float weight4=1-smoothstep(0,es-0.10,r);
        result=result+base4*float4(0,0.1,0.7,1)*(weight4);

        result=min(result,float4(1,1,1,1));
    }
    PS_Output output;
    output.col = result;
    return output;
}