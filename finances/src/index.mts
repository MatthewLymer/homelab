import { createWebDriver } from "./bootstrapping/index.js";
import { LoginPage } from "./easyweb/pages/loginPage.js";

const easywebUsername = process.env.EASYWEB_USERNAME;
const easywebPassword = process.env.EASYWEB_PASSWORD;

const driver = await createWebDriver();

try {
    await driver.navigate().to("https://easyweb.td.com/");

    const loginPage = await LoginPage.waitForPage(driver);

    await loginPage.login(easywebUsername ?? "", easywebPassword ?? "");

    await new Promise(resolve => setTimeout(resolve, 10_000));
}
finally {
    await driver.quit();
}
