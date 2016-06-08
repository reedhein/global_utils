module GlobalUtilities
  module SalesForce
    class Base
      require_relative './concern'
      include GlobalUtilities::SalesForce::Concern::DB #feels weird that this is required
      include GlobalUtilities::SalesForce::Concern::Zoho
      attr_reader :client, :zoho
      def initialize(api_object)
        @client             = GlobalUtilities::SalesForce::Client.new
        @api_object         = api_object
        @storage_object     = convert_api_object_to_local_storage(api_object)
        @problems           = []
        map_attributes(api_object)
        self
      end

      def map_attributes(params)
        params.each do |key, value|
          next if key == "attributes"
          next if key.downcase == "body" #prevent attachment from being downloaded if we haven't checked fro presence
          self.send("#{key.underscore}=", value)
        end
        params.fetch('attributes').each do |key, value|
          self.send("#{key.underscore}=", value)
        end
      end

      def attachments
        @attachments ||= GlobalUtilities::SalesForce::Client.instance.query("SELECT Id, Name FROM Attachment WHERE ParentId = '#{id}'")
      end
    end

  end
end
