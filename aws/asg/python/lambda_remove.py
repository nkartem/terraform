import json

def lambda_handler(event, context):
    message = "Server on ASG {}".format(event['key2'])
    print(message)
    return message
