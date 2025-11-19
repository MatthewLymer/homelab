import { createWebDriver } from "../bootstrapping/index.js";
import { getEasywebCredentials, getEasywebSecurityCode as getEasywebSecurityCode } from "../ui/inputProvider.js";
import { SecureCodeModal } from "./components/secureCodeModal.js";
import { AccountsOverviewPage } from "./pages/accountsOverview.js";
import { LoginPage } from "./pages/loginPage.js";

export async function fetchAccounts() {
    const { username, password } = await getEasywebCredentials();

    const driver = await createWebDriver();

    try {
        const loginPage = await LoginPage.navigateTo(driver);

        await loginPage.login(username, password, true);

        const secureCodeModal = await SecureCodeModal.waitUntilFound(driver);

        await secureCodeModal.clickTextMe();

        const securityCode = await getEasywebSecurityCode();

        await secureCodeModal.submitSecurityCode(securityCode.code);

        const accountsOverviewPage = await AccountsOverviewPage.waitForPage(driver);

        const accounts = await accountsOverviewPage.getAccounts();

        new Promise((resolve) => setTimeout(resolve, 30_000));
    }
    finally {
        await driver.quit();
    }
}
