module Utils
  module Zoho
    class Base
      require_relative './concern'
      path = File.dirname(File.absolute_path(__FILE__) )
      Dir.glob(path + '/**/*').delete_if{ |file| File.directory?(file) }.reverse.each{|file| require file}
      include Utils::Zoho::Concern::DB
      attr_accessor :saleforce, :api_object, :storage_object, :migration_complete, :module_name, :id
      def initialize(api_object, salesforce_client = nil)
        @api_object         = munge_api(api_object)
        @storage_object     = find_or_create(@api_object)
        @migration_complete = @storage_object.complete
        @salesforce         = salesforce_client
        dyanmic_methods_for_passing_to_api_object
        dynamic_methods_for_related_objects
        self
      end

      def self.counterpart(id)
        return nil unless id
        return nil unless id =~ /^zcrm_/
        corresponding_class = nil
        %w[lead potential contact account].detect do |zoho_object|
          puts "checking against zoho object #{zoho_object}"
          sleep 1
          begin
            corresponding_class = [RubyZoho::Crm, zoho_object.classify].join('::').constantize.find_by_id(zoho_id(id))
          rescue Net::OpenTimeout
            puts "network timeout sleeping 5 seconds then trying again"
            sleep 5
            retry
          end
        end
        return nil if corresponding_class.nil?
        module_name = corresponding_class.first.module_name.singularize
        ['Utils', 'Zoho' , module_name].join('::').constantize.new(corresponding_class.first)
      end

      private

      def munge_api(api_object)
        if api_object.is_a?(Hash) 
          api_object[:fields] = api_object.keys
          DeepStruct.wrap(api_object)
        else
          api_object
        end
      end

      def unsupported_gem_object?(aro)
        ['Notes', 'Attachments'].include? aro.fetch(:module_name)
      end

      def create_gem_zoho_object(aro, klass)
        ['RubyZoho','Crm', klass.singularize].join('::').constantize.new(aro)
      end

      def dynamic_methods_for_related_objects
        %w(Accounts Contacts Quotes Events Leads Potentials Tasks Users Notes Attachments).each do |klass|
          define_singleton_method klass.downcase.to_sym do
            sleep 2.5
            api_return_objects = RubyZoho.configuration.api.related_records(module_name, id, klass)
            return [] unless api_return_objects.present?
            api_return_objects.map do |aro|
              if unsupported_gem_object?(aro)
                api_zoho_object = aro
              else
                api_zoho_object = create_gem_zoho_object(aro, klass)
              end
              ['Utils', 'Zoho', klass.singularize].join('::').constantize.new(api_zoho_object)
            end
          end
        end
      end

      def dyanmic_methods_for_passing_to_api_object
        @api_object.fields.each do |meth|
          define_singleton_method meth do |*args|
            sleep 2.5
            @api_object.send(meth, *args)
          end
        end
      end

    end

  end
end

