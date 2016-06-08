require 'json'
module GlobalUtilities
  @@id_mapping = JSON.parse(File.open(File.join(File.dirname(__FILE__), 'id_json.json')).read)

  module Creds
    require_relative '../cred_service/cred_service'
  end

  module ZohoSushi
    require_relative '../sushi/lib/zoho_sushi'
  end

  module  DB
    require_relative '../db_share/db'
  end

  module Gmail
    require_relative '../gmail_tool/gmail_tool'
  end

  module SalesForce
    require_relative './global_utilities/sales_force'
  end

  module Zoho
    require_relative './global_utilities/zoho'
  end

  def self.id_mapping
    @@id_mapping
  end

  def self.class_from_id(id)
    key = id.slice(0,3)
    id_mapping.fetch(key, 'Generic')
  end
end
