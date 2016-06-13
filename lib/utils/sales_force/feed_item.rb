module Utils
  module SalesForce
    class FeedItem < Utils::SalesForce::Base
      attr_accessor :created_date, :id, :body, :parent_id, :type, :url, :title, :feed_type, :created_by_id
      def get_parent
        @client.custom_query(query: "select id from #{Utils.class_from_id(@parent_id)} where id = #{@parent_id}")
      rescue
        nil
      end

      def self.create_from_zoho_note( note, sf )
        user = Utils::SalesForce::User.record_from_full_name(note.created_by).first
        binding.pry if sf.type == "Case"
        data = {
          CreatedDate: Utils::SalesForce.format_time_to_soql(note.created_time),
          Title: note.title,
          Body: migration_note_body(note),
          ParentId: sf.id,
          CreatedBy: user.id
        }
        data.delete(:CreatedBy) if user.nil? || true
        sf.client.create('FeedItem', data)
      end

      private

      def map_attributes(params) #override baseclass
        params.each do |key, value|
          next if key == "attributes"
          if key == "Type"
            self.send('feed_type=', value)
          else
            self.send("#{key.underscore}=", value)
          end
        end
        params.fetch('attributes').each do |key, value|
          self.send("#{key.underscore}=", value)
        end
      end

      def self.migration_note_body(note)
        _content = note.note_content 
        _content << ' ::FROM ZOHO::' << " AUTHORED BY (#{note.created_by})"
      end
    end
  end
end
