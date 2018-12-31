const factories = require('./factories');
const AWS = require('aws-sdk');

const ddb = new AWS.DynamoDB.DocumentClient();

module.exports.handler = async function createHandler(event) {
    // take the client's input and hand it to a factory to create the related event
    const newEvent = await factories.create(event);
    // save that event to the preferred table
    try {
        await ddb.put({TableName: process.env.EVENT_TABLE_NAME, Item: newEvent}).promise();
        return newEvent;
    } catch (err) {
        console.error('An error occurred while trying to write a Create event: ', err);
        return err;
    }
};