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
