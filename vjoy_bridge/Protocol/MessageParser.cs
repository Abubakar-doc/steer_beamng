using System.Globalization;
using VJoy;

namespace Protocol
{
    public static class MessageParser
    {
        public static void Parse(string msg, VJoyManager vjoy)
        {
            if (double.TryParse(msg, NumberStyles.Float,
                CultureInfo.InvariantCulture, out var steer))
            {
                vjoy.SetSteer(steer);
                return;
            }

            if (msg.StartsWith("THR:") &&
                double.TryParse(msg[4..], out var t))
                vjoy.SetThrottle(t);

            else if (msg.StartsWith("BRK:") &&
                double.TryParse(msg[4..], out var b))
                vjoy.SetBrake(b);

            else if (msg.StartsWith("CAMX:") &&
                double.TryParse(msg[5..], out var cx))
                vjoy.SetCamX(cx);

            else if (msg.StartsWith("CAMY:") &&
                double.TryParse(msg[5..], out var cy))
                vjoy.SetCamY(cy);

            else if (msg.StartsWith("GEAR:") &&
                int.TryParse(msg[5..], out var g))
                vjoy.SetGear(g);

            else if (msg.StartsWith("HB:"))
                vjoy.SetHandbrake(msg[3..] == "1");

            else if (msg.StartsWith("ACT_HOLD_START:"))
                vjoy.SetButton(ButtonMap.Get(msg[15..]), true);

            else if (msg.StartsWith("ACT_HOLD_END:"))
                vjoy.SetButton(ButtonMap.Get(msg[13..]), false);

            else if (msg.StartsWith("ACT:"))
                vjoy.TapButton(ButtonMap.Get(msg[4..]));
        }
    }
}
