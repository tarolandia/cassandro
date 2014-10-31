# Cassandro

Cassandro is a small Ruby ORM for Apache Cassandra 2.0 and CQL 3.0. Cassandro uses the new Datastax Ruby Driver (official driver).

## Install
 
`gem install cassandro`

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
Cassandro.create_keyspace('new_keyspace', 'SimpleStrategy', 1)
```

Select keyspace outside `#connect`

```ruby
Cassandro.use('keyspace_name')
```

Create table.
```ruby
table = <<-TABLEDEF                                                              
  CREATE TABLE IF NOT EXISTS table_name (                                              
    id UUID,                                                                       
    username VARCHAR,                                                                 
    crypted_password VARCHAR,                                                      
    created_at TIMESTAMP,                                                          
    updated_at TIMESTAMP,                                                          
    PRIMARY KEY(id,username)                                                          
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

## Cassandro::Model

### Creating model
Creating new model: make you class inherits form `Cassandro::Model`

```ruby
class SomeModel < Cassandro::Model
end
```

Specifying table name using the method `table(table_name)`:

```ruby
class SomeModel < Cassandro::Model

  table 'some_models'
end
```

Adding attributes using the method `attribute(name, type, options)`:

```ruby
class SomeModel < Cassandro::Model

  attribute :id, :uuid
  attribute :name, :text
end
```

types: :uuid, :text, :integer, :float, :timestamp, :datetime

Setting the primary key using the method `primary_key(pk_name | Array)`:

```ruby
class SomeModel < Cassandro::Model

  attribute :id, :uuid
  attribute :name, :text
  
  primary_key :id

end

class SomeModel < Cassandro::Model

  attribute :id, :uuid
  attribute :name, :text
  
  primary_key [:id,:name]

end
```

Setting unique field using the method `unique(field | Array)`:

```ruby
class SomeModel < Cassandro::Model

  unique :name
end
```

__A complete example__

```ruby
class SomeModel < Cassandro::Model

  table 'some_models'

  attribute :id, :uuid
  attribute :name, :text
  
  primary_key [:id, :name]

  unique :name
end
```

### Interacting

Creating a new row:

```ruby
somemodel = SomeModel.create(name: 'DaModel')
=> #<SomeModel:0x00000001e7a0a8
 @attributes={:name=>"DaModel", :id=>"1534214c-0e0b-455c-95e8-13677f56d6e5"},
 @errors={},
 @persisted=true>

```

Find row:

```ruby
SomeModel[name: 'DaModel']
=> #<SomeModel:0x00000001d27930
 @attributes={:id=>1534214c-0e0b-455c-95e8-13677f56d6e5, :name=>"DaModel"},
 @errors={},
 @persisted=true>
```

Checking errors:
```ruby
somemodel = SomeModel.create(name: 'DaModel')
=> #<SomeModel:0x00000001d68160
 @attributes={:name=>"DaModel", :id=>"a723301b-b94b-4a4b-8d36-872055734ab5"},
 @errors={:unique=>"somemodel_not_unique"},
 @persisted=false>

somemodel.persisted?
=> false

somemodel.errors
=> {:unique=>"somemodel_not_unique"}
```

## TODO

* Migrations
* Support Index
* Better queries
* Better documentation

## How to collaborate

If you find a bug or want to collaborate with the code, you can:

* Report issues trhough the issue tracker
* Fork the repository into your own account and submit a Pull Request
