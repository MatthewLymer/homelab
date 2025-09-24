import http from 'http';

export function startServer(host: string, port: number) {
    const server = http.createServer(async (req, res) => {
        try {
            await new Promise((resolve) => setTimeout(resolve, 1000));

            res.statusCode = 200;
            res.setHeader('Content-Type', 'text/plain');
            res.end('Hello, World!\n');
        }
        catch (e) {
            try {
                res.statusCode = 500;
                res.setHeader('Content-Type', 'text/plain');
                res.end('500 - Internal Server Error');
            }
            catch {
                // do nothing.
            }
        }
    });

    server.listen(port, host, () => {
        console.log(`Server running at http://${host}:${port}/`);
    });
}