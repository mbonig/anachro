const {CREATE} = require("../eventNames");

const uuid = require('uuid/v4');

function createEvent(event) {
    return {
        type: CREATE,
        [process.env.EVENT_TABLE__HASH_KEY]: uuid().slice(-5),
        timestamp: new Date().toISOString(),
        body: event
    };
}

module.exports = {
    create: createEvent
};