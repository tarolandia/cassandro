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
    @@session.execute("USE #{keyspace}") if @@session
  end

  def self.disconnect
    @@cluster.close if @cluster
    @@session = nil
  end

  def self.execute(cql_command)
    @@session.execute(cql_command)
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

    @@session.execute(keyspace_definition)
  end

  def self.truncate_table(table_name)
    @@session.execute("TRUNCATE #{table_name}")
  end

  def self.register_table(table_def)
    @@tables << table_def
  end

  def self.load_tables
    @@tables.each do |table_definition|
      queries = table_definition.split(";").map(&:strip)
      queries.each do |query|
        @@session.execute(query) unless query.empty?
      end
    end
  end
end
