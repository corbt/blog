---
layout: post
published: true
title: Introducing Pypeline DB
description: Pypeline DB is a new Python package that makes it easy to import, explore, transform and export data sets.
---
[Pypeline DB](http://pypeline.readthedocs.org/en/latest/index.html) is a new Python package that makes it easy to import, explore, transform and export data sets.  All data is stored on disk, making it especially appropriate for data too large to fit in RAM or data that you'd like to keep persistent between sessions.

Pypeline is built on top of Google's [LevelDB](https://code.google.com/p/leveldb/), which gives it some unique strengths.  Because datasets are stored as sequential sets of keys in LevelDB's key-value store, iterating through them is extremely fast.  Random access to elements of a dataset is fast as well, and appending to and deleting from the dataset are straightforward.

The core concept of pypeline revolves around *collections*, which typically represent datasets.  Collections are stored on disk and are persistent.  Creating a collection is easy:

{% highlight python %}
>>> import pypeline
>>> db = pypeline.DB("my_file_path.pypeline", create_if_missing=True)
>>> collection = db.collection('my_collection')
{% endhighlight %}

Collections behave like you would expect: you can iterate over them using the `for x in collection` syntax, access (and update) elements with the `[]` operator and in general follow pythonic conventions.  Pypeline DB works with whatever format your data is in, and most common data types like ints, strings, dicts and lists are supported.  Behind the scenes the data is JSON-serialized before being stored in the levelDB database.

Pypeline was built with data mining in mind, and has built-in map, filter and reduce functionality.  Mapping a collection using an arbitrary function is as easy as `my_collection.map(my_fuction, None)`.  Mapping a collection to a new collection (thus leaving your original data intact) is simply `new_collection = my_collection.map(my_function, 'new_collection_name')`.  Filtering and reducing follow the same intuitive API.  The ability to save the result of any of these operations to a new collection makes pypeline a great choice for exploratory work because you can easily try a transformation, inspect the results, and then delete the resultant collection if it didn't work out.

Pypeline is still in its early stages and I have plans to improve the toolkit a great deal going forward.  The project's objective is to make getting data into a learnable state as easy and straightforward as possible.  In a later blog post I'll share my thoughts on potential future enhancements.  If you're interested in seeing a feature added to pypeline or contributing to the project, a good place to start is with the source on [Github](https://github.com/kcorbitt/pypeline).

For more information and examples, including a demonstration of how to export a pypeline DB collection to a pandas dataframe, check out the pypeline [documentation](http://pypeline.readthedocs.org/en/latest/index.html).
