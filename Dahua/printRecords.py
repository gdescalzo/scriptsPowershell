import requests

# Set the NVR API endpoint and login credentials
url = "https://xxxxxxxxxxxxxxxx/api/system/user/login"
username = "xxxxxxxxxxx"
password = "aaaaaaaaaaaaaaaa"

# Send a login request to authenticate with the NVR's API
response = requests.post(
    url, json={"userName": username, "password": password})

# Check if the login was successful
if response.status_code != 200:
    raise ValueError("Failed to authenticate with the NVR API")

# Extract the token from the login response
token = response.json()["token"]

# Set the API endpoint for retrieving the list of recordings
url = "https://wwwwwwwwwwwwwwww/api/playback/getPlaybackList"

# Set the parameters for the recording retrieval request
params = {
    "channelId": "<channel-id>",
    "beginTime": "<begin-time>",
    "endTime": "<end-time>",
    "pageStart": 0,
    "pageSize": 50
}

# Set the headers for the recording retrieval request
headers = {"Authorization": f"Bearer {token}",
           "Content-Type": "application/json"}

# Send the recording retrieval request
response = requests.post(url, json=params, headers=headers)

# Check if the retrieval was successful
if response.status_code != 200:
    raise ValueError("Failed to retrieve the list of recordings")

# Extract the recordings from the response
recordings = response.json()["data"]["list"]

# Print the list of recordings
print(recordings)
