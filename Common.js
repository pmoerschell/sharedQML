function findChild(item, objectName) {
    var children = item.children;
    for (var i = children.length; --i >= 0;) {
        var child = children[i];
        if (!child)
            continue;

        if (child.objectName === objectName)
            return child;

        child = findChild(child, objectName);
        if (child)
            return child;
    }
    return undefined;
}

function propertyValue(component, propertyName, defaultValue)
{
    if (component === undefined)
        return defaultValue;

    return component.hasOwnProperty(propertyName) ? component[propertyName] :
                                                    defaultValue;
}
