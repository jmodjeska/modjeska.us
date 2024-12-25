# modjeska.us
Static website at https://modjeska.us

## Subdomain redirects

### Cloudfront

Alternate domain name:
`www.modjeska.us`

Custom SSL cert:
`*.modjeska.us`

Origin:
`www.example.com` (doesn't matter)

Event:
`Viewer Request`

Cache behavior:
`*`

### Route53

```
www.modjeska.us
CNAME
d3m1d0o784rh45.cloudfront.net
```

### Lambda@Edge

Region:
`us-east-1`

Code:

```
def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    headers = request['headers']

    # Extract the host header
    host_header = headers.get('host', [{'value': ''}])[0]['value']

    # Define the subdomain to redirect from and apex domain to redirect to
    subdomain = 'www.modjeska.us'
    apex_domain = 'https://modjeska.us'

    if host_header == subdomain:
        # Construct the redirect URL
        redirect_url = f"{apex_domain}{request['uri']}"

        # Return a 301 Redirect
        return {
            'status': '301',
            'statusDescription': 'Moved Permanently',
            'headers': {
                'location': [{'key': 'Location', 'value': redirect_url}],
            },
        }

    # If the host doesn't match, proceed as usual
    return request
```

Execution role:
`RewriteWebsiteCategoryURLs-role-qcfj5shs`

### IAM (`RewriteWebsiteCategoryURLs-role-qcfj5shs`)

Permissions policies:
`AWSLambdaBasicExecutionRole`

Trust relationships:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "edgelambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

