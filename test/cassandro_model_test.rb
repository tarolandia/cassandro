require_relative 'helper'
require_relative 'support/tables'
require 'securerandom'

Protest.describe "Cassandro Model" do
  setup do
    Cassandro.connect(hosts: ['127.0.0.1'], keyspace: 'cassandro_test')
  end

  context 'Modeling' do
    setup do
      class Test < Cassandro::Model
      end
    end

    test "adds table name" do
      class Test < Cassandro::Model
        table 'tests'
      end
      assert_equal 'tests', Test.table_name
    end

    test "adds attribute" do
      class Test < Cassandro::Model
        attribute :test_col_1, :uuid
        attribute :test_col_2, :text
      end
      assert Test.attributes.include?(:test_col_1)
      assert Test.attributes.include?(:test_col_2)
    end

    test "adds primary key" do
      class Test < Cassandro::Model
        primary_key :test_col_1
      end
      assert Test.pk.include?(:test_col_1)
    end

    test "adds unique field" do
      class Test < Cassandro::Model
        unique :test_col_1
      end
      assert Test.uniques.include?(:test_col_1)
      assert Test.uniqueness_defined?
    end

    test "adds index" do
      class Test < Cassandro::Model
        index :test_col_2
      end

      assert Test.indexes.include?(:test_col_2)
    end

    test "adds multiple indexes" do
      class Test < Cassandro::Model
        attribute :test_col_3, :text
        attribute :test_col_4, :text
        attribute :test_col_5, :text

        index :test_col_3
        index [:test_col_4, :test_col_5]
      end
      assert Test.indexes.include?(:test_col_3)
      assert Test.indexes.include?(:test_col_4)
      assert Test.indexes.include?(:test_col_5)
    end

    test "allows setting and getting attributes" do
      uuid = SecureRandom.uuid
      test = Test.new(test_col_1: uuid, test_col_2: 'test_value_2')
      assert_equal uuid.to_s, test.test_col_1
      assert_equal 'test_value_2', test.test_col_2
    end
  end

  context 'Creating' do
    setup do
      class Test < Cassandro::Model
        table 'tests'

        attribute :test_col_1, :uuid
        attribute :test_col_2, :text

        primary_key :test_col_1
        unique :test_col_1
      end

      Cassandro.truncate_table('tests')
    end

    test "creates a row" do
      test = Test.create(test_col_1: SecureRandom.uuid, test_col_2: 'test_value_2')
      assert test.persisted?
    end

    test "fails creating dup row" do
      uuid = SecureRandom.uuid
      test_1 = Test.create(test_col_1: uuid, test_col_2: 'test_value_2')
      test_2 = Test.create(test_col_1: uuid, test_col_2: 'test_value_2')
      assert !test_2.persisted?
      assert_equal "test_not_unique", test_2.errors[:unique]
    end
  end

  context 'Saving' do
    setup do
      class TestAttributes < Cassandro::Model
        table 'tests_attributes'

        attribute :test_col_1, :uuid
        attribute :test_col_2, :text
        attribute :test_col_3, :datetime

        primary_key :test_col_1
        unique :test_col_1
      end

      Cassandro.truncate_table('tests_attributes')
    end

    test "save a row with nil values" do
      test = TestAttributes.create(test_col_1: SecureRandom.uuid, test_col_2: 'test_value_2', test_col_3: DateTime.now)
      test.test_col_3 = nil
      assert test.save
      assert test.persisted?
    end
  end

  context 'Querying' do
    setup do
      class Test < Cassandro::Model
        table 'tests'

        attribute :test_col_1, :uuid
        attribute :test_col_2, :text

        primary_key :test_col_1
        unique :test_col_1
      end

      Cassandro.truncate_table('tests')
    end

    test "gets row" do
      uuid = SecureRandom.uuid
      Test.create(test_col_1: uuid, test_col_2: 'test_value_2')
      test = Test[uuid]
      assert_equal uuid.to_s, test.test_col_1.to_s
      assert_equal "test_value_2", test.test_col_2
    end

    test "gets row with nil or empty values" do
      test = Test[nil]
      assert_equal nil, test

      test = Test[""]
      assert_equal nil, test

      test = Test[{}]
      assert_equal nil, test
    end

    test "counts the rows" do
      Test.create(test_col_1: SecureRandom.uuid, test_col_2: 'test_value_2')
      Test.create(test_col_1: SecureRandom.uuid, test_col_2: 'test_value_2')

      assert_equal Test.all.size, Test.count
    end

    test "counts the rows with filter" do
      uuid = SecureRandom.uuid
      Test.create(test_col_1: uuid, test_col_2: 'test_value_2')
      Test.create(test_col_1: SecureRandom.uuid, test_col_2: 'test_value_2')

      assert_equal 1, Test.count(:test_col_1, Cassandra::Uuid.new(uuid))
    end

    test "ignore columns not defined in model" do
      uuid = SecureRandom.uuid
      Test.create(test_col_1: uuid, test_col_2: 'test_value_2')

      tests = Test[uuid]
      assert_equal false, tests.respond_to?("test_col_ignored")
    end
  end

  context 'Updating' do
    setup do
      class Patient < Cassandro::Model
        table :patients
        attribute :name, :text
        attribute :address, :text
        attribute :age, :int

        primary_key :name
      end
      Cassandro.truncate_table('patients')
    end

    test "updates attributes" do
      patient = Patient.create(:name => "John Doe", :address => "Somewhere", :age => 30)
      assert_equal 1, Patient.all.count

      assert patient.update_attributes(:address => "Somewhere Else")
      assert_equal 1, Patient.all.count
      assert_equal "Somewhere Else", patient.address
    end

    test "won't update primary keys" do
      patient = Patient.create(:name => "John Doe", :address => "Somewhere", :age => 30)

      assert !patient.update_attributes(:name => "Jane Doe")
      assert_equal "PRIMARY KEY part name found in SET part", patient.errors[:update_error]
    end
  end

  context 'TTL' do
    setup do
      class Test < Cassandro::Model
        table 'tests'

        ttl 20

        attribute :test_col_1, :uuid
        attribute :test_col_2, :text

        primary_key :test_col_1
        unique :test_col_1
      end

      class Patient < Cassandro::Model
        table :patients

        attribute :name, :text
        attribute :address, :text
        attribute :age, :int

        primary_key [:name]
      end
      Cassandro.truncate_table('patients')
    end

    test "should create with TTL defined by the model" do
      volatile_record = Test.create(:test_col_1 => SecureRandom.uuid, :test_col_2 => "Test Text")
      results = Cassandro.execute "SELECT TTL(test_col_2) FROM tests WHERE test_col_1 = #{volatile_record.test_col_1}"

      assert results.first["ttl(test_col_2)"] > 0
      assert results.first["ttl(test_col_2)"] <= 20
    end

    test "should override TTL defined by the model" do
      volatile_record = Test.create_with_ttl(10, :test_col_1 => SecureRandom.uuid, :test_col_2 => "Test Text")
      results = Cassandro.execute "SELECT TTL(test_col_2) FROM tests WHERE test_col_1 = #{volatile_record.test_col_1}"

      assert results.first["ttl(test_col_2)"] > 0
      assert results.first["ttl(test_col_2)"] <= 10
    end

    test "should be able to create with TTL if not specified in the model" do
      dog = Patient.create(:name => "Cassandro", :address => "cassandstreet", :age => 1)
      results = Cassandro.execute "SELECT TTL(address) FROM patients WHERE name = 'Cassandro'"

      assert !results.first["ttl(address)"]

      cat = Patient.create_with_ttl(30, :name => "Cassandra", :address => "cassandstreet 123", :age => 2)
      results = Cassandro.execute "SELECT TTL(address) FROM patients WHERE name = 'Cassandra'"

      assert results.first["ttl(address)"] > 0
      assert results.first["ttl(address)"] <= 30
    end

    test "should get TTL" do
      patient = Patient.create_with_ttl(20, :name => "Cassandro Get", :address => "cassandstreet", :age => 1)
      assert patient.ttl > 0
      assert patient.ttl <= 20
    end
  end
end
