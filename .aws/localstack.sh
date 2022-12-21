#!/bin/bash
awslocal ses verify-email-identity --email-address no-reply@example.com --region eu-west-1

QUEUE_URL=$(awslocal sqs --region eu-west-1 create-queue --queue-name example --query 'QueueUrl' --output text)
QUEUE_ARN=$(awslocal sqs --region eu-west-1 get-queue-attributes --queue-url $QUEUE_URL --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

TOPIC_ARN_AccountOpened=$(awslocal sns --region eu-west-1 create-topic --name AccountOpened --query 'TopicArn' --output text)
awslocal sns --region eu-west-1 subscribe --topic-arn $TOPIC_ARN_AccountOpened --protocol sqs --notification-endpoint $QUEUE_ARN --query 'SubscriptionArn' --output text

TOPIC_ARN_AccountOpened=$(awslocal sns --region eu-west-1 create-topic --name AccountPasswordUpdated --query 'TopicArn' --output text)
awslocal sns --region eu-west-1 subscribe --topic-arn $TOPIC_ARN_AccountOpened --protocol sqs --notification-endpoint $QUEUE_ARN --query 'SubscriptionArn' --output text

TOPIC_ARN_AccountOpened=$(awslocal sns --region eu-west-1 create-topic --name AccountClosed --query 'TopicArn' --output text)
awslocal sns --region eu-west-1 subscribe --topic-arn $TOPIC_ARN_AccountOpened --protocol sqs --notification-endpoint $QUEUE_ARN --query 'SubscriptionArn' --output text

TOPIC_ARN_AccountOpened=$(awslocal sns --region eu-west-1 create-topic --name AccountDeposited --query 'TopicArn' --output text)
awslocal sns --region eu-west-1 subscribe --topic-arn $TOPIC_ARN_AccountOpened --protocol sqs --notification-endpoint $QUEUE_ARN --query 'SubscriptionArn' --output text

TOPIC_ARN_AccountOpened=$(awslocal sns --region eu-west-1 create-topic --name AccountWithdrawn --query 'TopicArn' --output text)
awslocal sns --region eu-west-1 subscribe --topic-arn $TOPIC_ARN_AccountOpened --protocol sqs --notification-endpoint $QUEUE_ARN --query 'SubscriptionArn' --output text

DLQ_URL=$(awslocal sqs --region eu-west-1 create-queue --queue-name example-dlq --query 'QueueUrl' --output text)
DLQ_ARN=$(awslocal sqs --region eu-west-1 get-queue-attributes --queue-url $DLQ_URL --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

awslocal sqs --region eu-west-1 set-queue-attributes --queue-url $QUEUE_URL --attributes RedrivePolicy="'"{\"deadLetterTargetArn\":\"$DLQ_ARN\"\,\"maxReceiveCount\":3}"'"
