import json

def lambda_handler(event, context):
    message = "Server".format(event['key1','key2'])
    print(message)
    return message