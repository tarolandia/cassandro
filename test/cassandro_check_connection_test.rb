require_relative 'helper'

Protest.describe "Cassandro Connection check" do
  setup do
    class Admin < Cassandro::Model
      table :admins
      attribute :nickname, :text
      attribute :age, :integer

      primary_key :nickname
    end

    Cassandro.disconnect
  end

  context "Core" do
    test "raise Exception on #execute" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Cassandro.execute("USE test_keyspace")
      end
    end

    test "raise Exception on #use" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Cassandro.use("test_keyspace")
      end
    end

    test "raise Exception on #create_keyspace" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Cassandro.create_keyspace("test_keyspace")
      end
    end

    test "raise Exception on #truncate_table" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Cassandro.truncate_table("tests")
      end
    end
  end

  context "Model" do
    test "raise Exception on #create" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Admin.create(nickname: "tarolandia")
      end
    end

    test "raise Exception on #save" do
      admin = Admin.new(nickname: "tarolandia")

      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        admin.save
      end
    end

    test "raise Exception on #update_attributes" do
      admin = Admin.new(nickname: "tarolandia")

      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        admin.update_attributes(age: 29)
      end
    end

    test "raise Exception on #[]" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Admin[nickname: "tarolandia"]
      end
    end

    test "raise Exception on #all" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Admin.all
      end
    end

    test "raise Exception on #where" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Admin.where(:nickname, "tarolandia")
      end
    end

    test "raise Exception on #count" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Admin.count
      end
    end

    test "raise Exception on #query" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Admin.query("nickname = ?", "tarolandia")
      end
    end

    test "raise Exception on #ttl" do
      admin = Admin.new(nickname: "tarolandia")

      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        admin.ttl
      end
    end

    test "raise Exception on #create_with_ttl" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Admin.create_with_ttl(20, nickname: "tarolandia", age: 29)
      end
    end

    test "raise Exception on #destroy" do
      admin = Admin.new(nickname: "tarolandia")

      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        admin.destroy
      end
    end

    test "raise Exception on #destroy_all" do
      assert_raise(Cassandra::Errors::ClientError, "Database connection is not stablished") do
        Admin.destroy_all
      end
    end
  end
end
