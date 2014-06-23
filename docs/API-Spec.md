## API

### [[General API Structure]]

### Endpoints



#### ``GET /status``

 Returns the status of the API
 
**Example**

    curl -vXGET http://SERVER_URL/status -H Content-Type:application/json
    
Response:

    < HTTP/1.1 200 OK
    < Content-Type: application/json
    < Content-Length: 40
    < Connection: keep-alive
    < Access-Control-Allow-Origin: *
    < Access-Control-Request-Method: *
    {"status":"ok","domain":"inakalabs.com"}
    
---
#### ``POST /login``

 Post to authenticate a user in a device

**Parameters:** 

 - email (required) : User email.

 - password (required) : User password.

 - device_id : Current device id. If blank, a new device entry is created.

 - device_type : Current device type.

**Example:**

    curl -vXPOST http://SERVER_URL/login -H Content-Type:application/json -d '
      {
        "email": "flavio@inaka.net",
        "password": "nohaymonedas"
      }
    '
    
Response:

    < HTTP/1.1 201 Created
    < Content-Type: application/json
    < Content-Length: 292
    < Connection: keep-alive
    < Access-Control-Allow-Origin: *
    < Access-Control-Request-Method: *
    {
      "id": "8193aacb-bfad-4220-8bdf-d0046c04cace",
      "email": "flavio@inaka.net",
      "username": "flaviogranero",
      "facebook_token": null,
      "avatar_url": null,
      "unconfirmed_email": null,
      "confirmed": false,
      "auth": {
        "device_id": "e29fb2d6-e1d2-4ffc-9869-3d8bf66d4b72",
        "access_token": "9a613c9df4c5aebcd274398dc309cc2f"
      }
    }

---
#### ``POST /auth/email-verification``

 Post to verify the current user email

**Parameters:** 


 - confirmation_token (required) : E-mail confirmation token.


---
#### ``POST /auth/password-reset``

 Request a password reset, delivering the reset password token

**Parameters:** 


 - email (required) : Password reset token.


---
#### ``PUT /auth/password-reset``

 Change the user's password

**Parameters:** 


 - reset_password_token (required) : Password reset token.

 - password (required) : New password


---
#### ``POST /user``

 Create a new user account

**Parameters:** 


 - email (required) : User email.

 - username (required) : User username.

 - password (required) : User password.

 - facebook_token : User facebook token.

 - avatar_url : User avatar url.

 - device_type : Current device type.

**Example 1: Creating a valid user account**

    curl -vXPOST http://SERVER_URL/user -H Content-Type:application/json -d '
      {
        "username": "flaviogranero",
        "email": "flavio@inaka.net",
        "password": "nohaymonedas"
      }
    '
Response:
    
    < HTTP/1.1 201 Created
    < Content-Type: application/json
    < Content-Length: 292
    < Connection: keep-alive
    < Access-Control-Allow-Origin: *
    < Access-Control-Request-Method: *
    < Location: /user
    <
    {
      "id": "8193aacb-bfad-4220-8bdf-d0046c04cace",
      "email": "flavio@inaka.net",
      "username": "flaviogranero",
      "facebook_token": null,
      "avatar_url": null,
      "unconfirmed_email": null,
      "confirmed": false,
      "auth": {
        "device_id": "49b3764c-c68a-418d-9503-ec24f205c1bf",
        "access_token": "8dedef102987d8a7b6837210846ed7e3"
      }
    }

---
#### ``GET /user``

 Returns current user data.
 
 Requires [[API Authentication]].
 
**Example:**

    curl -vXGET --user DEVICE_ID:ACCESS_TOKEN
    http://SERVER_URL/user -H Content-Type:application/json
    
Response:

    < HTTP/1.1 200 OK
    < Content-Type: application/json
    < Content-Length: 292
    < Connection: keep-alive
    < Access-Control-Allow-Origin: *
    < Access-Control-Request-Method: *

    {
      "id": "8193aacb-bfad-4220-8bdf-d0046c04cace",
      "email": "flavio@inaka.net",
      "username": "flaviogranero",
      "facebook_token": null,
      "avatar_url": null,
      "unconfirmed_email": null,
      "confirmed": false,
      "auth": {
        "device_id": "e29fb2d6-e1d2-4ffc-9869-3d8bf66d4b72",
        "access_token": "9a613c9df4c5aebcd274398dc309cc2f"
      }
    }
    
---
#### ``PUT /user``

 Update current user data and settings.
 
 Requires [[API Authentication]].

**Parameters:** 

 - email : User email.

 - username : User username.

 - facebook_token : User facebook token.

 - avatar_url : User avatar url

**Example:**

    curl -vXPUT --user DEVICE_ID:ACCESS_TOKEN
    http://SERVER_URL/user -H Content-Type:application/json -d '
      {
        "email": "flavio@inakanetworks.com",
        "username": "flavioinaka",
        "avatar_url": "http://placehold.it/80x80",
        "facebook_token": "avalidfacebooktoken"
      }
    '
    
Response:

    < HTTP/1.1 204 No Content

---
#### ``DELETE /user``

 Deletes the current user account.
 
 Requires [[API Authentication]].

**Example:**

    curl -vXDELETE --user DEVICE_ID:ACCESS_TOKEN http://SERVER_URL/user
    
Response:

    < HTTP/1.1 204 No Content

---
#### ``POST /stacks``

 Create a new stack with current user as owner.
 
 Requires [[API Authentication]].

**Parameters:** 


 - name (required) : Stack name, must be unique.

 - protected : Stack visibility.
 
**Example**:

    curl -vXPOST --user DEVICE_ID:ACCESS_TOKEN http://SERVER_URL/stacks
     -H Content-Type:application/json -d '
      {
        "name": "My New Stack",
        "protected": true
      }
    '
Response:

    < HTTP/1.1 201 Created
    < Content-Type: application/json
    < Content-Length: 133
    < Connection: keep-alive
    < Access-Control-Allow-Origin: *
    < Access-Control-Request-Method: *
    < Location: /stacks/51562699-9a62-4ee9-9c8a-a62240306b07
    {
      "id": "51562699-9a62-4ee9-9c8a-a62240306b07",
      "name": "My New Stack",
      "user_id": "8193aacb-bfad-4220-8bdf-d0046c04cace",
      "protected": true
    }

---
#### ``GET /stacks``

 Returns current user stacks, paginated

**Parameters:** 


 - page : Page of results to fetch.

 - per_page : Number of results to return per page.


---
#### ``GET /stacks/trending``

 Returns trending stacks, paginated

**Parameters:** 


 - page : Page of results to fetch.

 - per_page : Number of results to return per page.


---
#### ``GET /stacks/names``

 Returns stacks for an autocomplete box

**Parameters:** 


 - q (required) : The query for stack name lookup.


---
#### ``GET /stacks/:id``

 Returns the stack details

**Parameters:** 


 - id (required) : Stack id.




