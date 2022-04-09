import requests

api_uri = 'https://randomuser.me/api/'

r = requests.get(api_uri)
print(r.json())
