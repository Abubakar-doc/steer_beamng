using System.Collections.Generic;

namespace VJoy
{
    public static class ButtonMap
    {
        private static readonly Dictionary<string, uint> Map = new()
        {
            ["FIX"] = 12,
            ["FLIP"] = 13,
            ["MODE"] = 14,
            ["IGN"] = 15,
            ["FOG"] = 16,
            ["HEAD"] = 17,
            ["HORN"] = 18,
            ["LEFT"] = 19,
            ["HAZ"] = 20,
            ["RIGHT"] = 21,
            ["DIFF"] = 22,
            ["ESC"] = 23,
            ["4WD"] = 24,
            ["FLASH"] = 25,
            ["CAMRESET"] = 26,
            ["CAMZOOMIN"] = 27,
            ["CAMZOOMOUT"] = 28,
            ["CAMCHANGE"] = 29,
            ["CAMBEHIND"] = 30,
        };

        public static uint Get(string action) =>
            Map.TryGetValue(action, out var btn) ? btn : 0;
    }
}
