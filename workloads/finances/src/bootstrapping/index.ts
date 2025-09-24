import { Options } from "selenium-webdriver/chrome";
import { Builder, WebDriver } from "selenium-webdriver";
import { getSeleniumHubUrl } from "../configuration";

export async function createWebDriver(): Promise<WebDriver> {
    console.debug("Creating WebDriver.");

    return new Builder()
        .forBrowser("chrome")
        .setChromeOptions(new Options())
        .usingServer(getSeleniumHubUrl())
        .build();
}
