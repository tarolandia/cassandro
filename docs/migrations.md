## Migrations

Define your migrations by extending from `Cassandro::Migration`

```ruby
class UserMigration < Cassandro::Migration
  version 1

  def up
    execute <<-TABLEDEF
      CREATE TABLE users (
        id UUID,
        first_name VARCHAR,
        last_name VARCHAR,
        email VARCHAR,
        PRIMARY KEY(id, email)
      )
    TABLEDEF
  end

  def down
    execute <<-QUERY
      DROP TABLE users;
    QUERY
  end
end

class UserGenderMigration < Cassandro::Migration

  version 2

  def up
    execute <<-TABLEUPDATE
      ALTER TABLE users ADD gender VARCHAR
    TABLEUPDATE
  end

  def down
    execute <<-QUERY
      ALTER TABLE users DROP gender
    QUERY
  end
end
```

Then use `Cassandro::Migrator` to run your migrations

```ruby
Cassandro.connect(hosts: ['127.0.0.1'], keyspace: 'some_keyspace')

migrator = Cassandro::Migrator.new('./path/to/migrations', Logger.new(STDOUT))

migrator.migrate!(:up) #migrates to last version
migrator.migrate!(:down) #apply all downgrades

migrator.migrate!(:up, 2) #migrates up to version 2
migrator.migrate!(:down, 1) #migrates down to version 1
```


