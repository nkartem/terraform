import requests
import json

x = 11

if x > 10:
    url_add = "https://vxsjudiw1i.execute-api.us-central-2.amazonaws.com/add-stage/add"
    url = url_add
    key1 = {"key1":"add"}
#    result = requests.post(url, data=json.dumps(key1))
    result = requests.post(url, data=json.dumps(key1), headers={"authorizationToken":"z9UGS5sPAisIK19Wr9ZJeciDxsZ6kThGdJqjKQxfAmZOxHGB7pN0pNxqa9ing1TcD1nAtX8MFwpqPTPTa2z8JRqqrezuMiWxETyjpeiIswlCJv70djYkopPyc7L0i1Nz"})
    print(result)
    print(result.text)
    print(result.ok)

elif x <= 10:
    url_remove = "https://vxsjudiw1i.execute-api.us-central-2.amazonaws.com/remove-stage/remove"
    url = url_remove
    key2 = {"key2":"remove"}
#    result = requests.post(url, data=json.dumps(key2))
    result = requests.post(url, data=json.dumps(key2), headers={"authorizationToken":"z9UGS5sPAisIK19Wr9ZJeciDxsZ6kThGdJqjKQxfAmZOxHGB7pN0pNxqa9ing1TcD1nAtX8MFwpqPTPTa2z8JRqqrezuMiWxETyjpeiIswlCJv70djYkopPyc7L0i1Nz"})
    print(result)
    print(result.text)
    print(result.ok)

else:
    print("nothing doing")