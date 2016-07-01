module Utils
  module SalesForce
    class Determine
      attr_accessor :potentials, :contacts, :leads, :accounts, :email, :name, :phone, :sf_client, :sf_object
      def initialize(sf)
        @sf_object = sf
        @sf_client = sf.client
        @potentials, @contacts, @leads, @accounts = [], [], [], []
        @email, @name, @phone  = get_meta
        find_zoho(sf)
        self
      end

      def detect_zoho
        %w[potential contact lead account].detect do |zoho_object|
          zoho_object_fields(zoho_object).detect do |method_name| # i removed compact
            zoho_api_lookup = ['RubyZoho' , 'Crm', zoho_object.camelize].join('::').constantize.send("find_by_#{method_name.to_s}", self.send(method_name))
            populate_results(zoho_api_lookup)
          end
        end
      end

      def find_zoho(sf)
        corresponding_objects = fetch_zoho_objects(sf)
        return_value = corresponding_objects.flatten.compact.map do |zoho|
          begin
            module_name = zoho.module_name.singularize
            ['Utils', 'Zoho' , module_name].join('::').constantize.new(zoho)
          rescue => e
            puts e
            binding.pry
          end
        end.compact
        return_value
      end

      private

      def fetch_zoho_objects(sf)
        %w[contact potential lead account].map do |zoho_object|
          puts "checking against zoho object: #{zoho_object}"
          begin
            zoho_object_fields(zoho_object).compact.map do |method_name|
              zoho_api_lookup = ['RubyZoho' , 'Crm', zoho_object.camelize].join('::').constantize.send("find_by_#{method_name.to_s}", self.send(method_name))
              populate_results(zoho_api_lookup)
            end
          rescue Net::OpenTimeout
            puts "network timeout sleeping 5 seconds then trying again"
            sleep 5
            retry
          end
        end
      end

      def get_meta
        case @sf_object.type
        when 'Contact'
          return_value = @sf_client.query("SELECT email, name, phone FROM contact WHERE id = '#{@sf_object.id}'")
        when 'Opportunity'
          return_value = @sf_client.query("SELECT email, name, phone FROM contact WHERE accountid IN (SELECT accountid FROM Opportunity WHERE id = '#{@sf_object.id}')")
        when 'Account'
          return_value = @sf_client.query("SELECT email, name, phone FROM contact WHERE accountid = '#{@sf_object.id}'")
        when 'Case'
          return_value = @sf_client.query("select email, name, phone from contact  where id in (select contactid from case where id = '#{@sf_object.id}')")
        end
        first_entry  = return_value.first || {}
        [first_entry.fetch('Email', nil), first_entry.fetch('Name', nil), first_entry.fetch('Phone', nil)]
      end

      def populate_results(zoho_api_lookup)
        if zoho_api_lookup
          zoho_api_lookup.each do |zoho|
            global_zoho = ['Utils', 'Zoho', zoho.module_name.singularize].join('::').constantize.new(zoho)
            self.send(zoho.module_name.downcase) << global_zoho
          end
        end
      end

      def zoho_object_fields(zoho_object)
        #return values that we can query against
        ['RubyZoho','Crm', zoho_object.camelize].join('::').constantize.new.fields & [:email, :phone, :name]
      end
    end
  end
end
