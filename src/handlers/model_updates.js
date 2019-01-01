const AWS = require('aws-sdk');
const DDB = new AWS.DynamoDB();

exports.handler = async (event) => {
    console.log('AWS Version:', AWS.VERSION);
    console.log('event:', event);

    var scanParams = {
        TableName: process.env.TABLE_NAME
    };

    try {
        let connections = await DDB.scan(scanParams).promise();
        let apigwManagementApi = new AWS.ApiGatewayManagementApi({
            apiVersion: "2018-11-29",
            endpoint: "bjl54dby3b.execute-api.us-east-1.amazonaws.com/dev"
        });
        let postParams = {};

        for (let element of connections.Items) {
            console.log('sending to: ', element.connectionId.S);
            postParams.ConnectionId = element.connectionId.S;

            for (let record of event.Records) {
                const event = AWS.DynamoDB.Converter.unmarshall(record.dynamodb.NewImage);

                postParams.Data = JSON.stringify(event);
                console.log('postParams: ', postParams);
                try {
                    let data = await apigwManagementApi.postToConnection(postParams).promise();
                    // some code omitted for brevity
                    console.log('send message... I think', data);

                } catch (err) {
                    console.error('error when posting connection:', err);
                }
            }
        }
    }
    catch (err) {
        console.error('An error occurred: ', err);
        return {
            statusCode: 500,
            body: "Failed to connect: " + JSON.stringify(err)
        };
    }

    // TODO implement
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
    };
    return response;
};
