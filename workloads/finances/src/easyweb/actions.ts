import { createWebDriver } from "../bootstrapping/index.js";
import { getEasywebCredentials } from "../ui/inputProvider.js";
import { LoginPage } from "./pages/loginPage.js";

export async function fetchAccounts() {
    const { username, password } = await getEasywebCredentials();

    const driver = await createWebDriver();

    try {
        const loginPage = await LoginPage.navigateTo(driver);

        await loginPage.login(username, password);
    }
    finally {
        await driver.quit();
    }
}
