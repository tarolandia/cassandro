require_relative 'helper'

Protest.describe "Cassandro Module" do
  setup do
    SESSION.execute("DROP KEYSPACE IF EXISTS test_keyspace")
  end

  test "must connect to database" do
    client = Cassandro.connect(hosts: ["127.0.0.1"])
    assert_equal Cassandra::Session, client.class
  end

  test "must create new keyspace" do
    Cassandro.connect(hosts: ["127.0.0.1"])
    assert_equal Cassandra::Results::Void, Cassandro.create_keyspace("test_keyspace").class
    assert_equal NilClass, Cassandro.use("test_keyspace").class
  end
end

