module GlobalUtilities
  module SalesForce
    module Concern
      module DB
        # This class is mostly for hooking in DB functionality
        def self.included(base)
          base.extend(ClassMethods)
        end

        def convert_api_object_to_local_storage(api_object)
          SalesForceProgressRecord.first_or_create(
            sales_force_id: api_object.fetch('Id'),
            object_type: api_object.fetch('attributes').fetch('type'),
            created_date: DateTime.parse(api_object.fetch('CreatedDate'))
          )
        end

        def migration_complete?
          @migration_complete ||= @storage_object.complete
        end

        def mark_completed
          @storage_object.complete = true
          @migration_complete = true if @storage_object.save
        end

        def modified?
          @modified
        end

        module ClassMethods
        end
      end
    end
  end
end
