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
                responseGroup: 'Images,ItemAttributes,Reviews,OfferSummary',
                sort: 'salesrank'
            // client.itemLookup({
            //     itemId: 'B075M2DTZV',
            //     domain: 'webservices.amazon.de'
            }).then(function(results){
                console.log("Results", util.inspect(results, { depth: 10 }));

                let result = [];

                try {
                    for (let i=0; i < results.length; i++) {
                        let product = results[i];

                        console.log("Product:", product);

                        let name;
                        try {
                            name = product['ItemAttributes'][0]['Title'][0];
                        } catch (e) {
                            console.log("Error:", e);
                        }

                        let detailPageUrl;
                        try {
                            detailPageUrl = product['DetailPageURL'][0];
                        } catch (e) {
                            console.log("Error:", e);
                        }

                        let image;
                        try {
                            image = product['LargeImage'][0]['URL'][0];
                        } catch (e) {
                            console.log("Error:", e);
                        }

                        let price;
                        try {
                            price = product['OfferSummary'][0]['LowestNewPrice'][0]['FormattedPrice'][0];
                        } catch (e) {
                            console.log("Error:", e);
                        }

                        result.push({
                            'name': name,
                            'detailPageUrl': detailPageUrl,
                            'image': image,
                            'price': price
                        });
                    }

                    let response = {
                        statusCode: 200,
                        headers: {
                            'Content-Type': 'application/json; charset=utf-8',
                        },
                        body: JSON.stringify(result),
                    };

                    console.log("Response:", response);

                    callback(null, response);
                } catch (e) {
                    console.error("Error:", e);
                    callback(new Error(e));
                }
            }).catch(function(err){
                console.log("Error", util.inspect(err, { depth: 10 }));
                callback(new Error("GENERIC ERROR"));
            });
        }
    });
};