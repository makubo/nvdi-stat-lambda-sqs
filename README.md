# NDVI Analytics

Simple NDVI Analytics application which uses Sentinel Hub Statistical API to recieve satellite data.
Application made in purpose of demonstrating usage Terraform for deploying AWS Lambda and SQS.

## Description

Service consist of AWS Lambda Function: 
- `ndvi_stat`

and two SQS Queues:
- `ndvi_stat_input.fifo` (queue for input data)
- `ndvi_stat_result` (result message queue)

Any message in `ndvi_stat_input.fifo` inits `ndvi_stat` processing. In the end of process `ndvi_stat` puts results to `ndvi_stat_result`.

Correct input message data - top-left and bottom-right coordinates of region rectangle. Message group ID value could be any as you want.

Correct message body example:
```
139.0;35.5;140.0;34.5
```

Result message cosist:
- `date` Date of satellite data
- `min` NDVI Minimum value
- `max` NDVI Maximum value
- `mean` NDVI Mean value
- `variance` NDVI Variance
- `standard_deviation` NDVI Standard deviation value
- `region` Region coordinates

Result data example:
```
{'date': '2022-03-06', 'min': -0.34899792075157166, 'max': 0.15408805012702942, 'mean': -0.2088257924543944, 'variance': 0.0001571128974217256, 'standard_deviation': 0.012534468374116455, 'region': ['139.0', '35.5', '140.0', '34.5']}
```

## Depling process

Deploy requirements:
- OS GNU Linux
- terraform
- python
- pip

### Environment variable configuration

Before deploying you must define environment variables below

1. AWS Credentials variables

- TF_VAR_AWS_ACCESS_KEY
- TF_VAR_AWS_SECRET_KEY

How to get AWS Credentials: https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/getting-your-credentials.html

2. Sentinel Hub Credentials variables
- TF_VAR_SH_INSTANCE_ID
- TF_VAR_SH_CLIENT_ID
- TF_VAR_SH_CLIENT_SECRET

How to get Sentinel Hub Credentials: https://docs.sentinel-hub.com/api/latest/api/overview/authentication/


Example of `variables` file

```
#!/bin/bash

# AWS settings
export TF_VAR_AWS_ACCESS_KEY="QWERTYUIOPPIUYTRERTYUI"
export TF_VAR_AWS_SECRET_KEY="gjsklgkjdfkjgjgfg/hgjkshjfkdgh+hvjkdsjhaz"

# Sentinel Hub settings
export TF_VAR_SH_INSTANCE_ID="00000000-0000-0000-0000-000000000000"
export TF_VAR_SH_CLIENT_ID="11111111-1111-1111-1111-111111111111"
export TF_VAR_SH_CLIENT_SECRET="fgjdkhj'()'89dsadf')('655&(UU"
```

### Deploying

Deploy script:
```
source variables
terraform init
terraform plan
terraform apply -auto-approve
```

### Execution check

1. Go to lambda function and go to trigger queues
![Alt text](/screenshots/lambda_screen.png?raw=true)

2. Open input queue
![Alt text](/screenshots/sqs_input.png?raw=true)

3. Press "Send and receive messages" button
![Alt text](/screenshots/send_message_button.png?raw=true)

4. Prepare the message
![Alt text](/screenshots/message_prepare.png?raw=true)

5. Wait about 3 minute and open result queue
![Alt text](/screenshots/sqs_result.png?raw=true)

6. Press "Send and receive messages" button
![Alt text](/screenshots/receive_message_button.png?raw=true)

7. Press "Poll for messages" and find the new one
![Alt text](/screenshots/poll_messages.png?raw=true)

8. Check the result
![Alt text](/screenshots/receive_message.png?raw=true)

9. Also you can check logs
![Alt text](/screenshots/logs.png?raw=true)


## Used information
- Sentinel Hub Statistical API https://sentinelhub-py.readthedocs.io/en/latest/examples/statistical_request.html#Make-a-Statistical-API-request
- Python Lambda functions https://docs.aws.amazon.com/lambda/latest/dg/python-package.html
- Using Lambda with Amazon SQS https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html


