import { until, type WebDriver } from "selenium-webdriver";

export class AccountsOverviewPage {
    private constructor(private driver: WebDriver) {
    }

    public static async waitForPage(driver: WebDriver): Promise<AccountsOverviewPage> {
        await driver.wait(until.titleIs("Accounts Overview"));
        return new this(driver);
    }

    public async getAccounts() {
        const rows = await this.driver.findElements({css: "#pfsTableCA_BANKBanking tduf-balance-summary-account-row-content"});

        for (const row of rows) {
            const accountName = await row.findElement({css: "a.uf-account-name-and-link"}).getText();
            const accountNumber = await row.findElement({css: ".uf-account-number"}).getText();
            const amount = await row.findElement({css: ".uf-col2-amt-code"}).getText();
        }
    }
}