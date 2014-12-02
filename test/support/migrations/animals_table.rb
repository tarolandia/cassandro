class AnimalMigration < Cassandro::Migration
  version 3

  def up
    execute <<-TABLEDEF
      CREATE TABLE animals (
        family VARCHAR,
        genus VARCHAR,
        name VARCHAR,
        PRIMARY KEY(family, genus)
      )
    TABLEDEF
  end

  def down
    execute <<-QUERY
      DROP TABLE animals;
    QUERY
  end
end
