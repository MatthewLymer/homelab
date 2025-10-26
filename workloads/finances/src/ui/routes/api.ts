import express from 'express';

import portalFsm from '../portalFsm';
import { VIEWS_DIR } from '../server';
import path from 'path';
import ejs from 'ejs';

export const router = express.Router();

const TIMEOUT_MILLIS = 15_000;

router.post('/state', async (req, res) => {
    portalFsm.submitEasywebCredentials();

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

    const state = await portalFsm.waitForStateChange(parseInt(lastUpdatedStr, 10), TIMEOUT_MILLIS);

    if (state === null) {
        res.sendStatus(204);
        return;
    }

    const htmlContent = await ejs.renderFile(
        path.join(VIEWS_DIR, 'portalFsm', `${state.name}.ejs`), 
        state.data
    );

    res.json({
        htmlContent,
        lastUpdated: state.lastUpdated
    });
});
