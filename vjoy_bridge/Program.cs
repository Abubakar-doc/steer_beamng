using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using vJoyInterfaceWrap;

class Program
{
    static void Main()
    {
        Console.WriteLine("vJoy TCP Server starting...");

        if (!vJoy.vJoyEnabled())
        {
            Console.WriteLine("vJoy NOT enabled. Exiting.");
            return;
        }

        uint id = 1;
        var status = vJoy.GetVJDStatus(id);
        Console.WriteLine("vJoy Device 1 status: " + status);

        if (!vJoy.AcquireVJD(id))
        {
            Console.WriteLine("Failed to acquire vJoy device 1.");
            return;
        }

        var listener = new TcpListener(IPAddress.Any, 5000);
        listener.Start();
        Console.WriteLine("Listening on port 5000...");

        while (true)
        {
            Console.WriteLine("Waiting for client...");
            using var client = listener.AcceptTcpClient();
            Console.WriteLine("Client connected.");

            var stream = client.GetStream();
            byte[] buffer = new byte[256];
            string bufferStr = "";

            while (client.Connected)
            {
                if (!stream.DataAvailable)
                    continue;

                int bytes = stream.Read(buffer, 0, buffer.Length);
                if (bytes <= 0) continue;

                bufferStr += Encoding.UTF8.GetString(buffer, 0, bytes);

                int newlineIndex;
                while ((newlineIndex = bufferStr.IndexOf('\n')) != -1)
                {
                    string line = bufferStr.Substring(0, newlineIndex).Trim();
                    bufferStr = bufferStr.Substring(newlineIndex + 1);

                    if (string.IsNullOrWhiteSpace(line))
                        continue;

                    Console.WriteLine("RAW: " + line);

                    if (!double.TryParse(line,
                        System.Globalization.NumberStyles.Float,
                        System.Globalization.CultureInfo.InvariantCulture,
                        out double steer))
                        continue;

                    steer = Math.Clamp(steer, -1.0, 1.0);

                    int axisValue = (int)((steer + 1.0) * 16383.5);

                    bool ok = vJoy.SetAxis(axisValue, id, HID_USAGES.HID_USAGE_X);
                    Console.WriteLine($"steer={steer:F3} axis={axisValue} ok={ok}");
                }
            }

            Console.WriteLine("Client disconnected.");
        }
    }
}
