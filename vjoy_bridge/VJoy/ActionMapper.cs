namespace VJoy
{
    public static class ActionMapper
    {
        public static void Tap(VJoyManager vjoy, string action)
        {
            vjoy.TapButton(ButtonMap.Get(action));
        }

        public static void HoldStart(VJoyManager vjoy, string action)
        {
            vjoy.SetButton(ButtonMap.Get(action), true);
        }

        public static void HoldEnd(VJoyManager vjoy, string action)
        {
            vjoy.SetButton(ButtonMap.Get(action), false);
        }
    }
}
