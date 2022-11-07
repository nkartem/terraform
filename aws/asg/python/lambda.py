import json

def lambda_handler(event, context):
    message = "Server".format(event['key1'])
    print(message)
    return message
    
    
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
