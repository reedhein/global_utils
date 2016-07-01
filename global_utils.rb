require 'json'
module Utils
  @@id_mapping = JSON.parse(File.open(File.join(File.dirname(__FILE__), 'id_json.json')).read)

  class << self
    attr_accessor :environment
  end

  module Creds
    require_relative '../cred_service/cred_service'
  end

  require_relative '../db_share/db'

  module All
    require_relative './lib/utils'
  end

  module Gmail
    require_relative '../gmail_tool/gmail_tool'
  end

  # module SalesForce
  #   require_relative './lib/global_utilities/sales_force'
  # end
  #
  # module Zoho
  #   require_relative './lib/global_utilities/zoho'
  # end

  def self.id_mapping
    @@id_mapping
  end

  def self.class_from_id(id)
    key = id.slice(0,3)
    id_mapping.fetch(key, 'Generic')
  end
end