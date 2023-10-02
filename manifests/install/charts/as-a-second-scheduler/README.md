# Scheduler-plugins as a second scheduler in cluster

## Installation

Quick start instructions for the setup and configuration of as-a-second-scheduler using Helm.

### Prerequisites

- [Helm](https://helm.sh/docs/intro/quickstart/#install-helm)

### Installing the chart

#### Install chart using Helm v3.0+

```bash
$ git clone git@github.com:saniyard-dev/whatif-agent.git
$ cd whatif-agent/manifests/install/charts
$ helm install whatif-agent as-a-second-scheduler/
```

#### Verify that scheduler and plugin-controller pod are running properly.

```bash
$ kubectl get deploy -n whatif-agent
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
whatif-agent    1/1     1            1           7s
```

### Configuration

The following table lists the configurable parameters of the as-a-second-scheduler chart and their default values.

| Parameter                | Description            | Default                            |
| ------------------------ | ---------------------- | ---------------------------------- |
| `scheduler.name`         | Scheduler name         | `whatif-agent`                     |
| `scheduler.image`        | Scheduler image        | `saniyardev/whatif-agent:v0.23.10` |
| `scheduler.namespace`    | Scheduler namespace    | `whatif-agent`                     |
| `scheduler.replicaCount` | Scheduler replicaCount | `1`                                |
