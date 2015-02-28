module Cassandro
  module SoftDelete
    module ClassMethods
      def all(with_deleted = false)
        results = super()

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

