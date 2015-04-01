require 'open-uri'
require 'nokogiri'
require 'logger'
require 'yaml'
require 'time'
require 'sun_times'

class Switch

  attr_reader :status, :nigthly

  def initialize(id)
    @id = id

    ### Fitzbox data
    @@sid = Nokogiri::XML(open("http://fritz.box/login_sid.lua")).at_xpath('//SID/text()').to_s
    @name = open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=getswitchname").read
    @status = self.get_status
    @config = YAML.load_file("config/default.yml")
    @on_time = Time.parse(@config['switches']["#{@id}"]['on_time'])
    @off_time = Time.parse(@config['switches']["#{@id}"]['off_time'])
    @nightly = @config['switches']["#{@id}"]['nightly']

    ### Suntimes
    @sun_times = SunTimes.new
    @latitude = 52.633056
    @longitude = 13.55
    @sunrise = @sun_times.rise(Date.today, @latitude, @longitude).localtime
    @sunset =  @sun_times.set(Date.today, @latitude, @longitude).localtime

    if @nightly == true
      @on_time = @sunset
    end
    
    ### Log
    @logger = Logger.new(@config['log_path'])
    @logger.level = Logger::INFO
  end
  
  def switch_on
    if @status == false
      @logger.info("enable Switch: #{@name}")
      #open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=setswitchon")
      @status = true
    end
  end

  def switch_on_by_time
    if Time.now > @on_time and Time.now < @off_time
      self.switch_on
    end
  end

  def switch_off
    if @status == true
      @logger.info("disable Switch: #{@name}")
      #open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=setswitchoff")
      @status = false
    end
  end

  def switch_off_by_time
    if Time.now > @off_time
      self.switch_off
    end
  end

  protected

  def get_status
    if open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=getswitchstate").read.strip == "1"
      return true
    else
      return false
    end
  end
end
