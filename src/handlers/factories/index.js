const {CREATE} = require("../eventNames");

const uuid = require('uuid/v4');

async function createEvent(event) {
    return {
        type: CREATE,
        [process.env.HASH_KEY]: uuid().slice(-5),
        timestamp: new Date().toISOString(),
        body: event
    };
}

module.exports = {
    create: createEvent
};