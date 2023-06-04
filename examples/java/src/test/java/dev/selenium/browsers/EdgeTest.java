package dev.selenium.browsers;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Files;
import java.util.regex.Pattern;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.chrome.ChromeDriverService;
import org.openqa.selenium.chromium.ChromiumDriverLogLevel;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeDriverService;
import org.openqa.selenium.edge.EdgeOptions;
import org.openqa.selenium.remote.service.DriverService;

public class EdgeTest {
    public EdgeDriver driver;
    private final File logLocation = new File("msedgedriver.log");

    @AfterEach
    public void quit() {
        driver.quit();
    }

    @Test
    public void basicOptions() {
        EdgeOptions options = new EdgeOptions();
        driver = new EdgeDriver(options);
    }

    @Test
    public void headlessOptions() {
        EdgeOptions options = new EdgeOptions();
        options.addArguments("--headless=new");
        driver = new EdgeDriver(options);
    }

    @Test
    public void defaultService() {
        EdgeDriverService service = new EdgeDriverService.Builder().build();
        driver = new EdgeDriver(service);
    }

    @Test
    public void logsToFile() throws IOException {
        EdgeDriverService service = new EdgeDriverService.Builder()
                .withLogFile(logLocation)
                .build();

        driver = new EdgeDriver(service);

        String fileContent = new String(Files.readAllBytes(logLocation.toPath()));
        Assertions.assertTrue(fileContent.contains("Starting Microsoft Edge WebDriver"));
    }

    @Test
    public void logsToConsole() throws IOException {
        System.setOut(new PrintStream(logLocation));

        EdgeDriverService service = new EdgeDriverService.Builder()
                .withLogOutput(System.out)
                .build();

        driver = new EdgeDriver(service);

        String fileContent = new String(Files.readAllBytes(logLocation.toPath()));
        Assertions.assertTrue(fileContent.contains("Starting Microsoft Edge WebDriver"));
    }

    @Test
    public void logsWithLevel() throws IOException {
        System.setProperty(ChromeDriverService.CHROME_DRIVER_LOG_PROPERTY,
                logLocation.getAbsolutePath());

        EdgeDriverService service = new EdgeDriverService.Builder()
            .withLoglevel(ChromiumDriverLogLevel.DEBUG)
            .build();

        driver = new EdgeDriver(service);

        String fileContent = new String(Files.readAllBytes(logLocation.toPath()));
        Assertions.assertTrue(fileContent.contains("[DEBUG]:"));
    }

    @Test
    public void configureDriverLogs() throws IOException {
        System.setProperty(EdgeDriverService.EDGE_DRIVER_LOG_PROPERTY,
                logLocation.getAbsolutePath());
        System.setProperty(EdgeDriverService.EDGE_DRIVER_LOG_LEVEL_PROPERTY,
                ChromiumDriverLogLevel.DEBUG.toString());

        EdgeDriverService service = new EdgeDriverService.Builder()
            .withAppendLog(true)
            .withReadableTimestamp(true)
            .build();

        driver = new EdgeDriver(service);

        String fileContent = new String(Files.readAllBytes(logLocation.toPath()));
        Pattern pattern = Pattern.compile("\\[\\d\\d-\\d\\d-\\d\\d\\d\\d", Pattern.CASE_INSENSITIVE);
        Assertions.assertTrue(pattern.matcher(fileContent).find());
    }

    @Test
    public void disableBuildChecks() throws IOException {
        System.setProperty(EdgeDriverService.EDGE_DRIVER_LOG_PROPERTY,
                logLocation.getAbsolutePath());
        System.setProperty(EdgeDriverService.EDGE_DRIVER_LOG_LEVEL_PROPERTY,
                ChromiumDriverLogLevel.DEBUG.toString());

        EdgeDriverService service = new EdgeDriverService.Builder()
                .withBuildCheckDisabled(true)
                .build();

        driver = new EdgeDriver(service);

        String fileContent = new String(Files.readAllBytes(logLocation.toPath()));
        String expected = "[WARNING]: You are using an unsupported command-line switch: --disable-build-check";
        Assertions.assertTrue(fileContent.contains(expected));
    }
}
