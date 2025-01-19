<p align="center">
  <a href="https://example.com/">
    <img src="https://github.com/GolanSho/cp-task/blob/main/System_overview.png" alt="image" width=420 height=640>
  </a>

  <h3 align="center">Avanan Candidate Exam</h3>

  <p align="center">
    By Golan Shoshani
  </p>
</p>


## Table of contents

- [Intro](#intro)
- [Repo Overview](#repo-overview)
- [What i did](#what-i-did)
- [How to run](#how-to-run)


## Intro

For this exem i was requested to create a system of 2 Docker microservices in Python, built on ECS and use S3 bucket, Elastic load balancer, and SQS.
Use Jenkins for CI/CD.
All creations should be written by IaC (Terraform).


## Repo Overview

```text
cp-task/
├── push_msg_s3/
│     ├── Dockerfile
│     ├── push_msg_s3.py
│     └── Jenkinsfile
├── send_json_sqs_api/
│     ├── Dockerfile
│     ├── send_req_sqs.py
│     └── Jenkinsfile
└── tf-code/
      ├── ecs.tf
      ├── iam.tf
      ├── main.tf
      ├── networking.tf
      ├── s3-bucket.tf
      ├── s3-service.tf
      ├── sqs-service.tf
      └── sqs.tf
```

## What i did

I used terraform to create all aws resources, for that i used aws terraform modules and configured them for my need.
Including: all ecs components (cluster, tasks, services...) , iam roles , sqs & s3 bucket , networking (ELB, secutity groups..).

For CI/CD i deployed Jenkins on docker, with docker cloud dynamic agents, and scripted pipelines for the services upgrade process.
The upgrade process is pulling the code, building the image, pushing it to ECR, and upgrading the ECS services.

Using Python with Flask and boto3, i created the files for the services, and used Dockerfile to build their image. 

## How to run

Terraform:
- make sure you have aws credentials file with the right profile
- move to tf-code dir
- run terraform init
- run terraform plan
- run terraform apply

Jenkins Pipelines:
- to run the pipelines you will need the plugins: Build With Parameters, Docker plugin, Docker Pipeline, Pipeline: AWS Steps.
- the Docker cloud should be named 'Docker' and labeled 'Docker'
- make sure you have aws credentials with access and secret key.
- create pipeline for each service with string parameter 'version' (default=latest), point the scm to the Jenkinsfile in the service folder.
- run the pipelines.
