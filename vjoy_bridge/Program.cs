using Core;
using Network;
using VJoy;

class Program
{
    static void Main()
    {
        Logger.Info("=== vJoy Bridge Starting ===");

        var vjoy = new VJoyManager();
        if (!vjoy.Init()) return;

        var udp = new UdpServer();
        udp.Start(vjoy);

        Logger.Success($"Listening on UDP {AppConfig.Port} ({AppConfig.PcName})");

        Thread.Sleep(Timeout.Infinite);
    }
}
