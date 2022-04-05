# Example script to migrate a SageMaker Notebook instance with AL1 to an instance with AL2

Fill in the variables in [sagemaker-notebook-al2-migration.sh](./sagemaker-notebook-al2-migration.sh#L1-L14) and run the rest of the script to 

1. Stop an AL1 instance
1. Add a tag to the AL1 instance to setup the backup bucket
1. Attach backup script to an AL1 instance
1. Start AL1 instance to trigger the backup
1. Create AL2 instance with sync script attached
1. Stop AL1 instance and delete the instance (optional)

This script assumes you have created the two SageMaker notebook instance lifecycle configuration scripts mentioned in **Create lifecycle configurations** section in the blog: https://aws.amazon.com/blogs/machine-learning/migrate-your-work-to-amazon-sagemaker-notebook-instance-with-amazon-linux-2/.

The two scripts can be found in [migrate-ebs-data-backup](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/tree/master/scripts/migrate-ebs-data-backup) and [migrate-ebs-data-sync](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples/tree/master/scripts/migrate-ebs-data-sync).