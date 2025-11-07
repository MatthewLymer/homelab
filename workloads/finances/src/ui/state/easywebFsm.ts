import { FiniteStateMachine } from "./finiteStateMachine.js";

type State = {
    name: string,
    data: Record<string, any>,
};

class EasywebFsm extends FiniteStateMachine {
    public constructor() {
        super({name:'idle', data: {message:"Idle..."}});
    }

    public promptForCredentials() {
        this.ensureState('idle');

        this.setState({
            name: 'awaiting-credentials',
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

    public submitCredentials(username: string, password: string) {
        this.ensureState('awaiting-credentials');

        this.setState({
            name: 'idle',
            data: {
                message: "Idle..."
            },
        });

        this.publishEvent('onSubmitCredentials', {username, password});
    }
}

const easywebFsm = new EasywebFsm();

export default easywebFsm;