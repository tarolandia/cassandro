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


