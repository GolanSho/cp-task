# Docker based on Centos7
FROM python:3

RUN mkdir /app

WORKDIR /app

COPY send_req_sqs.py .

RUN pip install flask boto3

CMD ["python3", "send_req_sqs.py"]

EXPOSE 5000
