import { createWebDriver } from "../bootstrapping/index.js";
import { getEasywebCredentials } from "../ui/inputProvider.js";
import { MfaModal } from "./components/mfaModal.js";
import { LoginPage } from "./pages/loginPage.js";

export async function fetchAccounts() {
    const { username, password } = await getEasywebCredentials();

    const driver = await createWebDriver();

    try {
        const loginPage = await LoginPage.navigateTo(driver);

        await loginPage.login(username, password);

        const modal = await MfaModal.waitUntilFound(driver);

        await modal.clickTextMe();

        new Promise((resolve) => setTimeout(resolve, 30_000));
    }
    finally {
        await driver.quit();
    }
}
