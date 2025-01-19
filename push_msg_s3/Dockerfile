
FROM python:3

RUN mkdir /app

WORKDIR /app

COPY push_msg_s3.py .

RUN pip install boto3

CMD ["python3", "push_msg_s3.py"]

