# Example script to migrate a SageMaker Notebook instance with AL1 to an instance with AL2

Fill in the variables in [sagemaker-notebook-al2-migration.sh](./sagemaker-notebook-al2-migration.sh#L1-L14) and run the rest of the script to 

1. Stop an AL1 instance
1. Add a tag to the AL1 instance to setup the backup bucket
1. Attach backup script to an AL1 instance
1. Start AL1 instance to trigger the backup
1. Create AL2 instance with sync script attached
1. Stop AL1 instance and delete the instance (optional)
