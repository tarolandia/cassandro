require 'rack/test'
require 'protest'

require_relative '../lib/cassandro'

CASSANDRA = Cassandra.cluster(hosts: ['127.0.0.1'])
SESSION = CASSANDRA.connect

keyspace_definition = <<-KSDEF
  CREATE KEYSPACE IF NOT EXISTS cassandro_test
  WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
  }
KSDEF

SESSION.execute(keyspace_definition)
SESSION.execute("USE cassandro_test")

class Protest::TestCase
  include Rack::Test::Methods
end

Protest.report_with(:turn)
