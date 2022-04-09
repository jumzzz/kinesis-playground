# conda deactivate

echo "Initializing Package for Producer Lambda"
pip install --target ./producer_package requests kinesis-python
cd producer_package
zip -r ../producer-package.zip .
cd ..
zip -g producer-package.zip producer_lambda.py

echo "Initializing Package for Transformer Lambda"
zip transformer-package.zip transformer_lambda.py


echo "Creating IAM Role..."
awslocal iam create-role --role-name super-role --assume-role-policy-document file://role.json


echo "Creating Bucket user-stream-bucket"
awslocal s3 mb s3://user-stream-bucket


echo "Deploying Producer Lambda"

awslocal lambda create-function --function-name producer-function \
             --zip-file fileb://producer-package.zip --runtime python3.8 \
             --handler producer_lambda.producer_handler \
             --role arn:aws:iam::000000000000:role/super-role \
             --environment "Variables={TARGET_FIREHOSE=firehose-user-streams}"


echo "Deploying Transformer Lambda"
awslocal lambda create-function --function-name transformer-function \
             --zip-file fileb://transformer-package.zip --runtime python3.8 \
             --handler transformer_lambda.transformer_handler \
             --role arn:aws:iam::000000000000:role/super-role


echo "Creating Firehose Stream..."
# awslocal firehose create-delivery-stream \
#              --delivery-stream-name firehose-user-streams \
#              --delivery-stream-type DirectPut \
#              --extended-s3-destination-configuration file://s3_firehose_config.json

awslocal firehose create-delivery-stream \
            --cli-input-json file://firehose-skeleton.json