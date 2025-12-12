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

        public void Start(VJoyManager vjoy)
        {
            while (true)
            {
                IPEndPoint remote = new(IPAddress.Any, 0); // 🔴 NOT readonly
                var data = _udp.Receive(ref remote);
                var msg = Encoding.UTF8.GetString(data).Trim();

                if (DiscoveryHandler.Handle(_udp, remote, msg))
                    continue;

                MessageParser.Parse(msg, vjoy);
            }
        }
    }
}
