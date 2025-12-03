using System;
using System.Runtime.InteropServices;

namespace vJoyInterfaceWrap
{
    public enum VjdStat { VJD_STAT_OWN, VJD_STAT_FREE, VJD_STAT_BUSY, VJD_STAT_MISS, VJD_STAT_UNKN };
    public enum HID_USAGES : uint
    {
        HID_USAGE_X = 0x30,
        HID_USAGE_Y = 0x31,
        HID_USAGE_Z = 0x32,
        HID_USAGE_RX = 0x33,
        HID_USAGE_RY = 0x34,
        HID_USAGE_RZ = 0x35,
        HID_USAGE_SL0 = 0x36,
        HID_USAGE_SL1 = 0x37
    }

    public class vJoy
    {
        [DllImport("vJoyInterface.dll", EntryPoint = "vJoyEnabled")]
        public static extern bool vJoyEnabled();

        [DllImport("vJoyInterface.dll", EntryPoint = "AcquireVJD")]
        public static extern bool AcquireVJD(uint rID);

        [DllImport("vJoyInterface.dll", EntryPoint = "RelinquishVJD")]
        public static extern void RelinquishVJD(uint rID);

        [DllImport("vJoyInterface.dll", EntryPoint = "SetAxis")]
        public static extern bool SetAxis(int Value, uint rID, HID_USAGES Axis);

        [DllImport("vJoyInterface.dll", EntryPoint = "GetVJDStatus")]
        public static extern VjdStat GetVJDStatus(uint rID);
    }
}
