
import boto3
import time
import tempfile
from datetime import datetime

def pushMsgToS3(msg):
    """ Push the received message to S3 Bucket """

    s3 = boto3.client('s3', region_name="us-east-1")
    tmp = tempfile.NamedTemporaryFile()

    with open(tmp.name, 'w') as f:
        f.write(msg)
        
    now = datetime.now()
    timeForMsg = now.strftime("%d-%m-%Y-%H-%M")

    try:
        s3.upload_file(Filename=f"{tmp.name}", Bucket='cp-task-s3-bucket',
        Key=f'message-{timeForMsg}')
        print('Message Pushed to bucket.')
    except Exception as e:
        print(e)
    

def recDataFromSQS():
    """ Receive Message from SQS """
    queue_url = 'https://sqs.us-east-1.amazonaws.com/329599656414/cp-task-sqs'

    sqs = boto3.client('sqs', region_name="us-east-1")

    response = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=1,
        VisibilityTimeout=0,
        WaitTimeSeconds=0
    )
    
    if 'Messages' in response:
        message = response['Messages'][0]['Body']
        receipt_handle = response['Messages'][0]['ReceiptHandle']

        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )

        return message
    else:
        return False

if __name__ == '__main__':
    while True:
        msgToPush = recDataFromSQS()
        
        if msgToPush != False:
            print(msgToPush)
            pushMsgToS3(msgToPush)
        else:
            print('No Messages to pull')

        time.sleep(20)

