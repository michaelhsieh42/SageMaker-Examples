region=$1
domainid=$2
user=$3

config_name=autoshutdown
URL=https://raw.githubusercontent.com/aws-samples/sagemaker-studio-lifecycle-config-examples/main/scripts/install-autoshutdown-server-extension/on-jupyter-server-start.sh

# Create lifecycle config using https://github.com/aws-samples/sagemaker-studio-lifecycle-config-examples/tree/main/scripts/install-autoshutdown-server-extension as an example. 
# This script needs to be created as a JupyterServer lcc
wget -O install-autoshutdown-server-extension-on-jupyter-server-start.sh $URL

LCC_CONTENT=`openssl base64 -A -in install-autoshutdown-server-extension-on-jupyter-server-start.sh`
aws sagemaker create-studio-lifecycle-config \
    --region $region \
    --studio-lifecycle-config-name $config_name \
    --studio-lifecycle-config-content $LCC_CONTENT \
    --studio-lifecycle-config-app-type JupyterServer 

# update the domain with domain settings and user default in default-user-setting.json
# Please fill in your region and account information in the json file. 
aws sagemaker update-domain --cli-input-json file://default-user-settings-template.json


# Create a new UserProfile or update with update-user-profile command
aws sagemaker create-user-profile --domain-id $domainid \
    --region $region \
    --user-profile-name $user
    ## To overwrite default user setting, add the flag below
    ## --user-settings '{
    ##      "JupyterServerAppSettings": {
    ##        "DefaultResourceSpec":{
    ##          "InstanceType": "system",
    ##          "LifecycleConfigArn": "arn:aws:sagemaker:<region>:<account>:studio-lifecycle-config/autoshutdown"
    ##        }
    ##      }'

# Create a JupyterServer app with autoshutdown script attached
# By default, LCC script in DefaultUserSettings.JupyterServerAppSettings.DefaultResourceSpec.LifecycleConfigArn in default-user-setting.json will apply
aws sagemaker create-app --domain-id $domainid \
    --region $region \
    --user-profile-name $user \
    --app-type JupyterServer \
    --app-name default
    ## overwrite the default with additional flag below
    ## --resource-spec LifecycleConfigArn=arn:aws:sagemaker:<region>:<account>:studio-lifecycle-config/autoshutdown

# To verify the JupyterServer app is created with autoshutdown script
# See if the autoshutdown script appear in ResourceSpec.LifecycleConfigArn
aws sagemaker describe-app --domain-id $domainid \
    --user-profile-name $user \
    --app-type JupyterServer \
    --app-name default