region=<region>
al1_instance_name=<existing-al1-instance-name>
al1_instance_arn=<existing-al1-instance-arn>
al2_instance_name=<new-al2-instance-name>
role=<sagemaker-execution-role>
bucket=<bucket-to-backup>
subnet=<subnet-id> # e.g. subnet-12345abc
security_group=<security-group-id> # e.g. sg-12345abc
volume=<desired-ebs-volume-in-GB> # e.g. 120
internet=Enabled # or Disabled
backup_script=AL1-instance-create-backup # name of the backup lifecycle config script registered in SageMaker. https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/tree/master/scripts/migrate-ebs-data-backup
sync_script=AL2-sync-backup # name of the sync lifecycle config script registered in SageMaker. https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/tree/master/scripts/migrate-ebs-data-sync

tag1_key=ebs-backup-bucket
tag2_key=backup-snapshot

# Stop the AL1 instance
aws sagemaker stop-notebook-instance --region $region \
    --notebook-instance-name $al1_instance_name

aws sagemaker wait notebook-instance-stopped --region $region \
    --notebook-instance-name $al1_instance_name

# Add a tag to the AL1 instance to setup the backup bucket
aws sagemaker add-tags --region $region \
    --resource-arn $al1_instance_arn \
    --tags Key=$tag1_key,Value=$bucket

# Attach backup script to an AL1 instance
aws sagemaker update-notebook-instance --region $region \
    --notebook-instance-name $al1_instance_name \
    --lifecycle-config-name $backup_script

aws sagemaker wait notebook-instance-stopped --region $region \
    --notebook-instance-name $al1_instance_name

# Start AL1 instance to trigger the backup
aws sagemaker start-notebook-instance --region $region \
    --notebook-instance-name $al1_instance_name

aws sagemaker wait notebook-instance-in-service --region $region \
    --notebook-instance-name $al1_instance_name

# aws sagemaker create-presigned-notebook-instance-url  --region $region \
#     --notebook-instance-name $al1_instance_name

# Identify the latest backup snapshot from s3 prefix (using sort)
snapshot=$(aws s3 ls s3://${bucket}/${al1_instance_name} | sort | tail -1 | awk '{print$2}')
snapshot=${snapshot%/} # remove trailing slash

# Create AL2 instance
aws sagemaker create-notebook-instance --region $region \
    --notebook-instance-name $al2_instance_name \
    --instance-type ml.t3.medium \
    --role-arn $role \
    --platform-identifier notebook-al2-v1 \
    --volume-size-in-gb $volume \
    --lifecycle-config-name $sync_script \
    --tags Key=$tag1_key,Value=$bucket \
           Key=$tag2_key,Value=$snapshot \
    --subnet-id $subnet \
    --security-group-ids $security_group \
    --direct-internet-access $internet \

aws sagemaker wait notebook-instance-in-service --region $region \
    --notebook-instance-name $al2_instance_name

# Creat presigned URL to open jupyter
# aws sagemaker create-presigned-notebook-instance-url  --region $region \
#     --notebook-instance-name $al2_instance_name

# Stop AL1 instance and delete the instance (optional)
aws sagemaker stop-notebook-instance --region $region \
    --notebook-instance-name $al1_instance_name

aws sagemaker wait notebook-instance-stopped --region $region \
    --notebook-instance-name $al1_instance_name

# aws sagemaker delete-notebook-instance --region $region \
#     --notebook-instance-name $al1_instance_name

# aws sagemaker wait notebook-instance-deleted --region $region \
#     --notebook-instance-name $al1_instance_name