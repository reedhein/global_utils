require 'restforce'
require 'active_support/all'
module Utils
  module SalesForce
    class Client
      include Inspector
      include Singleton
      attr_reader :client

      def initialize(user = DB::User.first)
        @client = self.class.client(user)
        dynanmic_methods_for_client
      end

      def custom_query(query: nil, &block)
        fail ArgumentError if query.nil?
        tries ||= 0
        result = @client.query(query)
        return [] if result.count < 1
        object_type = result.first.dig('attributes', 'type')
        klass = ['Utils', 'SalesForce', object_type.camelize].join('::').classify.constantize
        result.entries.map do |entity|
          if block_given?
            yield klass.new(entity)
          else
            klass.new(entity)
          end
        end
      end

      def self.custom_query(query: nil, &block)
        self.instance.custom_query(query: query, &block)
      end

      def self.client(user = DB::User.first)
        Restforce.log = false
        Restforce.configure do |c|
          c.log_level = :info
        end
        update_user_tokens = lambda do |reply|
            user.salesforce_auth_token = reply.fetch('access_token')
            user.save
            puts "Salesforce Token updated: #{Time.now.to_s}"
          end

        Restforce.new oauth_token: user.salesforce_auth_token,
          refresh_token: user.salesforce_refresh_token,
          instance_url: CredService.creds.salesforce.instance_url,
          client_id:  CredService.creds.salesforce.api_key,
          client_secret:  CredService.creds.salesforce.api_secret,
          api_version:  CredService.creds.salesforce.api_version,
          authentication_callback: update_user_tokens
      end

      def for_date(date)
        requested_time   = Time.parse(date)
        beginning_of_day = requested_time.beginning_of_day
        end_of_day       = requested_time.end_of_day
        offices       = @client.query("select id from account where recordtype.name = 'Office Location'")
        opportunities = @client.query("select id from opportunity where createddate > #{format_time_to_soql(beginning_of_day) } and createddate < #{format_time_to_soql(end_of_day)}")
        leads         = @client.query("select id from lead where createddate > #{format_time_to_soql(beginning_of_day) } and createddate < #{format_time_to_soql(end_of_day)}")
        [offices, opportunities, leads]
      end


      private

      def dynanmic_methods_for_client
        methods = @client.public_methods - self.public_methods
        methods.each do |meth|
          define_singleton_method meth do |*args|
            @client.send(meth, *args)
          end
        end
      end

    end
  end
end
