## Basic Cassandro

Connecting to Cassandra DB: `Cassandro.connect(Hash options)`. For full list of options visit [Ruby Driver Documentation](http://datastax.github.io/ruby-driver/api/#cluster-class_method)

```ruby
Cassandro.connect(
                  hosts: ['127.0.0.1'],
                  keyspace: 'some_keyspace'
                 )
```

Creating a new keyspace. For full details of keyspace creation visit [CLI keyspace](http://www.datastax.com/documentation/cassandra/2.0/cassandra/reference/referenceStorage_r.html)

```ruby
# < 1.0.0
Cassandro.create_keyspace('new_keyspace', 'SimpleStrategy', 1)

# >= 1.0.0, allow more options
Cassandro.create_keyspace('new_keyspace', {
  replication: {
    class: 'NetworkTopologyStrategy',
    dc_1: 2,
    dc_2: 2
  },
  durable_writes: true
})
```

Select keyspace outside `#connect`

```ruby
Cassandro.use('keyspace_name')
```

Create table.
```ruby
table = <<-TABLEDEF                                                              
  CREATE TABLE IF NOT EXISTS users (                                              
    email VARCHAR,                                                                       
    first_name VARCHAR,                                                                 
    age INT,
    created_at TIMESTAMP,                                                          
    PRIMARY KEY(email,created_at)                                                          
  )                                                                                
TABLEDEF

Cassandro.execute(table)
```

Execute queries.
```ruby
result = Cassandro.execute("SELECT * FROM table_name;")
```

Using Driver directly.
```ruby
statement = Cassandro.client.prepare("SELECT * FROM table_name WHERE colname = ?;")
result = Cassandro.client.execute(statement, id)
```
