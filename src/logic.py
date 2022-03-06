#!/usr/bin/env python

import os
import boto3

import sh_stat

# Create SQS client
queue_url = os.getenv('RESULT_QUEUE_URL')
sqs = boto3.client('sqs')

def lambda_handler(event, _):
  """
  Lambda handler
  """
  input = (event['Records'][0]['body']).split(";")
  res = sh_stat.collect_stats(input)
  send_result(res)

def send_result(message): 
  """
  Send result to SQS queue
  """
  response = sqs.send_message(
    QueueUrl=queue_url,
    MessageBody=(
      f"{message}"
    )
  )
