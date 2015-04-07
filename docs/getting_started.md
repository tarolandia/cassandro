# Getting Started with Cassandro ORM

## Connection

Connecting to Cassandra DB: `Cassandro.connect(Hash options)`.

```ruby
# Connect
Cassandro.connect(hosts: ['192.168.2.100', '192.168.2.101'])

# Connect specifying keyspace
Cassandro.connect(hosts: ['192.168.2.100', '192.168.2.101'], keyspace: 'some_keyspace')
```

_For full list of options visit [Ruby Driver Documentation](http://datastax.github.io/ruby-driver/api/#cluster-class_method)_

## Keyspace

### Create Keyspace

```ruby
Cassandro.create_keyspace('new_keyspace', {
  replication: {
    class: 'NetworkTopologyStrategy',
    dc_1: 2,
    dc_2: 2
  },
  durable_writes: true
})
```

_For full details of keyspace creation visit [CLI keyspace](http://www.datastax.com/documentation/cassandra/2.0/cassandra/reference/referenceStorage_r.html)_


### Select keyspace

```ruby
Cassandro.use('keyspace_name')
```

## Execute

### Execute queries
```ruby
result = Cassandro.execute("SELECT * FROM table_name;")
```
### Create table
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

## Cassandra Client

Cassandro provides access to `cassandra-driver` instance through `Cassandro.client`

### Using Driver directly
```ruby
statement = Cassandro.client.prepare("SELECT * FROM table_name WHERE colname = ?;")
result = Cassandro.client.execute(statement, id)
```
