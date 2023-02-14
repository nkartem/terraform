def lambda_handler(event, context):
    
    #1 - Log the event
    print('*********** The event is: ***************')
    print(event)
    
    #2 - See if the person's token is valid
    auth = 'Deny'
    if event['authorizationToken'] == 'z9UGS5sPAisIK19Wr9ZJeciDxsZ6kThGdJqjKQxfAmZOxHGB7pN0pNxqa9ing1TcD1nAtX8MFwpqPTPTa2z8JRqqrezuMiWxETyjpeiIswlCJv70djYkopPyc7L0i1Nz':
        auth = 'Allow'
    else:
        auth = 'Deny'
    
    #3 - Construct and return the response
    authResponse = { "principalId": "z9UGS5sPAisIK19Wr9ZJeciDxsZ6kThGdJqjKQxfAmZOxHGB7pN0pNxqa9ing1TcD1nAtX8MFwpqPTPTa2z8JRqqrezuMiWxETyjpeiIswlCJv70djYkopPyc7L0i1Nz", "policyDocument": { "Version": "2012-10-17", "Statement": [{"Action": "execute-api:Invoke", "Resource": ["arn:aws:execute-api:us-central-1:122234418111:tsgjudgowu/*/*"], "Effect": auth}] }}
    return authResponse