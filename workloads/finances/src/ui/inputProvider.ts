import easywebFsm from "./state/easywebFsm";

class ManualResetVariable<TValue> {
    private promise: Promise<TValue>|null = null;
    private resolve: ((value: TValue) => void)|null = null;
    private reject: (() => void)|null = null;

    public constructor() {
        this.reset();
    }

    public get() {
        if (!this.promise) {
            throw new Error('Promise is null');
        }

        return this.promise;
    }

    public set(value: TValue) {
        if (this.resolve) {
            this.resolve(value);
        }
    }

    public reset() {
        if (this.reject) {
            this.reject();
        }

        this.promise = new Promise<TValue>((resolve, reject) => {
            this.resolve = resolve;
            this.reject = reject;
        });

        this.promise.catch(() => {});
    }
}

const credentials = new ManualResetVariable<{username: string, password: string}>();
const mfa = new ManualResetVariable<{pin: string}>();

easywebFsm.addEventListener('onSubmitMfa', (event: {pin: string}) => {
    mfa.set({...event});
});

easywebFsm.addEventListener('onSubmitCredentials', (event: {username: string, password: string}) => {
    credentials.set({...event});
});

export async function getEasywebCredentials() {
    credentials.reset();
    easywebFsm.promptForCredentials();
    return credentials.get();
}

export async function getEasywebMfa() {
    mfa.reset();
    easywebFsm.promptForMfa();
    return mfa.get();
}