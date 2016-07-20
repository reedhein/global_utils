path = File.dirname(File.absolute_path(__FILE__) )
Dir.glob(path + '/utils/*').delete_if{ |file| File.directory?(file) }.each{ |file| require file }
module Utils
  class << self
    attr_accessor :environment
  end
end
