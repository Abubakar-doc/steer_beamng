using System.Net;
using System.Net.Sockets;
using System.Text;
using Core;

namespace Protocol
{
    public static class DiscoveryHandler
    {
        public static bool Handle(UdpClient udp, IPEndPoint ep, string msg)
        {
            if (msg == "DISCOVER_SERVER")
            {
                var reply = $"SERVER_HERE:{AppConfig.PcName}";
                udp.Send(Encoding.UTF8.GetBytes(reply), ep);
                return true;
            }

            if (msg == "PING")
            {
                udp.Send(Encoding.UTF8.GetBytes("PONG"), ep);
                return true;
            }

            return false;
        }
    }
}
