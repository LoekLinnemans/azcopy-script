AZURE_STORAGE_ACCOUNT="newyorkbackups"
AZURE_CONTAINER="newyorkbackups"
AZURE_DESTINATION="https://newyorkbackups.blob.core.windows.net/newyorkbackups?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-01-23T16:18:44Z&st=2025-01-09T08:18:44Z&spr=https&sig=aT1vIbcV87NZtSmM%2Bz8Qgu7KRalt1qZKKtmTPTT9H1U%3D"
AWS_BUCKET_NAME="azurebackupsaws"
AWS_REGION="us-east-1"
TEMP_DIR="/tmp/azure_to_aws_backup"

if [ $? -ne 0 ]; then
    echo "Failed to authenticate with Azure"
    exit 1
fi

mkdir -p "$TEMP_DIR"

echo "Downloading files from Azure Blob Storage"
azcopy copy "${AZURE_DESTINATION}" "$TEMP_DIR" --recursive
if [ $? -ne 0 ]; then
    echo "Failed to download files from Azure Blob Storage."
    rm -rf "$TEMP_DIR" 
    exit 1
fi
echo "Download complete."

echo "Uploading files to AWS S3"
aws s3 sync "$TEMP_DIR" "s3://${AWS_BUCKET_NAME}" --region "$AWS_REGION" --profile "$AWS_PROFILE"
if [ $? -ne 0 ]; then
    echo "Failed to upload files to AWS S3"
    rm -rf "$TEMP_DIR" 
    exit 1
fi
echo "Upload complete"

echo "Cleaning up temporary files"
rm -rf "$TEMP_DIR"
echo "Backup process completed successfully"