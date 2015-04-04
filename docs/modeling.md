## Cassandro::Model

### Creating model

#### Creating new model

Make you class inherits form `Cassandro::Model`

```ruby
class User < Cassandro::Model
end
```
#### Table name

Specify table name using the method `table(table_name)`:

```ruby
class User < Cassandro::Model

  table 'users'
end
```

#### Attributes

Add attributes using the method `attribute(name, type, options)`:

```ruby
class User < Cassandro::Model

  attribute :email, :text
  attribute :first_name, :text
  attribute :age, :integer
  attribute :created_at, :datetime
end
```

Types: `:uuid`, `:text`, `:integer`, `:float`, `:timestamp`, `:datetime`, `:set`

#### Primary Key

Set the primary key using the method `primary_key(pk_name | Array)`:

```ruby
class User < Cassandro::Model

  primary_key [:email, :created_at]

end

```

#### Unique

Set unique fields using the method `unique(field | Array)`:

```ruby
class  User < Cassandro::Model

  unique :email
end
```

#### Index

Set indexes using the method `index(field | Array)`. Note registering indexes in your model is only a refence.

```ruby
class  User < Cassandro::Model

  index :age
end

#### A complete example

```ruby
class User < Cassandro::Model

  table 'users'

  attribute :email, :text
  attribute :first_name, :text
  attribute :age, :integer
  attribute :created_at, :datetime
  
  primary_key [:email, :created_at]

  unique :email
  
  index :age
end
```
