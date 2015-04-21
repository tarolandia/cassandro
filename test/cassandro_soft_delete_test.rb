require_relative 'helper'
require_relative 'support/tables'

Protest.describe "Cassandro Model Soft Delete" do
  setup do
    Cassandro.connect(hosts: ['127.0.0.1'], keyspace: 'cassandro_test')

    class Admin < Cassandro::Model
      include Cassandro::SoftDelete

      table :admins
      attribute :nickname, :text

      primary_key :nickname
    end


    Admin.all(true).each do |a|
      Cassandro.execute("DELETE FROM admins WHERE nickname = '#{a.nickname}'")
    end
  end

  test "all not include deleted" do
    me = Admin.create(:nickname => "k4nd4lf")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert !Admin.all.include?(me)
  end

  test "all should include deleted if asked" do
    me = Admin.create(:nickname => "k4nd4lf")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert !Admin.all.include?(me)

  end

  test "#where not includes deleted" do
    me = Admin.create(:nickname => "tarolandia")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert_equal 0, Admin.where(:nickname, "tarolandia").size
  end

  test "#where should include deleted if asked" do
    me = Admin.create(:nickname => "tarolandia")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert_equal 1, Admin.where(:nickname, "tarolandia", true).size
  end

  test "#count not includes deleted" do
    me = Admin.create(:nickname => "tarolandia")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert_equal 1, Admin.count
  end

  test "#count should include deleted if asked" do
    me = Admin.create(:nickname => "tarolandia")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert_equal 2, Admin.count(true)
  end

  test "#count should filter by key and exclude deleted" do
    me = Admin.create(:nickname => "tarolandia")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert_equal 0, Admin.count(:nickname, "tarolandia")
  end

  test "#count should filter by key including deleted" do
    me = Admin.create(:nickname => "tarolandia")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert_equal 1, Admin.count(:nickname, "tarolandia", true)
  end

  test "#query not includes deleted" do
    me = Admin.create(:nickname => "tarolandia")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert_equal 0, Admin.query("nickname = ?", "tarolandia").size
  end

  test "#query should include deleted if asked" do
    me = Admin.create(:nickname => "tarolandia")
    other = Admin.create(:nickname => "Jim")

    me.destroy

    assert_equal 1, Admin.query("nickname = ?", "tarolandia", true).size
  end
end


