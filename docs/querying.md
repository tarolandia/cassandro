## Querying

```ruby
class User < Cassandro::Model
  table :users
  
  attribute :email, :text
  attribute :first_name, :text
  attribute :age, :integer
  attribute :created_at, :datetime
  
  primary_key :email
  
  index :first_name
end
```

### Creating a new row:

```ruby
user = User.create(email: 'test1@example.com', first_name: 'Test', age: 30, created_at: DateTime.now)
=> #<User:0x00000001b9dc40 ... @persisted=true>

```

### Updating attributes

#### Using `#save`

```ruby
user.age = 31
user.save
=> true
```

#### Using `#update_attributes`

```ruby
user.update_attributes(first_name: 'Test 1', age: 31)
=> true
```

### Selecting records

#### Find

```ruby
User[email: 'test1@example.com']
=> #<User:0x00000001cc59d8 ... @persisted=true>
```
```ruby
User[email: 'test1@example.com', first_name: 'No Test']
=> nil
```

#### Find all

```ruby
User.all
=> [#<User:0x00000001cc59d8 ... @persisted=true>, #<User:0x00000001cc59d9 ... @persisted=true>, ...]
```
#### Where / Query

```ruby
User.where('first_name','Test 1')
=> [#<User:0x00000001cc59d8 ... @persisted=true>]
```

```ruby
User.query('first_name = ?', 'Test')
=> [#<User:0x00000001cc59d8 ... @persisted=true>, ...]
```

#### Count:

```ruby
User.count('email', 'test@example.com')
=> 1

User.count
=> 2
```

### Deleting

#### Destroy

```ruby
user = User[email: 'test1@example.com']
user.destroy
```

#### Destroy All (truncate table)

```ruby
User.destroy_all
```

### Checking errors:

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


