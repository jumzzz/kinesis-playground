cd package
zip -r ../producer-package.zip .
cd ..
zip -g producer-package.zip lambda_function.py

conda deactivate
pip install --target ./producer_package requests
cd producer_package
zip -r ../producer_package.zip .
cd ..


echo "Creating IAM Role..."
awslocal iam create-role --role-name lambda-role --assume-role-policy-document file://role.json


echo "Creating S3 Bucket"
awslocal s3 mb s3://user-stream-bucket

echo "Creating kinesis Stream..."
awslocal kinesis create-stream \
             --stream-name user-stream \
             --shard-count 3


echo "Creating Lambda Function..."
awslocal lambda create-function --function-name producer-function \
             --zip-file fileb://producer-package.zip --runtime python3.8 \
             --handler lambda_function.producer_handler \
             --role http://localhost:4566/lambda-role \
             --environment "Variables={TARGET_STREAM=user-stream}"

