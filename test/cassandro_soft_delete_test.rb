require_relative 'helper'
require_relative 'support/tables'

Protest.describe "Cassandro Model Soft Delete" do
  setup do
    Cassandro.connect(hosts: ['127.0.0.1'], keyspace: 'cassandro_test')

    class User < Cassandro::Model
      include Cassandro::SoftDelete

      table :users
      attribute :nickname, :text

      primary_key :nickname
    end


    User.all(true).each do |u|
      Cassandro.execute("DELETE FROM users WHERE nickname = '#{u.nickname}'")
    end
  end

  test "all not include deleted" do

    me = User.create(:nickname => "k4nd4lf")
    other = User.create(:nickname => "Jim")

    me.destroy

    assert !User.all.include?(me)
  end

  test "all should include deleted if asked" do
    me = User.create(:nickname => "k4nd4lf")
    other = User.create(:nickname => "Jim")

    me.destroy

    assert !User.all.include?(me)

  end
end


