var _map = Object.create(null)

function value(key) {
    return _map[key]
}

function setValue(key, value) {
    _map[key] = value
}

function remove(key) {
    delete _map[key]
}

function keys() {
    return Object.keys(_map)
}

function process() {
    for (var key in _map) {
        /* do something */
    }
}
