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

### Soft Delete
This will create a record in the `people` table with a TTL of `20` seconds. It doesn't matter if the model has a different TTL set, this will override that TTL for _this record only_

