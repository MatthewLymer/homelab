type State = {
    name: string,
    data: Record<string, any>,
};

export abstract class FiniteStateMachine {
    private lastUpdated = Date.now();
    private readonly onChangeListeners: (() => void)[] = [];
    private readonly eventListeners = new Map<string, ((args: any) => void)[]>();

    protected constructor(private state: State) {
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

    public addEventListener<TEvent>(eventName: string, callback: ((event: TEvent) => void)) {
        let listeners = this.eventListeners.get(eventName);

        if (!listeners) {
            listeners = [];
            this.eventListeners.set(eventName, listeners);
        }
        
        listeners.push(callback);
    }

    protected publishEvent<TEvent>(eventName: string, event: TEvent) {
        for (const listener of this.eventListeners.get(eventName) ?? []) {
            listener(event);
        }
    }

    protected ensureState(expectedState: string) {
        if (expectedState !== this.state.name) {
            throw new Error(`Wanted state to be '${expectedState}', got '${this.state.name}'.`);
        }
    }

    protected setState(state: State) {
        this.state = state;
        this.lastUpdated = Date.now();

        for (const listener of this.onChangeListeners) {
            listener();
        }
    }
}
