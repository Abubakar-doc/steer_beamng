using System;

namespace Core
{
    public static class Logger
    {
        public static void Info(string msg)
        {
            if (LogState.ShowLogs)
                Console.WriteLine(msg);
        }

        public static void Always(string msg)
        {
            Console.WriteLine(msg);
        }
    }
}
