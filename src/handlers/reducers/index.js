const {CREATE} = require("../eventNames");

module.exports = {
    default: (state = {}, action) => {
        if (action.type === CREATE) {
            state = {...state, ...action.body};
        }
        return state;
    }
};