module Cassandro
  class Migration
    @@migrations = []

    def up; end

    def down; end

    def execute(query)
      Cassandro.client.execute(query)
    end

    def self.version(version_number)
      @@migrations[version_number.to_i] = self.name
    end

    def self.migrations
      @@migrations.compact
    end

    def self.apply(direction = :up)
      new.send(direction)
    end
  end
end
