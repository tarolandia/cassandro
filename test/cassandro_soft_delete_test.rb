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
end


