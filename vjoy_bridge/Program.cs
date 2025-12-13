using System;
using System.Threading;
using Core;
using Network;
using VJoy;

class Program
{
    static void Main()
    {
        Logger.Info("=== Steer Beamng Server ===");

        var vjoy = new VJoyManager();

        // ---- vJoy preflight check ----
        if (!vjoy.Init())
        {
            Logger.Error("vJoy driver is NOT enabled!");
            Logger.Info("Search and Open: Configure vJoy");
            Logger.Info("• Enable Device");
            Logger.Info("• Set Buttons = 128");
            Logger.Info("• Click Apply");
            Logger.Info("• Restart Steer Beamng");
            Logger.Info("• Enjoy :)");
            Console.ReadKey();
            return;
        }

        Logger.Success("vJoy OK");

        var udp = new UdpServer();
        udp.Start(vjoy);

        Logger.Success($"Listening on UDP {AppConfig.Port} ({AppConfig.PcName})");

        Thread.Sleep(Timeout.Infinite);
    }
}
