SESSION.execute("DROP TABLE IF EXISTS tests")
table = <<-TABLEDEF
  CREATE TABLE IF NOT EXISTS tests (
    test_col_1 UUID,
    test_col_2 VARCHAR,
    PRIMARY KEY(test_col_1)
  )
TABLEDEF
SESSION.execute(table)

SESSION.execute("DROP TABLE IF EXISTS tests_attributes")
table = <<-TABLEDEF
  CREATE TABLE IF NOT EXISTS tests_attributes (
    test_col_1 UUID,
    test_col_2 VARCHAR,
    test_col_3 TIMESTAMP,
    PRIMARY KEY(test_col_1)
  )
TABLEDEF
SESSION.execute(table)

SESSION.execute("DROP TABLE IF EXISTS patients")
table = <<-TABLEDEF
  CREATE TABLE IF NOT EXISTS patients (
    name VARCHAR,
    address VARCHAR,
    age INT,
    PRIMARY KEY(name)
  )
TABLEDEF
SESSION.execute(table)

SESSION.execute("DROP TABLE IF EXISTS admins")
table = <<-TABLEDEF
  CREATE TABLE IF NOT EXISTS admins (
    nickname VARCHAR,
    deleted BOOLEAN,
    PRIMARY KEY(nickname)
  )
TABLEDEF
SESSION.execute(table)
