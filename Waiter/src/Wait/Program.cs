using System;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Wait
{
    public class Program
    {
        public static void Main(string[] args)
        {
            try
            {
                var currentProcess = Process.GetCurrentProcess();
                var cancellationTokenSource = new CancellationTokenSource();

                WaitForCancel(currentProcess, cancellationTokenSource);
                MainAsync(args, cancellationTokenSource.Token).Wait();
            }
            catch (AggregateException e)
            {
                var innerException = e.Flatten();
                if (innerException != null)
                {
                    throw innerException;
                }

                throw;
            }
        }

        private static void WaitForCancel(Process process, CancellationTokenSource cancellationTokenSource)
        {
            process.EnableRaisingEvents = true;
            process.Exited += (o, a) =>
            {
                Console.WriteLine("Stopping the application ...");
                cancellationTokenSource.Cancel();
            };
        }

        private static async Task MainAsync(string[] args, CancellationToken cancellationToken)
        {
            // Wait for the Teamcity agent starts.
            await Task.Delay(TimeSpan.FromSeconds(5), cancellationToken);

            while (!cancellationToken.IsCancellationRequested)
            {
                Console.WriteLine("Looking for java processes ...");
                var javaProcesses = Process.GetProcessesByName("java");
                if (javaProcesses.Any())
                {
                    foreach (var javaProcess in javaProcesses)
                    {
                        Console.WriteLine("Java process found, wait until it ends.");
                        await Task.Run(() => javaProcess.WaitForExit(), cancellationToken);
                    }

                    Console.WriteLine("Waiting for the next interval for checking if some others java processes still exist.");
                    await Task.Delay(TimeSpan.FromSeconds(1), cancellationToken);
                    continue;
                }

                Console.WriteLine("No java processes found, exit.");

                break;
            }

            if (args.Any())
            {
                Process.Start("cmd", $"/C {string.Join(" ", args)}").WaitForExit();
            }
        }
    }
}