import requests
import json

url = "https://pelevin.gpt.dobro.ai/generate/"

server_add = "add"
server_remove = "remove"
msg = "Твой текст!111111"
data = {"prompt": msg}

response = requests.post(url, data=json.dumps(data)).json()
answer = response.get("replies")
print(*answer)