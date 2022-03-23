# Install system default Jupyter kernel autoshutdown in a SageMaker Studio domain
This example shows you how you can install a SageMaker Studio Lifecycle Configuration (LCC) script to autoshutdown idle notebook kernels. Once applied, this LCC script will be attached by default to a new JupyterServer for all users in a SageMaker Studio domain.

Please follow the script and instruction in [install-domain-default-lcc.sh](./install-domain-default-lcc.sh) and fill in the placeholders in the template [default-user-settings-template.json](./default-user-settings-template.json). For example, please replace <domainid>, <region>, and <account> in the json file.

```
{
    "DomainId": "<domainid>",
...
          "LifecycleConfigArn": "arn:aws:sagemaker:<region>:<account>:studio-lifecycle-config/autoshutdown"
        },
        "LifecycleConfigArns": [
          "arn:aws:sagemaker:<region>:<account>:studio-lifecycle-config/autoshutdown"
        ]
     }
...
```

## Usage
The script [install-domain-default-lcc.sh](./install-domain-default-lcc.sh) takes 3 arguments: `region`, `domainid`, and an `user`. It downloads the autoshutdown script, updates the domain with the script as a default for all JupyterServer, creates a new `user` and a JupyterServer app and verifies that the autoshutdown LCC is attached to the JupyterServer app.
```shell
$ sh install-domain-default-lcc.sh $region $domainid $user
```