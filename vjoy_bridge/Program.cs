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
        Console.WriteLine("=== vJoy Bridge Starting (UDP) ===");

        // ---------------- vJoy Init ----------------
        if (!vJoy.vJoyEnabled())
        {
            Console.WriteLine("vJoy NOT enabled!");
            return;
        }

        uint id = 1;
        VjdStat status = vJoy.GetVJDStatus(id);

        if (status != VjdStat.VJD_STAT_FREE && status != VjdStat.VJD_STAT_OWN)
        {
            Console.WriteLine("vJoy device not free!");
            return;
        }

        if (!vJoy.AcquireVJD(id))
        {
            Console.WriteLine("Failed to acquire vJoy ID 1");
            return;
        }

        Console.WriteLine("vJoy OK!");

        // ---------------- UDP Listener ----------------
        UdpClient udp = new UdpClient(5000);
        Console.WriteLine("Server listening on UDP :5000");

        IPEndPoint remote = new IPEndPoint(IPAddress.Any, 0);

        bool clientConnected = false;
        DateTime lastPacket = DateTime.MinValue;

        while (true)
        {
            try
            {
                // ---- RECEIVE PACKET ----
                byte[] data = udp.Receive(ref remote);
                string msg = Encoding.UTF8.GetString(data).Trim();

                // ---- CONNECT STATUS ----
                if (!clientConnected)
                {
                    clientConnected = true;
                    Console.WriteLine($"CLIENT CONNECTED: {remote.Address}:{remote.Port}");
                }

                lastPacket = DateTime.Now;

                // ---- DISCONNECT CHECK ----
                if ((DateTime.Now - lastPacket).TotalSeconds > 2 && clientConnected)
                {
                    clientConnected = false;
                    Console.WriteLine("CLIENT DISCONNECTED");
                }

                double? steer = null;
                double? thr = null;
                double? brk = null;
                int? gear = null;

                // ---------------- Parse ----------------
                if (msg == "PING")
                {
                    byte[] pong = Encoding.UTF8.GetBytes("PONG");
                    udp.Send(pong, pong.Length, remote);
                    continue;
                }

                // Steering raw float
                if (double.TryParse(msg, NumberStyles.Float,
                    CultureInfo.InvariantCulture, out double s))
                {
                    steer = Math.Clamp(s, -1, 1);
                }

                // THROTTLE
                if (msg.StartsWith("THR:"))
                {
                    if (double.TryParse(msg[4..], NumberStyles.Float,
                        CultureInfo.InvariantCulture, out double v))
                        thr = Math.Clamp(v, 0, 1);
                }

                // BRAKE
                if (msg.StartsWith("BRK:"))
                {
                    if (double.TryParse(msg[4..], NumberStyles.Float,
                        CultureInfo.InvariantCulture, out double v))
                        brk = Math.Clamp(v, 0, 1);
                }

                // GEAR
                if (msg.StartsWith("GEAR:"))
                {
                    if (int.TryParse(msg[5..], out int g))
                        gear = g;
                }

                // HANDBRAKE (button 11)
if (msg.StartsWith("HB:"))
{
    if (int.TryParse(msg[3..], out int hb))
    {
        bool pressed = hb == 1;

        // Set vJoy button #11
        vJoy.SetBtn(pressed, id, 11);
        continue;
    }
}

// ACTION BUTTONS
if (msg.StartsWith("ACT:"))
{
    string action = msg[4..].ToUpperInvariant();

    int button = action switch
    {
        "FIX"  => 12,
        "FLIP" => 13,
        "MODE" => 14,
        "IGN"  => 15,
        "FOG"  => 16,
        "HEAD" => 17,
        "HORN" => 18,
        "LEFT" => 19,
        "HAZ"  => 20,
        "RIGHT"=> 21,
        "DIFF" => 22,
        "ESC"  => 23,
        "4WD"  => 24,
        _ => 0
    };

    if (button != 0)
    {
        vJoy.SetBtn(true, id, (uint)button);

        // momentary press (50–80ms feels good)
        System.Threading.Thread.Sleep(60);

        vJoy.SetBtn(false, id, (uint)button);
    }

    continue;
}

// ----- HOLD START -----
if (msg.StartsWith("ACT_HOLD_START:"))
{
    string action = msg["ACT_HOLD_START:".Length..].ToUpperInvariant();
    uint button = action switch
    {
        "FIX" => 12,
        "IGN" => 15,
        _ => 0
    };

    if (button != 0)
        vJoy.SetBtn(true, id, button); // keep holding

    continue;
}

// ----- HOLD END -----
if (msg.StartsWith("ACT_HOLD_END:"))
{
    string action = msg["ACT_HOLD_END:".Length..].ToUpperInvariant();
    uint button = action switch
    {
        "FIX" => 12,
        "IGN" => 15,
        _ => 0
    };

    if (button != 0)
        vJoy.SetBtn(false, id, button); // release

    continue;
}

                // ---------------- Apply to vJoy ----------------

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

                // ----- GEAR BUTTONS (1–10) -----
                if (gear.HasValue)
                {
                    int g = Math.Clamp(gear.Value, 1, 10);

                    for (uint b = 1; b <= 10; b++)
                        vJoy.SetBtn(false, id, b);

                    vJoy.SetBtn(true, id, (uint)g);
                }

                // ---- DISCONNECT CHECK AGAIN (post processing) ----
                if ((DateTime.Now - lastPacket).TotalSeconds > 2 && clientConnected)
                {
                    clientConnected = false;
                    Console.WriteLine("CLIENT DISCONNECTED");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("UDP error: " + ex.Message);
            }
        }
    }
}
