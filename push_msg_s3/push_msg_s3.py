
import boto3


def validateToken(reqToken):
    """ Validate the request token using token from ssm """

    ssm = boto3.client('ssm', region_name="us-east-1")

    ssmParam = ssm.get_parameter(Name='cp-ssm-req-token', WithDecryption=True)
    token = ssmParam['Parameter']['Value']

    if token == reqToken:
        return True
    else:
        return False

def sendDataToSQS(data):
    """ Send the request data to SQS """
    queue_url = 'https://sqs.us-east-1.amazonaws.com/329599656414/cp-task-sqs'

    sqs = boto3.client('sqs', region_name="us-east-1")

    response = sqs.send_message(
        QueueUrl=queue_url,
        DelaySeconds=10,
        MessageBody=(f'{data}')
    )

    return response

if __name__ == '__main__':
    
