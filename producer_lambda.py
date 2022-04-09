import time
import boto3
import requests
import json
import os
import base64
from kinesis.producer import KinesisProducer
import hashlib



API_URI = 'https://randomuser.me/api/' 
LOCALSTACK_HOST = os.environ['LOCALSTACK_HOSTNAME']
ENDPOINT_URI = f'http://{LOCALSTACK_HOST}:4566'



def gen_data(data):
    data_bytes = json.dumps(data, indent=0).encode('utf-8')
    return data_bytes


def put_record(client, stream_name, data):

    data_bytes = gen_data(data)
    data_b64 = base64.b64encode(data_bytes)
    # record_id = hashlib.md5(data_b64).hexdigest()
    
    response = client.put_record(
            DeliveryStreamName=stream_name,
            Record=
                {
                    'Data' : json.dumps(data).encode('utf-8'),

                }
            )

    return response

def get_random_user():
    r = requests.get(API_URI)
    return r.json()

def producer_handler(event, context):
    max_iter = 60

    session = boto3.Session()
    client = session.client('firehose', endpoint_url=ENDPOINT_URI)
    
    print('Here are the envs')
    for k,v in os.environ.items():
        print(f'{k} : {v}')

    stream_name = os.environ['TARGET_FIREHOSE']


    for i in range(1, max_iter):
        data = get_random_user()
        response = put_record(client, stream_name, data)
        print(f'[{i}/{max_iter}] Current Status: {response}')

    return "Producer Finished"


def test_main():
    data = get_random_user()
    data_bytes = gen_data(data)

    print('Data Bytes: ', data_bytes)
    print('Type of Data: ', type(data_bytes))
  

if __name__ == '__main__':
    test_main()
