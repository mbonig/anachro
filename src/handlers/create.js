const factories = require('./factories');
const {createStore} = require('redux');
const AWS = require('aws-sdk');
const reducers = require('./reducers');
const ddb = new AWS.DynamoDB.DocumentClient();


module.exports.handler = function createHandler(event, context, callback) {
    let apigwManagementApi = new AWS.ApiGatewayManagementApi({
        apiVersion: "2018-11-29",
        endpoint: event.requestContext.domainName + "/" + event.requestContext.stage
    });

    // take the client's input and hand it to a factory to create the related event
    const newEvent = factories.create(JSON.parse(event.body));
    // save that event to the preferred table

    let modelReducers = reducers[process.env.NAMESPACE];
    let store = createStore(modelReducers, {[process.env.MODEL_TABLE__HASH_KEY]: newEvent[process.env.EVENT_TABLE__HASH_KEY]});

    let unsubscribe = store.subscribe(async () => {
        unsubscribe();
        let newState = store.getState();
        try {
            let postParams = {ConnectionId: event.requestContext.connectionId, Data: JSON.stringify(newState)};

            let data = await apigwManagementApi.postToConnection(postParams).promise();
            await ddb.transactWrite({
                TransactItems:[
                    {Put: {TableName: process.env.EVENT_TABLE__NAME, Item: newEvent}},
                    {Put: {TableName: process.env.MODEL_TABLE__NAME, Item: newState}}
                ]
            }).promise();

            callback(null, {statusCode: 200, body: 'Sales Order Created'});

        } catch (err) {
            console.error('Error:', err);
        }
    });

    // process event
    console.log('Dispatching new event to redux...');
    store.dispatch(newEvent);
};