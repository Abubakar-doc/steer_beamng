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
        Console.WriteLine("=== vJoy Bridge Starting ===");

        // ---------------- vJoy Init ----------------
        if (!vJoy.vJoyEnabled())
        {
            Console.WriteLine("vJoy NOT enabled!");
            return;
        }

        uint id = 1;
        if (!vJoy.AcquireVJD(id))
        {
            Console.WriteLine("Failed to acquire VJoy ID 1");
            return;
        }

        Console.WriteLine("vJoy OK!");

        // ---------------- TCP Listener ----------------
        var listener = new TcpListener(IPAddress.Any, 5000);
        listener.Start();

        Console.WriteLine("Server listening on TCP :5000");

        while (true)
        {
            Console.WriteLine("Waiting for client...");
            var client = listener.AcceptTcpClient();
            client.NoDelay = true;

            Console.WriteLine("Client connected!");

            var stream = client.GetStream();
            byte[] buffer = new byte[256];
            string bufferStr = "";

            try
            {
                while (true)
                {
                    int bytes = stream.Read(buffer, 0, buffer.Length);
                    if (bytes <= 0) break;

                    bufferStr += Encoding.UTF8.GetString(buffer, 0, bytes);

                    int newline;
                    double? steer = null;
                    double? thr = null;
                    double? brk = null;

                    while ((newline = bufferStr.IndexOf('\n')) != -1)
                    {
                        string line = bufferStr[..newline].Trim();
                        bufferStr = bufferStr[(newline + 1)..];

                        if (line.Length == 0) continue;

                        // PING
                        if (line == "PING")
                        {
                            byte[] pong = Encoding.UTF8.GetBytes("PONG\n");
                            stream.Write(pong, 0, pong.Length);
                            continue;
                        }

                        // THROTTLE
                        if (line.StartsWith("THR:"))
                        {
                            if (double.TryParse(line[4..], NumberStyles.Float,
                                CultureInfo.InvariantCulture, out double v))
                                thr = Math.Clamp(v, 0, 1);
                            continue;
                        }

                        // BRAKE
                        if (line.StartsWith("BRK:"))
                        {
                            if (double.TryParse(line[4..], NumberStyles.Float,
                                CultureInfo.InvariantCulture, out double v))
                                brk = Math.Clamp(v, 0, 1);
                            continue;
                        }

                        // STEERING
                        if (double.TryParse(line, NumberStyles.Float,
                            CultureInfo.InvariantCulture, out double s))
                            steer = Math.Clamp(s, -1, 1);
                    }

                    // ---------------- Apply Inputs to vJoy ----------------
                    if (steer.HasValue)
                    {
                        int axis = (int)((steer.Value + 1) * 16383.5);
                        vJoy.SetAxis(axis, id, HID_USAGES.HID_USAGE_X);
                    }

                    if (thr.HasValue)
                    {
                        int axis = (int)(thr.Value * 32767);
                        vJoy.SetAxis(axis, id, HID_USAGES.HID_USAGE_SL0);
                    }

                    if (brk.HasValue)
                    {
                        int axis = (int)(brk.Value * 32767);
                        vJoy.SetAxis(axis, id, HID_USAGES.HID_USAGE_SL1);
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
