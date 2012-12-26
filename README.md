Dotdot
=======

A database handler which parses a key-value-group pair.

Keys would look like:

* databases.default
* database.mydb.name
* database.mydb.host
* cache.default
* cache.local.host

Keys are arbitrary in nature. Keys are paired with values.

* databases.default => 'development'

A key database default with 'development' as default values

* database.hosts => 'host1.local,host2.local,host3.local'

A key holding database hosts which is a multiple value key.

Key-value pairs also have groups. Groups identify collections to add
more uniqueness and isolation to keys and values.
