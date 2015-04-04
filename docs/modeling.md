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

