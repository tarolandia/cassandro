module Cassandro
  module SoftDelete
    def self.included(model)
      model.attribute :deleted, :boolean
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

