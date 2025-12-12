using System;
using System.Net;
using Core;

namespace Network
{
    public class ClientMonitor
    {
        private DateTime _last = DateTime.MinValue;

        public void Ping(IPEndPoint ep)
        {
            _last = DateTime.Now;
        }
    }
}
