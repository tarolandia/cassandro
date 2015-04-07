module Cassandro
  class Model
    class ModelException < StandardError; end

    attr_reader :attributes

    def initialize(attrs = {}, persisted = false)
      @attributes = {}
      @errors = {}
      @persisted = persisted

      attrs.each do |att, val|
        next unless self.respond_to?(:"#{att}=")
        case val.class.name
        when "Set"
          send(:"#{att}=", val.to_a)
        when "Cassandra::Uuid"
          send(:"#{att}=", val.to_s)
        when "Time"
          send(:"#{att}=", val.to_datetime)
        else
          send(:"#{att}=", val)
        end
      end
    end

    def persisted?
      @persisted
    end

    def errors
      @errors
    end

    def clear_errors
      @errors = {}
    end

    def valid?
      self.class.pk.any? && @errors.empty?
    end

    def cast(attribute)
      self.class.cast_as(attribute, @attributes[attribute])
    end

    def unique?
      self.class.uniqueness_defined? ? self.class[@attributes.slice(*self.class.uniques)].nil? : true
    end

    def update_attributes(attrs = {})
      attrs = attrs.inject({}) do |memo, (k,v)|
        memo[k.to_sym] = (v.nil? || v.to_s.empty?) ? nil : v #TODO: fix for Set, Map
        memo
      end#symbolize keys for later merge

      p_keys = []
      fields = []

      self.class.pk.flatten.each do |k|
        p_keys << "#{k} = #{cast(k)}"
      end

      attrs.keys.each do |field|
        fields << "#{field} = ?"
      end

      query = "UPDATE #{self.class.table_name} SET #{fields.join(", ")} "
      query += "WHERE #{p_keys.join(" AND ")}"

      begin
        st = Cassandro.client.prepare(query)
        Cassandro.client.execute(st, arguments: native_attributes(attrs))
        @attributes.merge!(attrs)
        true
      rescue Exception => e
        @errors[:update_error] = e.message
        false
      end
    end

    def save(insert_check = false)
      clear_errors

      if self.class.casts[:id] == :uuid
        @attributes[:id] ||= SecureRandom.uuid
      end

      self.class.pk.flatten.each do |key|
        if @attributes[key].nil?
          @errors[:primary_key] = "#{key.to_s}_cant_be_nil"
          return false
        end
      end

      if !persisted? && self.class.uniqueness_defined? && !unique?
        @errors[:unique] = "#{self.class.to_s.downcase}_not_unique"
        return false
      end

      st = self.statement_for(:insert, :insert_check => insert_check)

      begin
        r = Cassandro.client.execute(st, arguments: self.native_attributes)
        raise ModelException.new('not_applied') unless !insert_check || (insert_check && r.first["[applied]"])
        @persisted = true
      rescue => e
        @attributes[:id] = nil if !persisted? && @attributes.has_key?(:id)
        @errors[:save] = e.message
        false
      end
    end

    def destroy
      query = <<-QUERY
        DELETE FROM #{self.class.table_name}
        WHERE #{self.class.pk.flatten.map { |k| "#{k.to_s} = #{self.class.cast_as(k, @attributes[k])}" }.join(' AND ')}
      QUERY
      Cassandro.execute(query)
    end

    def ttl
      query = <<-QUERY
        SELECT TTL(#{@attributes.keys.last}) FROM #{self.class.table_name}
        WHERE #{self.class.pk.flatten.map { |k| "#{k.to_s} = #{self.class.cast_as(k, @attributes[k])}" }.join(' AND ')}
      QUERY
      result = Cassandro.execute(query)
      result.any? ? result.first.values.first : nil
    end

    def self.table(name)
      self.table_name = name.to_s
    end

    def self.attribute(name, type = String, options = {})
      return if attributes.include?(name)
      attributes << name
      casts[name] = type

      define_method(name) do
        @attributes[name]
      end

      define_method(:"#{name}=") do |value|
        @attributes[name] = value
      end
    end

    def self.primary_key(keys)
      if keys.is_a?(Array)
        pk.merge(keys)
      else
        pk.add(keys)
      end
    end

    def self.unique(keys)
      if keys.is_a?(Array)
        uniques.merge(keys)
      else
        uniques.add(keys)
      end
    end

    def self.index(keys)
      if keys.is_a?(Array)
        indexes.merge(keys)
      else
        indexes.add(keys)
      end
    end

    def self.[](value)
      return nil if value.nil? || (value.respond_to?(:empty?) && value.empty?)

      if value.is_a?(Hash)
        where = "#{value.keys.map{ |k| "#{k} = ?" }.join(' AND ')} ALLOW FILTERING"
        values = value.map{ |k,v| casts[k] == :uuid ? Cassandra::Uuid.new(v) : v }
      else
        where = "#{partition_key} = ?"
        values = [casts[partition_key] == :uuid ? Cassandra::Uuid.new(value) : value]
      end

      query = <<-QUERY
        SELECT *
        FROM #{table_name}
        WHERE #{where}
      QUERY

      st = Cassandro.client.prepare(query)
      result = Cassandro.client.execute(st, arguments: values)

      return nil unless result.any?

      self.new(self.parse_row(result.first), true)
    end

    def self.create(attrs = {})
      model = new(attrs)
      model.save(true)

      model
    end

    def self.create_with_ttl(seconds, attrs = {})
      old_ttl = self.options[:ttl]
      self.options[:ttl] = seconds.to_i

      result = self.create(attrs)

      old_ttl ? self.options[:ttl] = old_ttl : self.options.delete(:ttl)
      result
    end

    def self.all
      query = "SELECT * FROM #{self.table_name}"

      rows = Cassandro.execute(query)
      all = []
      rows.each do |row|
        all << new(self.parse_row(row), true)
      end
      all
    end

    def self.where(key, value)
      key = key.to_sym
      results = []

      query = "SELECT * FROM #{table_name} WHERE #{key} = ? ALLOW FILTERING"

      st = Cassandro.client.prepare(query)
      rows = Cassandro.client.execute(st, arguments: [value])

      rows.each do |result|
        results << new(result, true)
      end

      results
    end

    def self.count(key = nil, value = nil)
      query = "SELECT count(*) FROM #{table_name}"

      if key && value
        key = key.to_sym
        query << " WHERE #{key} = ? ALLOW FILTERING"
        st = Cassandro.client.prepare(query)
        results = Cassandro.client.execute(st, arguments: [value])
      else
        results = Cassandro.client.execute(query)
      end

      results.first["count"]
    end

    def self.destroy_all
      begin
        query = "TRUNCATE #{table_name}"
        st = Cassandro.execute(query)
        st.is_a? Cassandra::Client::VoidResult
      rescue e
        false
      end
    end

    def self.query(where, *values)
      results = []

      query = "SELECT * FROM #{table_name} WHERE #{where} ALLOW FILTERING"
      st = Cassandro.client.prepare(query)
      rows = Cassandro.client.execute(st, arguments: values)


      rows.each do |result|
        results << new(result, true)
      end

      results
    end

    protected
    def self.attributes
      @attributes ||= []
    end

    def self.pk
      @pk ||= Set.new
    end

    def self.table_name
      @table_name ||= name.downcase
    end

    def self.table_name=(name)
      @table_name = name
    end

    def self.casts
      @cast ||= {}
    end

    def self.uniques
      @unique ||= Set.new
    end

    def self.indexes
      @indexes ||= Set.new
    end

    def self.uniqueness_defined?
      uniques.any?
    end

    def self.cast_as(key, value)
      return "NULL" if value.nil?

      case casts[key]
      when :text
        "'#{value}'"
      when :int, :integer
        value.to_i
      when :datetime
        value.strftime("%Q").to_i
      else
        "#{value}"
      end
    end

    def self.partition_key
      pk.first
    end

    def self.options
      @options ||= {}
    end

    def self.ttl(seconds)
      self.options[:ttl] = seconds.to_i
    end

    def statement_for(operation, options = {})
      case operation
      when :insert
        #INSERT will update if the record already exists http://www.datastax.com/documentation/cql/3.0/cql/cql_reference/insert_r.html
        query = <<-QUERY
          INSERT INTO #{self.class.table_name}(#{@attributes.keys.map { |x| x.to_s}.join(',')})
          VALUES(#{@attributes.keys.map { |x| '?' }.join(",")})
          #{options[:insert_check] ? 'IF NOT EXISTS' : ''}
          #{self.class.options[:ttl] && self.class.options[:ttl] > 0 ? "USING TTL #{self.class.options[:ttl]}" : ''}
        QUERY
        if @insert_statement.nil? ||
                      @insert_statement.params_metadata.count != @attributes.count
          @insert_statement = Cassandro.client.prepare(query)
        else
          @insert_statement
        end
      end
    end

    def native_attributes(attrs = nil)
      n_attrs = []
      attrs ||= @attributes

      attrs.each do |k, v|
        # bypassed nil values to avoid type casting errors
        if attrs[k].nil?
          n_attrs << nil
          next
        end

        case self.class.casts[k]
        when :set
          n_attrs << Set.new(attrs[k])
        when :uuid
          n_attrs << Cassandra::Uuid.new(attrs[k])
        when :integer
          n_attrs << attrs[k].to_i
        when :float
          n_attrs << attrs[k].to_f
        when :datetime
          n_attrs << attrs[k].to_time
        else
          n_attrs << attrs[k]
        end
      end
      n_attrs
    end

    def self.parse_row(row)
      row.each{ |k,v| row[k] = [] if casts[k.to_sym] == :set && v.nil? }
    end
  end
end
