# ACCOUNT CREATE
curl -vXPOST localhost:9000/user -H Content-Type:application/json -d '
  {
    "username": "flaviogranero",
    "email": "flavio@inaka.net",
    "password": "changeme123"
  }
'