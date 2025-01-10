import { until, type WebDriver } from "selenium-webdriver";

export class LoginPage {
    private constructor(private driver: WebDriver) { }

    public static async waitForPage(driver: WebDriver): Promise<LoginPage> {
        await driver.wait(until.titleIs("EasyWeb Login"));
        return new this(driver);
    }

    public async login(username: string, password: string): Promise<void> {
        const form = await this.driver.findElement({
            css: "core-login-form",
        });
        await (await form.findElement({ css: "#username" })).sendKeys(username);
        await (await form.findElement({ css: "#uapPassword" })).sendKeys(password);
        await (await form.findElement({ css: "button span.td-icon-secureBtn" })).click();
    }
}