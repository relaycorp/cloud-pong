# Infrastructure for Relaycorp-run Relaynet Pong instances

This repository contains the code and configuration for the cloud and Kubernetes resources powering the [Relaynet-Pong](https://docs.relaycorp.tech/relaynet-pong/) instances operated by Relaycorp.

The cloud resources are defined in Terraform modules managed on Terraform Cloud. Shared resources can be found in [`tf-workspace/`](./tf-workspace), whilst environment-specific resources can be found under [`environments/`](./environments).

The Kubernetes resources are defined in Helm charts ([`charts/`](./charts)), which are automatically deployed by Google Cloud Build.

## Instances

We currently operate a single instance:

- Public endpoint address: `ping.awala.services`
- PoHTTP URL: `https://pong-pohttp.awala.services`
