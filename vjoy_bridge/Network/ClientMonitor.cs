using System;
using System.Net;
using System.Threading;

namespace Network
{
    public class ClientMonitor
    {
        private DateTime _last = DateTime.MinValue;
        private bool _connected = false;
        private IPEndPoint? _client;

        public ClientMonitor()
        {
            new Thread(() =>
            {
                while (true)
                {
                    Thread.Sleep(500);
                    CheckTimeout();
                }
            })
            { IsBackground = true }.Start();
        }

        public void Ping(IPEndPoint ep)
        {
            _last = DateTime.Now;

            if (!_connected)
            {
                _connected = true;
                _client = ep;
                Console.WriteLine($"✅ CLIENT CONNECTED: {ep.Address}:{ep.Port}");
            }
        }

        private void CheckTimeout()
        {
            if (_connected &&
                (DateTime.Now - _last).TotalSeconds > 2)
            {
                _connected = false;
                Console.WriteLine("❌ CLIENT DISCONNECTED");
            }
        }
    }
}
