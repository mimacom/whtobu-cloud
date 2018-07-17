var AWS = require('aws-sdk'),
    endpoint = "https://secretsmanager.eu-central-1.amazonaws.com",
    region = "eu-central-1",
    secretName = "lambda/amazon-product-api",
    secret,
    binarySecretData;

var amazon = require('amazon-product-api');

const util = require('util');

console.log('Loading function');

exports.handler = function (event, context, callback) {
    console.log(JSON.stringify(event, null, 2));

    var client = new AWS.SecretsManager({
        endpoint: endpoint,
        region: region
    });

    client.getSecretValue({SecretId: secretName}, function(err, data) {
        if(err) {
            if(err.code === 'ResourceNotFoundException')
                console.log("The requested secret " + secretName + " was not found");
            else if(err.code === 'InvalidRequestException')
                console.log("The request was invalid due to: " + err.message);
            else if(err.code === 'InvalidParameterException')
                console.log("The request had invalid params: " + err.message);
            else
                console.log("Secret Error", util.inspect(err, { depth: 10 }));

            callback(new Error("SECRET ERROR"));
        } else {
            // Decrypted secret using the associated KMS CMK
            // Depending on whether the secret was a string or binary, one of these fields will be populated
            if(data.SecretString !== "") {
                secret = data.SecretString;
            } else {
                binarySecretData = data.SecretBinary;
            }
        }

        if (secret) {
            secret = JSON.parse(secret);

            var client = amazon.createClient({
                awsId: secret.awsId,
                awsSecret: secret.awsSecret,
                awsTag: secret.awsTag
            });

            let data = JSON.parse(event.body);

            if (!data) {
                console.log("Error! Could not parse event body as JSON!", util.inspect(event.body, { depth: 10 }));
                callback(new Error("PARAM ERROR"));

                return
            }

            client.itemSearch({
                keywords: data.keywords,
                manufacturer: data.manufacturer,
                merchantId: 'Amazon',
                domain: 'webservices.amazon.de',
                condition: 'New',
                searchIndex: data.searchIndex,
                responseGroup: 'Images,ItemAttributes,Reviews,SalesRank',
                sort: 'salesrank'
            // client.itemLookup({
            //     itemId: 'B075M2DTZV',
            //     domain: 'webservices.amazon.de'
            }).then(function(results){
                console.log("Results", util.inspect(results, { depth: 10 }));

                let response = {
                    statusCode: 200,
                    headers: {
                        'Content-Type': 'application/json; charset=utf-8',
                    },
                    body: JSON.stringify(results),
                };

                callback(null, response);
            }).catch(function(err){
                console.log("Error", util.inspect(err, { depth: 10 }));
                callback(new Error("GENERIC ERROR"));
            });
        }
    });
};