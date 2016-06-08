module GlobalUtilities
  module Zoho
    module Concern
      module DB
        def self.included(base)
          base.extend(ClassMethods)
        end


        def migration_complete?
          migration_complete
        end

        def mark_completed
          @storage_object.update(complete: true)
          @migration_complete = true
        end

          def find_or_create(api_object)
            self.class.convert_api_object_to_local_storage(api_object)
          end
        module ClassMethods


          def convert_api_object_to_local_storage(api_object)
            ZohoProgressRecord.first_or_create(
              zoho_id: api_object.id,
              module_name: api_object.module_name
            )
          end

          def counterpart(id)
            fail ArgumentError unless id
            corresponding_class = nil
            %w[potential contact lead account].detect do |zoho_object|
              puts "checking against zoho object #{zoho_object}"
              sleep 1
              begin
                corresponding_class = [RubyZoho::Crm, zoho_object.classify].join('::').constantize.find_by_id(zoho_id(id))
              rescue Net::OpenTimeout
                puts "network timeout sleeping 10 seconds then trying again"
                sleep 10
                retry
              end
            end
            return nil if corresponding_class.nil? 
            module_name = corresponding_class.first.module_name.singularize
            ['GlobalUtilities', 'Zoho' , module_name].join('::').constantize.new(corresponding_class.first)
          end

          def zoho_id(id)
            id.gsub('zcrm_', '')
          end
        end
      end
    end
  end
end
