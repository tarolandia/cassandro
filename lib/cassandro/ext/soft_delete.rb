module Cassandro
  module SoftDelete
    module ClassMethods
      def all(with_deleted = false)
        results = super()

        results.reject!{ |r| r.deleted } unless with_deleted

        results
      end

      def where(key, value, with_deleted = false)
        results = super(key, value)

        results.reject!{ |r| r.deleted } unless with_deleted

        results
      end

      def count(key = nil, value = nil, with_deleted = false)
        return super(key, value) if with_deleted || key === true

        if key && !value.nil?
          results = where(key, value)
        else
          results = all
        end

        results.size
      end

      def query(where, *values)
        with_deleted = where.scan(/\?/).length < values.length && values.pop === true

        results = super(where, *values)

        results.reject!{ |r| r.deleted } unless with_deleted

        results
      end
    end

    def self.included(model)
      model.attribute :deleted, :boolean
      model.extend ClassMethods
    end

    def destroy
      update_attributes(deleted: true)
    end

    def restore
      update_attributes(deleted: false)
    end

    def deleted?
      !!deleted
    end

    def exists?
      !deleted
    end
  end
end

