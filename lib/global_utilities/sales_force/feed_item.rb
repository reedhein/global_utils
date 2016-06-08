module GlobalUtilities
  module SalesForce
    class FeedItem < GlobalUtilities::SalesForce::Base
      attr_accessor :created_date, :id, :body, :parent_id, :type, :url, :title
      def get_parent
        @client.custom_query(query: "select zoho_id__c from #{GlobalUtilities.class_from_id(@id)}")
      end
    end
  end
end
