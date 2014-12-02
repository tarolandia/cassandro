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

