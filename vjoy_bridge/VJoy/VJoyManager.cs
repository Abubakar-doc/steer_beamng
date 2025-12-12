using System;
using System.Threading;
using vJoyInterfaceWrap;

namespace VJoy
{
    public class VJoyManager
    {
        private const uint ID = 1;

        public bool Init()
        {
            if (!vJoy.vJoyEnabled()) return false;
            return vJoy.AcquireVJD(ID);
        }

        public void SetSteer(double v) =>
            vJoy.SetAxis(ToAxis(v), ID, HID_USAGES.HID_USAGE_X);

        public void SetThrottle(double v) =>
            vJoy.SetAxis(ToAxis01(v), ID, HID_USAGES.HID_USAGE_SL0);

        public void SetBrake(double v) =>
            vJoy.SetAxis(ToAxis01(v), ID, HID_USAGES.HID_USAGE_SL1);

        public void SetCamX(double v) =>
            vJoy.SetAxis(ToAxis(v), ID, HID_USAGES.HID_USAGE_RX);

        public void SetCamY(double v) =>
            vJoy.SetAxis(ToAxis(v), ID, HID_USAGES.HID_USAGE_RY);

        public void SetHandbrake(bool on) =>
            vJoy.SetBtn(on, ID, 11);

        public void SetGear(int g)
        {
            g = Math.Clamp(g, 1, 10);
            for (uint i = 1; i <= 10; i++)
                vJoy.SetBtn(false, ID, i);

            vJoy.SetBtn(true, ID, (uint)g);
        }

        public void TapButton(uint button)
        {
            if (button == 0) return;
            vJoy.SetBtn(true, ID, button);
            Thread.Sleep(60);
            vJoy.SetBtn(false, ID, button);
        }

        public void SetButton(uint button, bool state)
        {
            if (button != 0)
                vJoy.SetBtn(state, ID, button);
        }

        private static int ToAxis(double v) =>
            (int)((Math.Clamp(v, -1, 1) + 1) * 16383.5);

        private static int ToAxis01(double v) =>
            (int)(Math.Clamp(v, 0, 1) * 32767);
    }
}
