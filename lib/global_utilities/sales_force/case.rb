module GlobalUtilities
  module SalesForce
    class Case < GlobalUtilities::SalesForce::Base
      attr_accessor :id, :zoho_id__c, :last_modified_by, :email, :name,  :record_type,  :type, :url,
        :api_object, :migration_complete, :attachment_names, :modified, :created_date
    end
  end
end
