require 'watir'
class BrowserTool
  attr_accessor :worker_pool, :agents, :instance_url
  def initialize(number_of_browsers = 4)
    Utils.environment = :production
    @sf_login      = CredService.creds.salesforce.public_send(Utils.environment).host
    @sf_username   = CredService.creds.user.salesforce.public_send(Utils.environment).username
    @sf_password   = CredService.creds.user.salesforce.public_send(Utils.environment).password
    @instance_url  = CredService.creds.salesforce.public_send(Utils.environment).instance_url
    @agents        = []
    @worker_pool = @wp = WorkerPool.instance
    number_of_browsers.times do |i|
      self.instance_variable_set("@agent#{i}".to_sym, Watir::Browser.new(:firefox))
      agent = self.instance_variable_get("@agent#{i}".to_sym)
      @agents << agent
      agent.driver.manage.timeouts.implicit_wait = 30
      agent.driver.manage.timeouts.page_load = 30
      @screen_width  ||= agent.execute_script('return screen.width;')
      @screen_height ||= agent.execute_script('return screen.height;')
      setup_in_quadrant(agent, i)
      Thread.new{ log_in_to_salesforce(agent) }
    end
  end

  def close
    instance_variables.select{|v| v =~ /agent\d+/}.each{|agent| self.instance_variable_get(agent).close}
  end

  def queue_work(&block)
    agent = free_agent
    yield agent
    agent.unlock
  end

  def create_folder(opportunity)
    queue_work do |agent|
      begin
        agent.goto opportunity_url(opportunity)
        agent.span(class: 'title', text: 'Details').when_present.click
        Watir::Wait.until{ agent.iframe(id: 'vfFrameId').wait_until_present(timeout = 30) }
        box_iframe = agent.iframe(id: 'vfFrameId').when_present.iframe(id: /j_id\d+/)
        box_iframe.input(type: 'submit', value: 'Create Folder').when_present.click
        sleep 4
        box_iframe.div(id: 'error-page').exists?
      rescue => e
        ap e.backtrace
        binding.pry
      end
    end
  end

  def free_agent
    @agents.cycle do |agent|
      return agent if agent.lock
      sleep 0.5
    end
  end

  private

  def opportunity_url(opp)
    [@instance_url, opp.id].join('/')
  end

  def log_in_to_salesforce(agent)
    agent.goto(@sf_login)
    agent.text_field(id: 'username').when_present.set @sf_username
    agent.text_field(id: 'password').set @sf_password
    agent.button(name: 'Login').click
    Watir::Wait.until { agent.body(class: 'desktop').wait_until_present }
  end

  def setup_in_quadrant(agent, quadrant)
    agent.window.resize_to(@screen_width/2, @screen_height/2)
    case quadrant
    when 0
      agent.window.move_to(0, 0)
    when 1
      agent.window.move_to(@screen_width/2, 0)
    when 2
      agent.window.move_to(0, @screen_height/2)
    when 3
      agent.window.move_to(@screen_width/2, @screen_height/2)
    end
    @screen_width
  end


end

class Watir::Browser
  attr_accessor :lock
  def lock
    if @lock == false || nil
      @lock = true
    else
      @lock = false
    end
  end

  def unlock
    @lock = false
  end
end
