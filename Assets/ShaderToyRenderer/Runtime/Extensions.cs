using UnityEngine;

namespace ShaderToyRenderer
{
    public static class Extensions
    {
        public static void Clear(this RenderTexture rt, Color color)
        {
            var old = RenderTexture.active;
            RenderTexture.active = rt;
            if (rt)
            {
                GL.Clear(true, true, color);
            }

            RenderTexture.active = old;
        }
    }
}