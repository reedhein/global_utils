module Utils
  module SalesForce
    module Concern
      module Zoho
        def zoho_attach(zoho_sushi, file_data)
          # description = description_from_file_data(file_data)
          begin
            file = ::Zoho::Base.client.download_file(zoho_sushi.module_name, file_data[:id])
            Utils::SalesForce::Client.create('Attachment',
                                              Body: Base64::encode64(file),
                                              Description: "imported from zoho ID: #{zoho_sushi.id}",
                                              Name: file_data[:file_name],
                                              ParentId: id)
            @modified = true
          rescue Errno::ETIMEDOUT
            puts 'api timeout waiting 10 seconds and retrying'
            sleep 10
            retry
          rescue => e
            puts e
            binding.pry
          end
        end

        def find_zoho
          @zoho ||= Utils::Zoho::Base.counterpart(zoho_id__c) || VirtualProxy.new { Utils::SalesForce::Determine.new(self) }
        end

        private

      end
    end
  end
end
