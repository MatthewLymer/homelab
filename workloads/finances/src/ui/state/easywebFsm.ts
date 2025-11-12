import { FiniteStateMachine } from "./finiteStateMachine.js";

type State = {
    name: string,
    data: Record<string, any>,
};

function createIdleState(): State {
    return {
        name: 'idle',
        data: {
            message: "Idle..."
        },
    };
}

class EasywebFsm extends FiniteStateMachine {
    public constructor() {
        super(createIdleState());
    }

    public promptForCredentials() {
        this.ensureState('idle');

        this.setState({
            name: 'awaiting-input',
            data: {
                action: "submitCredentials",
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

    public promptForSecurityCode() {
        this.ensureState('idle');

        this.setState({
            name: 'awaiting-input',
            data: {
                action: "submitSecurityCode",
                fields: [
                    {
                        label: "Security code",
                        name: "securityCode",
                        type: "text",
                    }
                ]
            },
        });
    }

    public submitCredentials(username: string, password: string) {
        this.ensureState('awaiting-input');

        this.setState(createIdleState());

        this.publishEvent('onSubmitCredentials', {username, password});
    }

    public submitSecurityCode(code: string) {
        this.ensureState('awaiting-input');

        this.setState(createIdleState());

        this.publishEvent('onSubmitSecurityCode', {code});        
    }
}

const easywebFsm = new EasywebFsm();

export default easywebFsm;