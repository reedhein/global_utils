require 'boxr'
path = File.dirname(File.absolute_path(__FILE__) )
Dir.glob(path + '/box/*').delete_if{|file| File.directory?(file) }.each{|file| require file}
module Utils
  module Box
  end
end
