import express from 'express';
import ejs from 'ejs';
import { router as homeRouter } from './routes/home';
import { router as apiRouter } from './routes/api';
import path from 'path';

export const VIEWS_DIR = path.join(__dirname, 'views');

export function startServer(hostname: string, port: number) {
    const app = express();

    app.engine('ejs', ejs.renderFile);
    app.set('views', VIEWS_DIR);

    app.use((req, res, next) => {
        next();
        console.debug('%s %s - [%i]', req.method, req.url, res.statusCode);
    });

    app.use('/', homeRouter);
    app.use('/api', apiRouter);

    app.use(express.static(path.join(__dirname, 'public')));

    app.listen(port, hostname, (error) => {
        if (error) {
            console.error(error);
        } else {
            console.debug(`Server running at http://${hostname}:${port}/`);
        }
    });
}
