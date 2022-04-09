import base64
import hashlib


def transformer_handler(event, context):
    output = []

    print(event['records'])

    for record in event['records']:
        # print(record['recordId'])
        payload = base64.b64decode(record['data'])

        recordId = hashlib.md5(record['data'].encode('utf-8')).hexdigest()

        # Do custom processing on the payload here

        output_record = {
            # 'recordId': recordId,
            'recordId' : record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(payload)
        }
        output.append(output_record)

    print('Successfully processed {} records.'.format(len(event['records'])))

    return {'records': output}