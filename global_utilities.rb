require 'json'
module GlobalUtilities
  @@id_mapping = JSON.parse(File.open(File.join(File.dirname(__FILE__), 'id_json.json')).read)
  module  DB
    require_relative '../db_share/db'
  end
  module Gmail
    require_relative '../gmail_tool/gmail_tool'
  end
  module Creds
    require_relative '../cred_service/cred_service'
  end
  def self.id_mapping
    @@id_mapping
  end
end
