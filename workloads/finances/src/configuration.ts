import process from 'process';

export function getSeleniumHubUrl() {
    return process.env.SELENIUM_HUB_URL ?? "http://localhost:4444/wd/hub";
}
