
from flask import Flask, request
import boto3

app = Flask(__name__)

@app.route('/info', methods=['GET'])
def get_info():
    """ Returns 'Running' string. Used to test if api is running """
    return "Running"


@app.route('/', methods=['POST'])
def processRequest():
    """ receive JSON request with token and send it to sqs """
    request_data = request.get_json()
    
    token = request_data['token']
    data = request_data['data']

    if len(data) != 4:
        return 'data is invalid: need to have 4 text fields'

    if validateToken(token):
        return sendDataToSQS(data)
    else:
        return 'Token is invalid'

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
    app.run(debug=True, host='0.0.0.0')
