module Utils
  module SalesForce
    module Concern
      module Zoho
        def attach(zoho_sushi, file_data)
          if file_already_present?(file_data)
            puts "*" * 88
            puts "WARNING this file was discoverd in SFDC id: #{id}"
            puts "*" * 88
            return
          end
          # description = description_from_file_data(file_data)
          begin
            file = ::Zoho::Base.client.download_file(zoho_sushi.module_name, file_data[:id])
            Utils::SalesForce::Client.instance.client.create('Attachment',
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
          @zoho ||= Utils::Zoho::Base.counterpart(zoho_id__c) || Utils::SalesForce::Determine.new(self)
        end

        private

        def file_already_present?(file_data)
          puts 'testing for presence'
          attachments.entries.map{|attachment| attachment.fetch('Name')}.include? file_data[:file_name]
        end
      end
    end
  end
end
