import json

def lambda_handler(event, context):
    message = "Server on ASG {}".format(event['key1'])
    print(message)
    return message