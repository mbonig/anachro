const {createStore} = require('redux');
const AWS = require('aws-sdk');
const reducers = require('./reducers');
const ddb = new AWS.DynamoDB.DocumentClient();

module.exports.handler = function eventHandlers(event, context, callback) {
    // step through each record
    event.Records.reduce(async (prev, record) => {
        await prev;
        if (record.eventName !== 'INSERT') {
            // we don't handle non-inserts
            return;
        }
        const event = AWS.DynamoDB.Converter.unmarshall(record.dynamodb.NewImage);
        console.log('event: ', event);

        // get the existing model from process.env.MODEL_TABLE_NAME
        const existingModelResults = await
            ddb.get({
                TableName: process.env.MODEL_TABLE_NAME,
                Key: {
                    [process.env.MODEL_TABLE__HASH_KEY]: event[process.env.EVENT_TABLE__HASH_KEY]
                }
            }).promise();

        let existingModel = existingModelResults.Item || {[process.env.MODEL_TABLE__HASH_KEY]: event[process.env.EVENT_TABLE__HASH_KEY]};

        // init redux
        let modelReducers = reducers[process.env.NAMESPACE];
        let store = createStore(modelReducers, existingModel);

        console.log('the store:', store);
        let unsubscribe = store.subscribe(async () => {

            let newState = store.getState();
            console.log('state is now:', newState);
            console.log('saving state to db: ', process.env.MODEL_TABLE_NAME);
            try {
                await ddb.put({TableName: process.env.MODEL_TABLE_NAME, Item: newState}).promise();
                console.log('saved to db!');
                unsubscribe();
            } catch (err) {
                console.error('Error processing event record: ', record);
                console.error('Error:', err);
            }
        });

        // process event
        console.log('Dispatching new event to redux...');
        store.dispatch(event);

    }, Promise.resolve()).then(callback);

};