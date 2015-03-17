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
end
