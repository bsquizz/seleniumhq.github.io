using System;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using OpenQA.Selenium.Edge;

namespace SeleniumDocs.Browsers
{
    [TestClass]
    public class EdgeTest
    {
        private EdgeDriver driver;
        private readonly string _logLocation = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "../../../selenium.log");

        [TestCleanup]
        public void QuitDriver()
        {
            driver.Quit();
        }

        [TestMethod]
        public void BasicOptions()
        {
            var options = new EdgeOptions();
            driver = new EdgeDriver(options);
        }

        [TestMethod]
        public void HeadlessOptions()
        {
            var options = new EdgeOptions();
            options.AddArgument("--headless=new");
            driver = new EdgeDriver(options);
        }

        [TestMethod]
        public void BasicService()
        {
            var service = EdgeDriverService.CreateDefaultService();
            driver = new EdgeDriver(service);
        }

        [TestMethod]
        public void LogsToFile()
        {
            var service = EdgeDriverService.CreateDefaultService();

            service.LogPath = _logLocation;

            driver = new EdgeDriver(service);

            var lines = File.ReadLines(_logLocation);
            Assert.IsNotNull(lines.FirstOrDefault(line => line.Contains("Starting Microsoft Edge WebDriver")));
        }

        [TestMethod]
        [Ignore("Not implemented")]
        public void LogsToConsole()
        {
            var stringWriter = new StringWriter();
            var originalOutput = Console.Out;
            Console.SetOut(stringWriter);

            var service = EdgeDriverService.CreateDefaultService();

            //service.LogToConsole = true;

            driver = new EdgeDriver(service);
            
            Assert.IsTrue(stringWriter.ToString().Contains("Starting Microsoft Edge WebDriver"));
            Console.SetOut(originalOutput);
            stringWriter.Dispose();
        }

        [TestMethod]
        [Ignore("Not implemented")]
        public void LogsLevel()
        {
            var service = EdgeDriverService.CreateDefaultService();
            service.LogPath = _logLocation;

            // service.LogLevel = ChromiumDriverLogLevel.Debug 

            driver = new EdgeDriver(service);

            var lines = File.ReadLines(_logLocation);
            Assert.IsNotNull(lines.FirstOrDefault(line => line.Contains("[DEBUG]:")));
        }

        [TestMethod]
        [Ignore("Not implemented")]
        public void ConfigureDriverLogs()
        {
            var service = EdgeDriverService.CreateDefaultService();
            service.LogPath = _logLocation;
            service.EnableVerboseLogging = true;

            service.EnableAppendLog = true;
            // service.readableTimeStamp = true;

            driver = new EdgeDriver(service);

            var lines = File.ReadLines(_logLocation);
            var regex = new Regex(@"\[\d\d-\d\d-\d\d\d\d");
            Assert.IsNotNull(lines.FirstOrDefault(line => regex.Matches("").Count > 0));
        }

        [TestMethod]
        public void DisableBuildCheck()
        {
            var service = EdgeDriverService.CreateDefaultService();
            service.LogPath = _logLocation;
            service.EnableVerboseLogging = true;

            service.DisableBuildCheck = true;

            driver = new EdgeDriver(service);

            var expected = "[WARNING]: You are using an unsupported command-line switch: --disable-build-check";
            var lines = File.ReadLines(_logLocation);
            Assert.IsNotNull(lines.FirstOrDefault(line => line.Contains(expected)));
        }
    }
}