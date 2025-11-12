import express from 'express';

import easywebFsm from '../state/easywebFsm';
import { VIEWS_DIR } from '../server';
import path from 'path';
import ejs from 'ejs';

export const router = express.Router();

const TIMEOUT_MILLIS = 15_000;

router.use(express.json()).post('/state/:action', async (req, res) => {
    const body = req.body as Record<string, any>|null;

    if (!body) {
        res.status(400).json({});
        return;
    }

    if (req.params['action'] === "submitCredentials") {
        easywebFsm.submitCredentials(body.username, body.password);
    }

    if (req.params['action'] === "submitSecurityCode") {
        easywebFsm.submitSecurityCode(body.code);
    }

    res.status(200).json({});
});

router.get('/state', async (req, res) => {
    const { lastUpdated: lastUpdatedStr } = req.query;

    if (typeof lastUpdatedStr !== 'string') {
        res.status(400).json({
            errors: [
                {message: 'Expected query parameter "lastUpdated".'}
            ]
        });
        return;
    }

    const state = await easywebFsm.waitForStateChange(parseInt(lastUpdatedStr, 10), TIMEOUT_MILLIS);

    if (state === null) {
        res.sendStatus(204);
        return;
    }

    const htmlContent = await ejs.renderFile(
        path.join(VIEWS_DIR, 'easywebFsm', `${state.name}.ejs`), 
        state.data
    );

    res.json({
        htmlContent,
        lastUpdated: state.lastUpdated
    });
});
