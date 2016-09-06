module Utils
  module Zoho
    module Concern
      module Notes
        def notes #this isn't being called the dynamic method in Utils::Zoho::Base is
          RubyZoho.configuration.api.related_records(self.module_name, self.id, 'Notes') || []
        end

      end
    end
  end
end
