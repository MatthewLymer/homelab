import process from 'process';

import { startServer } from './ui/server.js';

const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;
const HOST = process.env.HOST ?? 'localhost';

startServer(HOST, PORT);

import { CronJob } from 'cron';
import { fetchAccounts } from './easyweb/actions.js';

const easywebJob = CronJob.from({
    cronTime: '* * * * * *',
	onTick: async () => {
		await fetchAccounts();
		// console.log('You will see this message every second');
	},
	onComplete: null,
    waitForCompletion: true,
	start: true,
	timeZone: 'utc'
});

easywebJob.start();

