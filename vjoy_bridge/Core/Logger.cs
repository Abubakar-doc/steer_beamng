using System;

namespace Core
{
    public static class Logger
    {
        public static void Info(string m) => Console.WriteLine(m);
        public static void Success(string m) => Console.WriteLine($"✅ {m}");
        public static void Warn(string m) => Console.WriteLine($"⚠️ {m}");
        public static void Error(string m) => Console.WriteLine($"❌ {m}");
    }
}
