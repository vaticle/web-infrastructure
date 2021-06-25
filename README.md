## Infrastructure manual

This repository has two modules `vault` and `nomad`.

**NOTE:** All the following code assumes you have GCP credentials set up in your shell. To set up the credential, export `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to your GCP credential file. Please access the GCP console [here](https://console.cloud.google.com/), and the project name is `vaticle-web-prod`.

### Vault

Vault is used for storing passwords, ssl certificates and so on. This is used across the entire web arena including the nomad infrastructure, so it must be set up prior to everything. We only need to deploy Vault if it doesn't already exist (in the cloud) or we need to upgrade.

#### Deployment

1. First we need to deploy the image, which will have the required tools pre-installed. The image only needs to be updated if we want to upgrade the installed software version.

    ```
   DEPLOY_PACKER_VERSION=(git rev-parse HEAD) bazel run //infrastructure/vault/images:deploy-gcp-vault
    ```
   
   This will deploy an image called `vault-<commit id>` to GCP.
   
2. We then need to deploy the cloud infrastructure of vault to GCP, after modifying the commit version of the image to use.

    ```
   terraform plan && terraform apply
    ```

#### Operation

To be able to authenticate with the vault server and call vault commands locally, you will need vault related credentials set up. There's a shell script to set up the environment variable needed to communicate with the vault server.

```
eval $(./authenticate-vault.sh)
```

To ssh into the machine, install the `gcloud` CLI and use the following command.

```
gcloud ssh vault
```

To start & restart the server, please ssh into the machine and run the following command.

```
systemctl restart vault
```

To view the logs, please ssh into the machine and run the following command.

```
journalctl -u vault
```

### Nomad

Nomad runs contained applications on top. It contains one or more nomad server, and arbitrary number of nomad clients. The vault setup process will automatically populate the credentials that a nomad cluster needs to run, so no extra manual steps are needed for setting up nomad credentials.  We only need to deploy Nomad server if it doesn't already exist (in the cloud) or we need to upgrade.

Note that there's also a GUI interface that would be useful for monitor the nomad jobs. Please refer to the authentication nomad section below to gain access to the GUI. After authentication locally, there will be a `NOMAD_ADDR` environment variable which has the IP address of the nomad machine.

#### Deployment

1. First we need to deploy the image, which will have the required tools pre-installed. The image only needs to be updated if we want to upgrade the installed software version.

    ```
   DEPLOY_PACKER_VERSION=(git rev-parse HEAD) bazel run //infrastructure/nomad/images:deploy-gcp-nomad-server
   DEPLOY_PACKER_VERSION=(git rev-parse HEAD) bazel run //infrastructure/nomad/images:deploy-gcp-nomad-client
    ```
   
   This will deploy an image called `nomad-server-<commit id>` and `nomad-client-<commit id>` to GCP.
   
2. We then need to deploy the cloud infrastructure of nomad server to GCP, after modifying the commit version of the image to use. We don't need to deploy nomad clients yet, as that depends on what and how many applications we want to run as nomad applications.

    ```
   terraform plan && terraform apply
    ```

#### Operation

To be able to authenticate with the nomad server and call nomad commands locally, you will need nomad related credentials set up. There's a shell script to set up the environment variable needed to communicate with the nomad server.

```
eval $(./authenticate-nomad.sh)
```

To ssh into the machine, install the `gcloud` CLI and use the following command.

```
gcloud ssh nomad-server
```

To start & restart the server, please ssh into the machine and run the following command.

```
systemctl restart nomad-server
```

To view the logs, please ssh into the machine and run the following command.

```
journalctl -u nomad-server
```
