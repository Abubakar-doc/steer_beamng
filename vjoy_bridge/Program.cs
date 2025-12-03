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
        listener.Server.SetSocketOption(SocketOptionLevel.Tcp, SocketOptionName.NoDelay, true);
        listener.Start();
        Console.WriteLine("Listening on port 5000...");

        while (true)
        {
            Console.WriteLine("Waiting for client...");
            var client = listener.AcceptTcpClient();
            client.NoDelay = true;                    // 👈 disable Nagle for this client
            Console.WriteLine("Client connected.");

            var stream = client.GetStream();
            byte[] buffer = new byte[256];
            string bufferStr = "";

            try
            {
                while (true)
                {
                    int bytes = stream.Read(buffer, 0, buffer.Length);
                    if (bytes <= 0) break;           // disconnected

                    bufferStr += Encoding.UTF8.GetString(buffer, 0, bytes);

                    int newlineIndex;
                    double? lastSteer = null;

                    // parse all lines we currently have, but only APPLY the last one
                    while ((newlineIndex = bufferStr.IndexOf('\n')) != -1)
                    {
                        string line = bufferStr.Substring(0, newlineIndex).Trim();
                        bufferStr = bufferStr.Substring(newlineIndex + 1);

                        if (string.IsNullOrWhiteSpace(line))
                            continue;

                        if (double.TryParse(
                                line,
                                System.Globalization.NumberStyles.Float,
                                System.Globalization.CultureInfo.InvariantCulture,
                                out double steer))
                        {
                            lastSteer = Math.Clamp(steer, -1.0, 1.0);
                        }
                    }

                    if (lastSteer.HasValue)
                    {
                        // only set once per burst
                        int axisValue = (int)((lastSteer.Value + 1.0) * 16383.5);
                        vJoy.SetAxis(axisValue, id, HID_USAGES.HID_USAGE_X);

                        // keep logging VERY light or remove entirely
                        // Console.WriteLine($"steer={lastSteer.Value:F3} axis={axisValue}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Client error: " + ex.Message);
            }
            finally
            {
                Console.WriteLine("Client disconnected.");
                client.Close();
            }
        }
    }
}
