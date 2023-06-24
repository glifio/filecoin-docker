## Structure
This section describes the scripts and how they work in more detail.

````mermaid
flowchart LR

A[Dockerfile] -->|ENTRYPOINT /scripts/run| B{./run}
B -->|run bash-config| C[./bash-config - Export ENV vars]
B -->|run configure| D[./configure - Set configuration functions]
B -->|run launch| E[./launch -  starts the required processes]

````


Here's a quick guide. The main parts of the repository are:
* [Our infrastructure scripts:](./scripts)
    * [bash-config](bash-config) -  exports environment variables and defines the utility functions that are required for the other scripts to work. 
    * [configure](./scripts/configure) - defines and runs the configuration functions that handle our custom environment variables.
    * [healthcheck](./scripts/healthcheck) - contains a health check script that you can use as a readiness probe in Kubernetes to verify that the node is in the 3 [tipsets](https://docs.filecoin.io/basics/the-blockchain/tipsets/) range from the current head.
    * [launch](./scripts/launch) - starts the required processes according to the selected launch scenario.
    * [run](./scripts/run) - docker entrypoint script. Runs the before-mentioned scripts in the following order: bash-config, configure, launch.


[run](run)

Running the configure file and launch file

[bash-config](bash-config)

Besides exporting the utility environment variables, the scripts define the validation functions:
`validate_env_soft` and `validate_env_hard`. Both functions check if the provided as an argument environment variable has a value, and the value is not false.\
If the value is empty or false, the validate_env_soft function returns a non-zero code.\
On the other hand, the validate_env_hard function under the before-mentioned conditions terminates the script execution with the non-zero code.

[Launch script](launch)

The script is written in a way that only one launch scenario is executed at a time. The launch scenario precedence is as follows:
INFRA_LOTUS_LITE > INFRA_LOTUS_GATEWAY > INFRA_LOTUS_DAEMON.\
Keep in mind that the `--api-wait-lookback-limit` and `--api-max-lookback` arguments are hardcoded as `2000` and `16h40m0s` respectively.\
If you want to change this behavior, you have to edit the arguments in the `launch_gateway function`.


[configure](configure)

Runs scripts based on configured variables such as deleting the lotus directory, adding a secret volume, coping secrets, assigns permissions, coping the toml config, importing snapshot, launching a sync with the blockchain.


[healthcheck](healthcheck)

The health-check script can be used as a readiness probe for the lotus pod in Kubernetes. It compares the current chain head and the head at hand, and if the difference is more than 3 [tipsets](https://docs.filecoin.io/basics/the-blockchain/tipsets/), the pod is considered unhealthy.\
The number 3 has been chosen because the epoch in Filecoin lasts 30 seconds; the average time to catch up a tipset is ~12 seconds; so, if the head at hand is 3 tipsets behind the current head, something went wrong and you have to investigate the issue.
