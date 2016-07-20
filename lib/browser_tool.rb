require 'watir'

class BrowserTool
  attr_accessor :worker_pool, :agents
  def initialize(number_of_browsers = 4)
    Utils.environment = :production
    @sf_login      = CredService.creds.salesforce.public_send(Utils.environment).host
    @sf_username   = CredService.creds.user.salesforce.public_send(Utils.environment).username
    @sf_password   = CredService.creds.user.salesforce.public_send(Utils.environment).password
    @agents = []
    @worker_pool = @wp = WorkerPool.instance
    number_of_browsers.times do |i|
      self.instance_variable_set("@agent#{i}".to_sym, Watir::Browser.new(:chrome))
      agent = self.instance_variable_get("@agent#{i}".to_sym)
      @agents << agent
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
      agent.goto opporutnity_url(opportunity.id)
      agent.span(class: 'title', text: 'Details').wait_until_present.click
      Watir::Wait.until{ agent.frame(id: 'vfFrameId').wait_until_present }
      box_iframe = agent.frame(id: 'vfFrameId').wait_until_present.frame(id: /j_id\d+/)
      binding.pry
      box_iframe.input(type: 'submit', value: 'Create Folder')
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
