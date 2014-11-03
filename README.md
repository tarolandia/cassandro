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

## Cassandro::Model

### Creating model
Creating new model: make you class inherits form `Cassandro::Model`

```ruby
class User < Cassandro::Model
end
```

Specifying table name using the method `table(table_name)`:

```ruby
class User < Cassandro::Model

  table 'users'
end
```

Adding attributes using the method `attribute(name, type, options)`:

```ruby
class User < Cassandro::Model

  attribute :email, :text
  attribute :first_name, :text
  attribute :age, :integer
  attribute :created_at, :datetime
end
```

types: :uuid, :text, :integer, :float, :timestamp, :datetime

Setting the primary key using the method `primary_key(pk_name | Array)`:

```ruby
class User < Cassandro::Model

  primary_key [:email, :created_at]

end

```

Setting unique field using the method `unique(field | Array)`:

```ruby
class  User < Cassandro::Model

  unique :email
end
```

__A complete example__

```ruby
class User < Cassandro::Model

  table 'users'

  attribute :email, :text
  attribute :first_name, :text
  attribute :age, :integer
  attribute :created_at, :datetime
  
  primary_key [:email, :created_at]

  unique :email
end
```

### Interacting

Creating a new row:

```ruby
user = User.create(email: 'test1@example.com', first_name: 'Test', age: 30, created_at: DateTime.now)
=> #<User:0x00000001b9dc40
 @attributes=
  {:email=>"test1@example.com",
   :first_name=>"Test",
   :age=>30,
   :created_at=>
    #<DateTime: 2014-11-03T11:34:47-03:00 ((2456965j,52487s,201385585n),-10800s,2299161j)>},
 @errors={},
 @insert_statement=
  #<Cassandra::Statements::Prepared:0xdcd4f8 @cql="          INSERT INTO users(email,first_name,age,created_at)\n          VALUES(?,?,?,?)\n          IF NOT EXISTS\n">,
 @persisted=true>

```

Find:

```ruby
User[email: 'test1@example.com']
=> #<User:0x00000001cc59d8
 @attributes=
  {:email=>"test1@example.com",
   :created_at=>2014-11-03 11:34:47 -0300,
   :age=>30,
   :first_name=>"Test"},
 @errors={},
 @persisted=true>

User.where('email','test1@example.com')
=> #<User:0x00000001cc59d8
 @attributes=
  {:email=>"test1@example.com",
   :created_at=>2014-11-03 11:34:47 -0300,
   :age=>30,
   :first_name=>"Test"},
 @errors={},
 @persisted=true>

```

```ruby
User.all
=> [#<User:0x00000002bc75f8
  @attributes=
   {:email=>"test@example.com",
    :created_at=>2014-11-03 11:30:52 -0300,
    :age=>30,
    :first_name=>"Test"},
  @errors={},
  @persisted=true>,
 #<User:0x00000002bc6b30
  @attributes=
   {:email=>"test1@example.com",
    :created_at=>2014-11-03 11:34:47 -0300,
    :age=>30,
    :first_name=>"Test"},
  @errors={},
  @persisted=true>]
```

```ruby
User.query('created_at > ?', Time.now.to_i)
=> #<Cassandra::Result:0x1fcb254 @rows=[{"email"=>"test@example.com", "created_at"=>2014-11-03 11:30:52 -0300, "age"=>30, "first_name"=>"Test"}, {"email"=>"test1@example.com", "created_at"=>2014-11-03 11:34:47 -0300, "age"=>30, "first_name"=>"Test"}] @last_page=true>
```

Count:

```ruby
User.count('email', 'test@example.com')
=> 1
```

Checking errors:
```ruby
user = User.create(email: 'test1@example.com', first_name: 'Test', age: 30, created_at: DateTime.now)
=> #<User:0x00000001dc7a48
 @attributes=
  {:email=>"test1@example.com",
   :first_name=>"Test",
   :age=>30,
   :created_at=>
    #<DateTime: 2014-11-03T11:36:40-03:00 ((2456965j,52600s,972972939n),-10800s,2299161j)>},
 @errors={:unique=>"user_not_unique"},
 @persisted=false>

user.persisted?
=> false
user.errors
=> {:unique=>"user_not_unique"}

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
