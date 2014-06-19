### API



#### GET /status

 Returns the status of the API



#### POST /login

 Post to authenticate a user in a device

**Parameters:** 


 - email (required) : User email.

 - password (required) : User password.

 - device_id : Current device id. If blank, a new device entry is created.

 - device_type : Current device type.



#### POST /auth/email-verification

 Post to verify the current user email

**Parameters:** 


 - confirmation_token (required) : E-mail confirmation token.



#### POST /auth/password-reset

 Request a password reset, delivering the reset password token

**Parameters:** 


 - email (required) : Password reset token.



#### PUT /auth/password-reset

 Change the user's password

**Parameters:** 


 - reset_password_token (required) : Password reset token.

 - password (required) : New password

 - password_confirmation (required) : New password confirmation



#### POST /user

 Create a new user account

**Parameters:** 


 - email (required) : User email.

 - password (required) : User password.

 - password_confirmation (required) : User password confirmation.

 - username : User username.

 - avatar_url : User avatar url



#### GET /user

 Returns current user data



#### PUT /user

 Update current user data and settings

**Parameters:** 


 - email : User email.

 - username : User username.

 - avatar_url : User avatar url



#### DELETE /user

 Deletes the current user account



#### POST /stacks

 Create a new stack with current user as owner

**Parameters:** 


 - name (required) : Stack name, must be unique.

 - protected : Stack visibility.



#### GET /stacks

 Returns current user stacks, paginated

**Parameters:** 


 - page : Page of results to fetch.

 - per_page : Number of results to return per page.



#### GET /stacks/trending

 Returns trending stacks, paginated

**Parameters:** 


 - page : Page of results to fetch.

 - per_page : Number of results to return per page.



#### GET /stacks/names

 Returns stacks for an autocomplete box

**Parameters:** 


 - q (required) : The query for stack name lookup.



#### GET /stacks/:id

 Returns the stack details

**Parameters:** 


 - id (required) : Stack id.




