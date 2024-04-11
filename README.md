Cognito + Google + Terraform 
============================

This repo contains an example of providing a Google Sign-In button to get AWS STS credentials, using terraform for the infrasturcture.

Getting Started
---------------

To use this repo you need to have both a Google Identity setup:

  * https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid
  
The index.html file in this repo is created following the personalized button example:

  * https://developers.google.com/identity/gsi/web/guides/display-button
 
And a simple browser native javascript implementation of the Cognito enhanced simplifed auth flow:

  * https://docs.aws.amazon.com/cognito/latest/developerguide/authentication-flow.html

You can add your google_client_id to data.tf and index.html and then run:

	terraform apply -auto-approve

The output will include the generated cognito_identity_pool_id you need to add to index.html:

	cognito_identity_pool_id = "<your aws region>:<some uuid>"

Once you supply your google_client_id and your cognito_indentity_pool_id you're ready to run the sample:

	node server.js

Connect to localhost:3000 and login!


How The Authentication Works
----------------------------

![Cognito enhanced simplified auth flow](https://docs.aws.amazon.com/images/cognito/latest/developerguide/images/amazon-cognito-ext-auth-enhanced-flow.png)

The flow is the button logs into Google, and then returns a JWT following the OIDC protocol.  This
token is then passed to Cognito to provision a new identifier if necessary (Cognito will validate 
the JWT for you), and then requests AWS STS credentials using the Cognito identifier.  The STS
credentials can then be used to call any AWS API using sigv4 signing, such as my [minaws](https://github.com/cthulhuology/minaws)
for a browser native interface.



