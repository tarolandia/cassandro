### Setting TTL to a model

```Ruby
class Person < Cassandro::Model
  table :people
  ttl 60
end
```
This will make all the instances of the People class will have a Time To Live of `60` seconds in the database.

Creating a single record with a given TTL:

```Ruby
class Person < Cassandro::Model
  table :people
  attribute :first_name, :text
  attribute :last_name, :text
end

Person.create_with_ttl(20, :first_name => "Eddie", :last_name => "Vedder")
```

This will create a record in the `people` table with a TTL of `20` seconds. It doesn't matter if the model has a different TTL set, this will override that TTL for _this record only_

### Enabling Soft Delete


```Ruby
class Person < Cassandro::Model
  include Cassandro::SoftDelete
  
  table :people
end
```

This will add an attribute `:delete` to your model. Next time you use `Model#destroy` your data will not be deleted from database but marked as deleted. You can then use `Model#restore` to unmark it.

Data marked as deleted is not included within `Model#all` method by default. In order to include deleted records you have to send a boolean parameter to `all`.

```ruby
Person.all # => list all but deleted
Person.all(true) # => list all, deleted included
```
