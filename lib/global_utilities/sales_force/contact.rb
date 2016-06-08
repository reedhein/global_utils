module GlobalUtilities
  module SalesForce
    class Contact < GlobalUtilities::SalesForce::Base
      attr_accessor :id, :zoho_id__c, :last_modified_by, :email, :name,  :record_type,  :type, :url,
        :api_object, :migration_complete, :attachment_names, :modified, :created_date

      def cases
        @client.custom_query(
          query: "select id, createddate, zoho_id__c from case where contactid = '#{id}'"
        )
      end
    end

  end
end
