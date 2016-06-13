module Utils
  module SalesForce
    class Case < Utils::SalesForce::Base
      attr_accessor :id, :zoho_id__c, :last_modified_by, :email, :name,  :record_type,
        :type, :url, :api_object, :migration_complete, :attachment_names, :modified,
        :created_date, :closed_date, :contact_id, :created_by_id

      def opportunity
        @opportunity ||= @client.custom_query(
          query: "SELECT id, createddate, closeddate, zoho_id__c, FROM opportunity WHERE id in (select opportunityid from case where id = '#{@id}')"
        ).first
      end
    end
  end
end
