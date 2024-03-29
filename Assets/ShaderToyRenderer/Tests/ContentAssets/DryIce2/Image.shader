Shader "ShaderToy/Dry Ice 2/Image"
{
    Properties
    {
        iChannel0 ("Texture", 2D) = "white" {}
        iChannel1 ("Texture", 2D) = "white" {}

        iMouse("Click pos",Vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "../../../Runtime/Shaders/ShaderToyBase.hlsl"
            #include "./Common.hlsl"

            #pragma vertex vert
            #pragma fragment frag


            #define RENDER3D	0

            // #if  RENDER3D


            float sceneIntersection(in vec3 ro, in vec3 rd, out vec3 inter, out vec3 normal, out vec3 color,
                                    in float dist, out vec3 lightPos)
            {
                float mint = dist;
                inter = vec3(0, 0, 0);
                normal = vec3(0, 0, 0);
                color = vec3(0, 0, 0);
                float dissipation = 0.95;

                float ballRadius = 0.06;
                float fogHeigth = .24; //ballRadius * 4.;
                // int	nbSlice			= 24;
                float fogSlice = .01; //fogHeigth / float(nbSlice);
                int nbSphere = 3;
                float shadowDensity = 25.;
                float fogDensity = 20.;
                float lightHeight = 1.;
                // Spheres
                for (int i = 0; i < nbSphere; i++)
                {
                    vec2 p2d = spherePosition(i, iFrame);
                    vec3 pos = vec3(p2d.x, ballRadius, p2d.y);
                    vec3 ballColor = vec3(1, 0, 0);
                    if (i == 0)
                    {
                        ballColor = vec3(1, 1, 1);
                        lightPos = pos + vec3(0, lightHeight, 0);
                    }

                    float t = sphIntersect(ro, rd, pos, ballRadius).x;
                    if (t > 0. && t < mint)
                    {
                        mint = t;
                        inter = (ro + mint * rd);
                        normal = normalize(inter - pos);
                        color = ballColor;
                    }
                }

                // Floor
                {
                    float aspecRatio = iResolution.x / iResolution.y;
                    vec3 boxNormal;
                    float t = boxIntersection(ro, rd, vec3(aspecRatio, 0.1, 1), vec3(0, -0.1, 0), boxNormal).x;
                    if (t > 0. && t < mint)
                    {
                        mint = t;
                        inter = (ro + mint * rd);
                        normal = boxNormal;
                        ivec2 tileId = ivec2(vec2(inter.x, inter.z) * 3. + 100.);
                        color = ((tileId.x & 1) ^ (tileId.y & 1)) == 0 ? vec3(0.3, 0.3, 0.3) : vec3(0.15, 0.15, 0.15);
                    }
                }
                return mint;
            }

            float sampleFog(in vec3 pos)
            {
                vec2 uv = pos.xz;
                uv.x *= iResolution.y / iResolution.x;
                uv = uv * 0.5 + 0.5;
                if (max(uv.x, uv.y) > 1. || min(uv.x, uv.y) < 0.)
                {
                    return 0.;
                }
                return texture(iChannel0, uv).z;
            }

            vec3 Render(in vec3 ro, in vec3 rd, in float dist, float fudge)
            {
                vec3 inter;
                vec3 normal;
                vec3 baseColor;
                vec3 lightPos;
                float mint = sceneIntersection(ro, rd, inter, normal, baseColor, dist, lightPos);

                vec3 color = vec3(0, 0, 0);
                float ballRadius = 0.06;
                float fogHeigth = .24; //ballRadius * 4.;
                int nbSlice = 24;
                float fogSlice = .01; //fogHeigth / float(nbSlice);
                int nbSphere = 3;
                float shadowDensity = 25.;
                float fogDensity = 20.;
                float lightHeight = 1.;

                if (mint < dist)
                {
                    vec3 lightDir = normalize(lightPos - inter);
                    float lightDist2 = dist2(lightPos - inter);
                    vec3 shadowStep = (fogHeigth / float(nbSlice)) * lightDir / lightDir.y;
                    float shadowDist = 0.;
                    for (int i = 0; i < nbSlice; i++)
                    {
                        vec3 shadowPos = inter + shadowStep * float(i);
                        float v = sampleFog(shadowPos) * fogHeigth;
                        shadowDist += min(max(0., v - shadowPos.y), fogSlice) * length(shadowStep) / fogSlice;
                    }
                    float shadowFactor = exp(-shadowDist * shadowDensity * 0.25);
                    color = baseColor * (max(0., dot(normal, lightDir) * shadowFactor) + 0.2) / lightDist2;
                }
                else
                {
                    color = vec3(0, 0, 0);
                }


                // Compute Fog
                float t;
                if (floorIntersect(ro, rd, fogHeigth, t))
                {
                    vec3 curPos = ro + rd * t;
                    vec3 fogStep = (fogHeigth / float(nbSlice)) * rd / abs(rd.y);
                    curPos += fudge * fogStep; // fix banding issue
                    float stepLen = length(fogStep);
                    float curDensity = 0.;
                    float transmittance = 1.;
                    float lightEnergy = 0.;
                    [unroll(88)]
                    for (int i = 0; i < nbSlice; i++)
                    {
                        if (dot(curPos - ro, rd) > mint)
                            break;
                        float curHeigth = sampleFog(curPos) * fogHeigth;
                        float curSample = min(max(0., curHeigth - curPos.y), fogSlice) * stepLen / fogSlice;
                        if (curSample > 0.001)
                        {
                            vec3 lightDir = normalize(lightPos - curPos);
                            vec3 shadowStep = (fogHeigth / float(nbSlice)) * lightDir / lightDir.y;
                            float lightDist2 = dist2(lightPos - curPos);
                            vec3 shadowPos = curPos + shadowStep * fudge;
                            float shadowDist = 0.;

                            for (int j = 0; j < nbSlice; j++)
                            {
                                shadowPos += shadowStep;
                                if (shadowPos.y > fogHeigth)
                                {
                                    break;
                                }
                                float curHeight = sampleFog(shadowPos) * fogHeigth;
                                shadowDist += min(max(0., curHeight - shadowPos.y), fogSlice) * length(shadowStep) /
                                    fogSlice;
                            }


                            float shadowFactor = exp(-shadowDist * shadowDensity) / lightDist2;
                            curDensity = curSample * fogDensity;
                            float absorbedlight = shadowFactor * (1. * curDensity);
                            lightEnergy += absorbedlight * transmittance;
                            transmittance *= 1. - curDensity;
                        }
                        curPos += fogStep;
                    }
                    color = mix(color, vec3(lightEnergy, lightEnergy, lightEnergy), 1. - transmittance);
                }


                return color;
            }

            vec3 vignette(vec3 color, vec2 q, float v)
            {
                color *= 0.3 + 0.8 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), v);
                return color;
            }

            mat3 setCamera(in vec3 ro, in vec3 ta)
            {
                vec3 cw = normalize(ta - ro);
                vec3 up = vec3(0, 1, 0);
                vec3 cu = normalize(cross(cw, up));
                vec3 cv = normalize(cross(cu, cw));
                return mat3(cu, cv, cw);
            }

            float4 frag(v2f i) : SV_Target
            {
                vec2 uv = i.uv;
                vec2 fragCoord = uv * iResolution.xy;

                #if RENDER3D
                vec3 tot = vec3(0.0, 0, 0);

                vec2 rook[4];
                rook[0] = vec2(1. / 8., 3. / 8.);
                rook[1] = vec2(3. / 8., -1. / 8.);
                rook[2] = vec2(-1. / 8., -3. / 8.);
                rook[3] = vec2(-3. / 8., 1. / 8.);
                for (int n = 0; n < 4; ++n)
                {
                    // pixel coordinates
                    vec2 o = rook[n];
                    vec2 p = (-iResolution.xy + 2.0 * (fragCoord + o)) / iResolution.y;

                    // camera       
                    float theta = radians(360.) * (iMouse.x / iResolution.x - 0.5) - radians(90.);
                    float phi = -radians(30.);
                    vec3 ro = 2. * vec3(sin(phi) * cos(theta), cos(phi), sin(phi) * sin(theta));
                    vec3 ta = vec3(0, 0, 0);
                    // camera-to-world transformation
                    mat3 ca = setCamera(ro, ta);

                    vec3 rd = mul(ca, normalize(vec3(p, 1.5)));
                    vec3 col = Render(ro, rd, 6., hash12(fragCoord + iTime));


                    tot += col;
                }
                tot /= 4.;
                tot = vignette(tot, fragCoord / iResolution.xy, 0.6);
                half4 fragColor = vec4(sqrt(tot), 1.0);

                #else
                half c = texelFetch(iChannel0, fragCoord, 0).z;
                half4 fragColor = vec4(vec3(c, c, c), 1);

                #endif

                return fragColor;
            }
            ENDHLSL
        }
    }
}