require_relative 'helper'

Protest.describe "Cassandro Migrator" do
  Cassandro.connect(hosts: ['127.0.0.1'], keyspace: 'cassandro_test')
  setup do
    #Cassandro::Migration.cleaassandra::Errors::InvalidError
    Cassandro.client.execute("DROP TABLE IF EXISTS users")
    Cassandro.client.execute("DROP TABLE IF EXISTS animals")
    Cassandro.client.execute("DROP TABLE IF EXISTS cassandro_migrations")
    @migrator = Cassandro::Migrator.new("./test/support/migrations", Logger.new('/dev/null'))
  end

  context "Migrating up" do

    test "to last version" do
       @migrator.migrate!(:up)
       version = Cassandro::Migrator::CassandroMigration[name: 'version']

       assert_equal 3, version.value.to_i
       assert_equal Cassandra::Results::Paged, Cassandro.client.execute("SELECT * FROM users").class
       assert_equal Cassandra::Results::Paged, Cassandro.client.execute("SELECT * FROM animals").class
    end

    test "to specific version" do
      @migrator.migrate!(:up, 1)
      version = Cassandro::Migrator::CassandroMigration[name: 'version']

      assert_equal 1, version.value.to_i
      assert_equal Cassandra::Results::Paged, Cassandro.client.execute("SELECT * FROM users").class
      assert_raise Cassandra::Errors::InvalidError, "unconfigured columnfamily animals" do
        Cassandro.client.execute("SELECT * FROM animals")
      end
    end
  end

  context 'Migrating down' do
    setup do
      @migrator.migrate!(:up)
    end

    test "to version 0" do
      @migrator.migrate!(:down)

      version = Cassandro::Migrator::CassandroMigration[name: 'version']

      assert_equal 0, version.value.to_i
      assert_raise Cassandra::Errors::InvalidError, "unconfigured columnfamily users" do
        Cassandro.client.execute("SELECT * FROM users")
      end
      assert_raise Cassandra::Errors::InvalidError, "unconfigured columnfamily animals" do
        Cassandro.client.execute("SELECT * FROM animals")
      end
    end

    test "to specific version" do
      @migrator.migrate!(:down, 1)

      version = Cassandro::Migrator::CassandroMigration[name: 'version']

      assert_equal 1, version.value.to_i
      assert_equal Cassandra::Results::Paged, Cassandro.client.execute("SELECT * FROM users").class
      assert_raise Cassandra::Errors::InvalidError, "unconfigured columnfamily animals" do
        Cassandro.client.execute("SELECT * FROM animals")
      end
    end
  end
end
