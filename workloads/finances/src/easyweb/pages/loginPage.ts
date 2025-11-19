import { until, type WebDriver } from "selenium-webdriver";

export class LoginPage {
    private constructor(private driver: WebDriver) { }

    public static async navigateTo(driver: WebDriver): Promise<LoginPage> {
        await driver.navigate().to("https://easyweb.td.com/");
        return this.waitForPage(driver);
    }

    public static async waitForPage(driver: WebDriver): Promise<LoginPage> {
        await driver.wait(until.titleIs("EasyWeb Login"));
        return new this(driver);
    }

    public async login(username: string, password: string, rememberMe: boolean): Promise<void> {
        const form = this.driver.findElement({
            css: "core-login-form",
        });

        await form.findElement({ css: "#username" }).sendKeys(username);
        await form.findElement({ css: "#uapPassword" }).sendKeys(password);
        if (rememberMe) {
            await form.findElement({ css: "input[formcontrolname=rememberMe]"}).click();
        }
        await form.findElement({ css: "button span.td-icon-secureBtn" }).click();
    }
}