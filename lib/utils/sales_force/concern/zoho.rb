module Utils
  module SalesForce
    module Concern
      module Zoho
        def zoho_attach(zoho_sushi, file_data)
          sf_file = file_already_present?(file_data)
          if sf_file
            sf_file #=> entity
          else
            transfer_from_zoho
          end
        end

        def find_zoho
          @zoho ||= Utils::Zoho::Base.counterpart(zoho_id__c) || VirtualProxy.new { Utils::SalesForce::Determine.new(self) }
        end

        private

        def file_already_present?(file_data)
          puts 'testing for presence'
          attachments.entries.detect{|attachment| attachment.fetch('Name') == file_data[:file_name] }
        end

        def transfer_from_zoho
          begin
            file = ::Zoho::Base.client.download_file(zoho_sushi.module_name, file_data[:id])
            sf_file = Utils::SalesForce::Client.create('Attachment',
                                                        Body: Base64::encode64(file),
                                                        Description: "imported from zoho ID: #{zoho_sushi.id}",
                                                        Name: file_data[:file_name],
                                                        ParentId: id
                                                      )
            @modified = true
          rescue Errno::ETIMEDOUT
            puts 'api timeout waiting 10 seconds and retrying'
            sleep 10
            retry
          rescue => e
            puts e
            binding.pry
          end
          sf_file # => 'sfid0001111222334'
        end
      end
    end
  end
end
