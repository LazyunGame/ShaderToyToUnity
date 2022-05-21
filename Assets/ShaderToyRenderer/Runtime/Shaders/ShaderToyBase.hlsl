#ifndef SHADERTOY_BASE
#define SHADERTOY_BASE
#endif


/********** ShaderToy Inputs ************/
#define iResolution _ScreenParams
#define iTime _Time.y
#define iChannelTime _Time.y
#define iChannelResolution _ScreenParams
#define iTimeDelta unity_DeltaTime.x
/****************************************/

/****************************************/
#define PI 3.14159265358

#define mix lerp
#define vec2 float2
#define vec3 float3
#define vec4 float4
#define fract frac
#define mat2 float2x2
#define mat3 float3x3
#define mat4 float4x4
#define dFdx ddx
#define dFdy ddy
vec4 texelFetch(sampler2D samp,vec2 p, int lod)
{
    return tex2Dlod(samp, float4(p, 0, lod));
}

vec4 textureLod(sampler2D samp,vec2 p, float lod)
{
    return tex2Dlod(samp, float4(p, 0, lod));
}

#define texture tex2D
/*****************************************/

// float4 textureLod(sampler2D sp,float2 uv,float level)
// {
//     return tex2Dlod(sp,float4(uv,level,level));
// }
//
// float4 texelFetch(sampler2D sp,float2 iuv,float4 texelSize)
// {
//     float2 uv = (floor(iuv * texelSize.zw) + 0.5) * texelSize.xy;
//     return tex2Dlod(sp, float4(uv, 0, 0));
// }

float atan(float y, float x)
{
    return atan(y / x);
}

float mod(float a, float b)
{
    return a - b * floor(a / b);
}

float2 mod(float2 a, float2 b)
{
    return a - b * floor(a / b);
}

float pingPong(float v)
{
    const float amplitude = 1.;
    const float t = PI * 2.0;
    float k = 4.0 * amplitude / t;
    float r = mod(v, t);
    float d = floor(v / (0.5 * t));
    return mix(k * r - amplitude, amplitude * 3. - k * r, mod(d, 2.0));
}

float circle(vec2 dist, float _radius)
{
    return 1. - smoothstep(_radius - (_radius * 0.01),
                           _radius + (_radius * 0.01),
                           dot(dist, dist) * 4.0);
}

vec2 hash(vec2 p)
{
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1. + 2. * fract(sin(p) * 53758.5453123);
}

vec2 noise(vec2 tc)
{
    return hash(tc);
}


// http://iquilezles.org/www/articles/palettes/palettes.htm
// https://www.shadertoy.com/view/ll2GD3
vec3 colorPalette(float t, vec3 a, vec3 b, vec3 c, vec3 d)
{
    return a + b * cos(PI * 2. * (c * t + d));
}


float3 rgb2hsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 hsv2rgb(float3 c)
{
    c = float3(c.x, clamp(c.yz, 0.0, 1.0));
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


float4 hsv2rgb(float3 c, float a)
{
    return float4(hsv2rgb(c), a);
}
