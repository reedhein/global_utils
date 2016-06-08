path = File.dirname(File.absolute_path(__FILE__) )
require path + '/sales_force/base'
Dir.glob(path + '/sales_force/*').delete_if{|file| File.directory?(file) }.each{|file| require file}
module GlobalUtilities
  module SalesForce
  end
end
