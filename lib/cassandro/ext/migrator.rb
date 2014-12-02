require 'logger'

module Cassandro
  class Migrator

    def initialize(path, logger = ::Logger.new(STDOUT))
      Dir["#{path}/**/*.rb"].each { |file| require file }
      @migrations = Cassandro::Migration.migrations
      @logger = logger

      Cassandro.client.execute CassandroMigration.schema

      version = CassandroMigration[name: 'version'] || CassandroMigration.create(name: 'version', value: "0")

      @current_version = version
    end

    def migrate!(direction, to = '.')
      from = @current_version.value.to_i

      case direction
      when :up
        to   = (to == '.' ? @migrations.size - 1 : to).to_i
        return @logger.error "Can't migrate up to a prev version (#{from} to #{to})" if to < from
        return @logger.info  "Database is up to date" if to == from

        @logger.info "Upgrading database from version #{from} to #{to}"
        begin
          @migrations[from+1..to].each do |migration|
            Object.const_get(migration).apply(:up)
          end
          @current_version.update_attributes(value: to.to_s)
          @logger.info "OK"
        rescue => e
          @logger.error "#{e.message}\n#{e.backtrace}"
        end
      when :down
        to   = (to == '.' ? 0 : to).to_i
        return @logger.error "Can't migrate down to a higher version (#{from} to #{to})" if to > from
        return @logger.info  "Database is up to date" if to == from

        @logger.info "Drowngrading database from version #{from} to #{to}"
        begin
          @migrations[to+1..from].reverse_each do |migration|
            Object.const_get(migration).apply(:down)
          end
          @current_version.update_attributes(value: to.to_s)
          @logger.info "OK"
        rescue => e
          @logger.error "#{e.message}\n#{e.backtrace}"
        end
      end
    end

    class CassandroMigration < Cassandro::Model
      table :cassandro_migrations

      attribute :name, :text
      attribute :value, :text

      primary_key [:name]

      def self.schema
        <<-TABLEDEF
          CREATE TABLE IF NOT EXISTS cassandro_migrations (
            name VARCHAR,
            value VARCHAR,
            PRIMARY KEY (name)
          )
        TABLEDEF
      end
    end
  end
end
