import requests
import json

x = 11

if x > 10:
    url_add = "https://q5z53tz230.execute-api.us-west-2.amazonaws.com/add-stage/add"
    url = url_add
    key1 = {"key1":"add"}
    result = requests.post(url, data=json.dumps(key1))
    print(result)
    print(result.text)
    print(result.ok)

elif x <= 10:
    url_remove = "https://q5z53tz230.execute-api.us-west-2.amazonaws.com/remove-stage/remove"
    url = url_remove
    key2 = {"key2":"remove"}
    result = requests.post(url, data=json.dumps(key2))
    print(result)
    print(result.text)
    print(result.ok)

else:
    print("nothing doing")