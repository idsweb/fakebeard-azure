# Custom Policy sample with local and Azure Active Directory signin

## Creating a dotnet core webapp from the command line

```dotnet new webapp --auth IndividualB2C 

```json
"AzureAdB2C": {
    "Instance": "https://login.microsoftonline.com/tfp/",
    "ClientId": "11111111-1111-1111-11111111111111111",
    "CallbackPath": "/signin-oidc",
    "Domain": "qualified.domain.name",
    "SignUpSignInPolicyId": "",
    "ResetPasswordPolicyId": "",
    "EditProfilePolicyId": ""
  }
```

| Setting | Value |
| ----------- | ----------- |
| Paragraph | Text |