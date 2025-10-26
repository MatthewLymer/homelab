type State = {
    name: string,
    data: Record<string, any>,
};

class PortalFsm {
    private state: State = {
        name: 'idle',
        data: {
            message: "Idle..."
        }
    }

    private lastUpdated = Date.now();

    private onChangeListeners: (() => void)[] = [];

    public promptForEasywebCredentials() {
        this.ensureState('idle');

        this.setState({
            name: 'awaiting-input',
            data: {
                fields: [
                    {
                        label: "Username or Access Card",
                        name: "username",
                        type: "text",
                    },
                    {
                        label: "Password",
                        name: "password",
                        type: "password"
                    }
                ]
            },
        });
    }

    public submitEasywebCredentials() {
        this.ensureState('awaiting-input');

        this.setState({
            name: 'idle',
            data: {
                message: "Idle..."
            },
        });
    }

    public waitForStateChange(lastUpdated: number, timeoutMillis: number): Promise<Readonly<State & {lastUpdated: number}>|null> {
        if (lastUpdated !== this.lastUpdated) {
            return Promise.resolve({
                ...this.state,
                lastUpdated: this.lastUpdated
            });
        }

        return new Promise((resolve) => {
            const onStateChange = () => {
                const index = this.onChangeListeners.findIndex(x => x === onStateChange);
                if (index >= 0) {
                    this.onChangeListeners.splice(index, 1);
                }

                resolve({
                    ...this.state,
                    lastUpdated: this.lastUpdated
                });
            };

            this.onChangeListeners.push(onStateChange);

            setTimeout(() => {
                const index = this.onChangeListeners.findIndex(x => x === onStateChange);
                if (index >= 0) {
                    this.onChangeListeners.splice(index, 1);
                }

                resolve(null);
            }, timeoutMillis);
        });
    }

    private ensureState(expectedState: string) {
        if (expectedState !== this.state.name) {
            throw new Error(`Wanted state to be '${expectedState}', got '${this.state.name}'.`);
        }
    }

    private setState(state: State) {
        this.state = state;
        this.lastUpdated = Date.now();

        for (const listener of this.onChangeListeners) {
            listener();
        }
    }
}

const portalFsm = new PortalFsm();

export default portalFsm;