const factories = require('./factories');
const AWS = require('aws-sdk');

const ddb = new AWS.DynamoDB.DocumentClient();

module.exports.handler = async function createHandler(event) {
    console.log('event:', event);
    // take the client's input and hand it to a factory to create the related event
    const newEvent = await factories.create(JSON.parse(event.body));
    // save that event to the preferred table
    try {
        await ddb.put({TableName: process.env.EVENT_TABLE_NAME, Item: newEvent}).promise();
        return {statusCode: 200, body: 'Sales Order Created'};
    } catch (err) {
        console.error('An error occurred while trying to write a Create event: ', err);
        return {statusCode: 500, error: JSON.stringify(err)};
    }
};