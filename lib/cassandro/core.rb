require 'cassandra'

module Cassandro
  @@cluster = nil
  @@session = nil
  @@tables = []

  def self.cluster
    @@cluster
  end

  def self.client
    @@session
  end

  def self.tables
    @@tables
  end

  def self.connect(options = {})
    keyspace = options.delete(:keyspace)
    @@cluster = Cassandra.cluster(options)
    @@session = @@cluster.connect(keyspace || nil)
  end

  def self.use(keyspace)
    execute("USE #{keyspace}")
  end

  def self.disconnect
    @@cluster.close if @cluster
    @@session = nil
  end

  def self.connected?
    !@@session.nil?
  end

  def self.check_connection!
    raise Cassandra::Errors::ClientError.new("Database connection is not established") unless connected?
  end

  def self.execute(statement, options = nil)
    check_connection!
    @@session.execute(statement, options)
  end

  def self.prepare(statement, options = nil)
    check_connection!
    @@session.prepare(statement, options)
  end

  def self.create_keyspace(name, options = { replication: { class: 'SimpleStrategy', replication_factor: 1}} )
    with = "WITH " + options.map do |key, option|
      param_string = "#{key.to_s.upcase} = " +
      if option.is_a?(Hash)
        "{ #{option.map { |k,v| "'#{k}': #{v.is_a?(String) ? "'#{v}'": v.to_s}" }.join(", ")} }"
      else
        option.is_a?(String) ? "'#{option}'": option.to_s
      end
    end.join(" AND ")

    keyspace_definition = <<-KSDEF
      CREATE KEYSPACE IF NOT EXISTS #{name}
      #{with}
    KSDEF

    execute(keyspace_definition)
  end

  def self.truncate_table(table_name)
    execute("TRUNCATE #{table_name}")
  end

  def self.register_table(table_def)
    @@tables << table_def
  end

  def self.load_tables
    check_connection!
    @@tables.each do |table_definition|
      queries = table_definition.split(";").map(&:strip)
      queries.each do |query|
        execute(query) unless query.empty?
      end
    end
  end
end

# Patch: Make params_metadata public for Prepared Statements
module Cassandra
  module Statements
    class Prepared
      attr_reader :params_metadata
    end
  end
end
