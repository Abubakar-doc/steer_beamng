using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Globalization;
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
            client.NoDelay = true;
            Console.WriteLine("Client connected.");

            var stream = client.GetStream();
            byte[] buffer = new byte[256];
            string bufferStr = "";

            try
            {
                while (true)
                {
                    int bytes = stream.Read(buffer, 0, buffer.Length);
                    if (bytes <= 0) break; // disconnected

                    bufferStr += Encoding.UTF8.GetString(buffer, 0, bytes);

                    int newlineIndex;
                    double? lastSteer = null;
                    double? lastThrottle = null;
                    double? lastBrake = null;

                    while ((newlineIndex = bufferStr.IndexOf('\n')) != -1)
                    {
                        string line = bufferStr.Substring(0, newlineIndex).Trim();
                        bufferStr = bufferStr.Substring(newlineIndex + 1);

                        if (string.IsNullOrWhiteSpace(line))
                            continue;

                        // THR:0.75  -> throttle 0..1
                        if (line.StartsWith("THR:", StringComparison.OrdinalIgnoreCase))
                        {
                            var valStr = line.Substring(4);
                            if (double.TryParse(valStr, NumberStyles.Float,
                                CultureInfo.InvariantCulture, out double thr))
                            {
                                lastThrottle = Math.Clamp(thr, 0.0, 1.0);
                            }
                            continue;
                        }

                        // BRK:0.40  -> brake 0..1
                        if (line.StartsWith("BRK:", StringComparison.OrdinalIgnoreCase))
                        {
                            var valStr = line.Substring(4);
                            if (double.TryParse(valStr, NumberStyles.Float,
                                CultureInfo.InvariantCulture, out double brk))
                            {
                                lastBrake = Math.Clamp(brk, 0.0, 1.0);
                            }
                            continue;
                        }

                        // plain number -> steering
                        if (double.TryParse(
                                line,
                                NumberStyles.Float,
                                CultureInfo.InvariantCulture,
                                out double steer))
                        {
                            lastSteer = Math.Clamp(steer, -1.0, 1.0);
                        }
                    }

                    // apply latest steering
                    if (lastSteer.HasValue)
                    {
                        int axisValue = (int)((lastSteer.Value + 1.0) * 16383.5); // -1..1 -> 0..32767
                        vJoy.SetAxis(axisValue, id, HID_USAGES.HID_USAGE_X);
                    }

                    // apply latest throttle (0..1 -> 0..32767) on Slider 0
                    if (lastThrottle.HasValue)
                    {
                        int thrAxis = (int)(lastThrottle.Value * 32767.0);
                        vJoy.SetAxis(thrAxis, id, HID_USAGES.HID_USAGE_SL0);
                    }

                    // apply latest brake (0..1 -> 0..32767) on Slider 1
                    if (lastBrake.HasValue)
                    {
                        int brkAxis = (int)(lastBrake.Value * 32767.0);
                        vJoy.SetAxis(brkAxis, id, HID_USAGES.HID_USAGE_SL1);
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
