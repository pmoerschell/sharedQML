.import Cadence.Prototyping.Compile 1.0 as Compile

/***********************************************************************
 * example of usage:
 * elementOfModel(model, function(item) { return str1 === str2 });
 * where str1 === str2 is any logical statement
 **********************************************************************/
function elementOfModel(model, criteria)
{
    if (!model)
        return null;

    var i;
    if (model.count) {
        for (i = 0; i < model.count; ++i) {
            if (criteria(model.get(i)))
                return model.get(i);
        }
    } else if (model.length) {
        for (i = 0; i < model.length; ++i) {
            if (criteria(model[i]))
                return model[i];
        }
    }
    return null;
}

function indexOfModel(model, criteria)
{
    if (!model)
        return -1;

    var i;
    if (model.count) {
        for (i = 0; i < model.count; ++i) {
            if (criteria(model.get(i)))
                return i;
        }
    } else if (model.length) {
        for (i = 0; i < model.length; ++i) {
            if (criteria(model[i]))
                return i;
        }
    }
    return -1;
}

function criteriaOfModelCount(model, criteria)
{
    if (!model)
        return 0;

    var i;
    var count = 0;
    if (model.count) {
        for (i = 0; i < model.count; ++i) {
            if (criteria(model.get(i)))
                count++;
        }
    } else if (model.length) {
        for (i = 0; i < model.length; ++i) {
            if (criteria(model[i]))
                count++;
        }
    }
    return count;
}

function listModelSort(model, compareFunction)
{
    if (!model)
	return 0
    let indexes = [ ...Array(model.count).keys() ]
    indexes.sort( (a, b) => compareFunction( model.get(a), model.get(b) ) )
    let sorted = 0
    while ( sorted < indexes.length && sorted === indexes[sorted] ) sorted++
    if ( sorted === indexes.length ) return
    for ( let i = sorted; i < indexes.length; i++ ) {
          model.move( indexes[i], model.count - 1, 1 )
          model.insert( indexes[i], { } )
    }
    model.remove( sorted, indexes.length - sorted )
}
