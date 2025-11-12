import requests
import csv
from dotenv import load_dotenv
import json
import os
import time

load_dotenv()

auth_token = os.environ['BRIGHT_DATA_AUTH']
headers = {
    "Authorization": f"Bearer {auth_token}",
    "Content-Type": "application/json",
}

profiles = []
with open("profiles.txt") as f:
    urls = f.readlines()
    for url in urls:
        profiles.append({
            "url": url.strip()
        })

data = json.dumps(profiles)

response = requests.post(
    "https://api.brightdata.com/datasets/v3/trigger?dataset_id=gd_l1viktl72bvl7bjuj0&notify=false&include_errors=true",
    headers=headers,
    data=data
).json()

id = response["snapshot_id"]

ready = False

while not ready:
    response = requests.get(
        f"https://api.brightdata.com/datasets/v3/progress/{id}",
        headers=headers,
    ).json()

    ready = (response["status"] == "ready")
    time.sleep(10)

response = requests.get(
    f"https://api.brightdata.com/datasets/v3/snapshot/{id}",
    headers=headers,
).content.decode()

results = response.split('\n')


profile_headers = ["id", "name", "about", "current_company", "experience", "education", "courses"]
with open('output.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(profile_headers)

    for response in results:
        if response.strip():
            resp_obj = json.loads(response)
            writer.writerow([resp_obj.get(col, '') for col in profile_headers])