import { until, type WebElement, type WebDriver } from "selenium-webdriver";

const TEXT_ME_TEXT = "Text me";

export class MfaModal {
    private constructor(private element: WebElement) { }

    public static async waitUntilFound(driver: WebDriver): Promise<MfaModal> {
        const element = await driver.wait(until.elementLocated({css:"mat-dialog-container[aria-labelledby=otpChoiceModalTitle]"}));
        return new this(element);
    }

    public async clickTextMe() {
        const buttons = await this.element.findElements({css: "button"});
        for (const button of buttons) {
            const text = await button.getText();
            if (text.indexOf(TEXT_ME_TEXT) >= 0) {
                await button.click();
                return;
            }
        }

        throw new Error(`Could not find button with text '${TEXT_ME_TEXT}'.`);
    }
}