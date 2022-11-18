import json

def lambda_handler(event, context):
    if format(event['key1']) == "add":
        message = "Add Server on ASG {}".format(event['key1'])
        print(message)
        return message
    elif format(event['key2']) == "remove":
        message = "Remove Server on ASG {}".format(event['key2'])
        print(message)
        return message
    else:
        print ("Error, can not find key!")