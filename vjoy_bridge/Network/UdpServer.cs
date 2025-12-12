using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using Core;
using Protocol;
using VJoy;

namespace Network
{
    public class UdpServer
    {
        private readonly UdpClient _udp = new(AppConfig.Port)
        {
            EnableBroadcast = true
        };

        private bool _showLogs = false;

public void Start(VJoyManager vjoy)
{
    Console.WriteLine($"📡 UDP Server listening on :{AppConfig.Port}");

    var monitor = new ClientMonitor();

    while (true)
    {
        IPEndPoint remote = new(IPAddress.Any, 0);
        var data = _udp.Receive(ref remote);
        var msg = Encoding.UTF8.GetString(data).Trim();

        monitor.Ping(remote);   // ✅ ONLY this

        if (_showLogs)
            Console.WriteLine($"[CMD] {msg}");

        if (DiscoveryHandler.Handle(_udp, remote, msg))
            continue;

        MessageParser.Parse(msg, vjoy);
    }
}

    }
}
