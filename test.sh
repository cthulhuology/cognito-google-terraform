JWT="your test jwt"

IDP=$(aws cognito-identity list-identity-pools --max-results 1 | jq -r '.IdentityPools | .[] | .IdentityPoolId')

IDD=$(aws cognito-identity get-id --identity-pool-id $IDP --logins "accounts.google.com=$JWT" | jq -r .IdentityId )

aws cognito-identity get-credentials-for-identity --identity-id $IDD --logins  "accounts.google.com=$JWT"

