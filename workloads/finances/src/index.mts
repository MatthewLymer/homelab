import process from 'process';

import { startServer } from './ui/server.js';

const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;
const HOST = process.env.HOST ?? 'localhost';

startServer(HOST, PORT);

import { CronJob } from 'cron';

const easywebJob = CronJob.from({
    cronTime: '* * * * * *',
	onTick: () => {
		// console.log('You will see this message every second');
	},
	onComplete: null,
    waitForCompletion: true,
	start: true,
	timeZone: 'utc'
});

easywebJob.start();

// import { createWebDriver } from "./bootstrapping/index.js";
// import { LoginPage } from "./easyweb/pages/loginPage.js";

// const easywebUsername = process.env.EASYWEB_USERNAME;
// const easywebPassword = process.env.EASYWEB_PASSWORD;

// const driver = await createWebDriver();

// try {
//     const loginPage = await LoginPage.navigateTo(driver);

//     await loginPage.login(easywebUsername ?? "", easywebPassword ?? "");

//     await new Promise(resolve => setTimeout(resolve, 10_000));
// }
// finally {
//     await driver.quit();
// }
