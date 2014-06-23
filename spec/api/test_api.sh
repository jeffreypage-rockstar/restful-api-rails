# ACCOUNT CREATE
curl -vXPOST http://hyper-api-staging.inakalabs.com/user -H Content-Type:application/json -d '
  {
    "username": "flaviogranero",
    "email": "flavio@inaka.net",
    "password": "nohaymonedas"
  }
'

# LOGIN
curl -vXPOST http://hyper-api-staging.inakalabs.com/login -H Content-Type:application/json -d '
  {
    "email": "flavio@inaka.net",
    "password": "nohaymonedas"
  }
'

# USER DETAILS
curl -vXGET --user 49b3764c-c68a-418d-9503-ec24f205c1bf:8dedef102987d8a7b6837210846ed7e3 
http://hyper-api-staging.inakalabs.com/user -H Content-Type:application/json

# USER UPDATE
curl -vXPUT --user 49b3764c-c68a-418d-9503-ec24f205c1bf:8dedef102987d8a7b6837210846ed7e3  http://hyper-api-staging.inakalabs.com/user -H Content-Type:application/json -d '
  {
    "email": "flavio@inakanetworks.com",
    "username": "flavioinaka",
    "avatar_url": "http://placehold.it/80x80",
    "facebook_token": "avalidfacebooktoken"
  }
'

# CREATE A STACK
curl -vXPOST --user 49b3764c-c68a-418d-9503-ec24f205c1bf:8dedef102987d8a7b6837210846ed7e3  http://hyper-api-staging.inakalabs.com/stacks -H Content-Type:application/json -d '
  {
    "name": "My New Stack",
    "protected": true
  }
'
