require_relative 'helper'

Protest.describe "Cassandro Migration" do
  setup do
    Cassandro.connect(hosts: ['127.0.0.1'], keyspace: 'cassandro_test')
  end

  test "enqueue migrations" do
    Cassandro::Migration.clean

    class FirstMigration < Cassandro::Migration
      version 1
    end

    class SecondMigration < Cassandro::Migration
      version 2
    end

    assert_equal 2, Cassandro::Migration.migrations.compact.size
    assert_equal "FirstMigration", Cassandro::Migration.migrations[1]
    assert_equal "SecondMigration", Cassandro::Migration.migrations[2]
  end
end
