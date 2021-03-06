## TTL

### Setting TTL to a model

```Ruby
class Person < Cassandro::Model
  table :people
  ttl 60
end
```
This will make all the instances of the People class will have a Time To Live of `60` seconds in the database.

### Creating a single record with a given TTL:

```Ruby
class Person < Cassandro::Model
  table :people
  attribute :first_name, :text
  attribute :last_name, :text
end

Person.create_with_ttl(20, :first_name => "Eddie", :last_name => "Vedder")
```

This will create a record in the `people` table with a TTL of `20` seconds. It doesn't matter if the model has a different TTL set, this will override that TTL for _this record only_

### Getting TTL

After creating a record with a TTL you can use method `Model#ttl` to get the value.

```Ruby
person = Person.create_with_ttl(20, :first_name => "John", :last_name => "Lennon")

person.ttl # => 20

# ...

person.ttl # => 18
```

## Enabling Soft Delete


```Ruby
class Person < Cassandro::Model
  include Cassandro::SoftDelete
  
  table :people
end
```

This will add an attribute `:delete` to your model. Next time you use `Model#destroy` your data will not be deleted from database but marked as deleted. You can then use `Model#restore` to unmark it.

Data marked as deleted is not included within find methods by default. In order to include deleted records you have to send a boolean parameter:

### All

```ruby
Person.all # => list all but deleted
Person.all(true) # => list all, deleted included
```

### Where

```ruby
Person.where(:gender, "male") # => list "male" but deleted
Person.where(:gender, "male", true) # => list "male", deleted included
```

### Count

```ruby
Person.count # => count all but deleted
Person.count(true) # => count all deleted included

# with filter
Person.count(:gender, "female") # => count all "female" but deleted
Person.count(:gender, "female", true) # => count all "female" deleted included
```

### Query

```ruby
Person.query("gender = ? AND admin = ?", "male", true) # => list "male" "admins" but deleted
Person.query("gender = ? AND admin = ?", "male", true, true) # => list "male" "admins", deleted included
```
