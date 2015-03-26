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
    @status = true
    ### Fitzbox data
    @@sid = Nokogiri::XML(open("http://fritz.box/login_sid.lua")).at_xpath('//SID/text()').to_s
    @name = open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=getswitchname").read
    @config = YAML.load(File.open("#{File.expand_path File.dirname(__FILE__)}/config/default.yml"))
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
    @logger.info("enable Switch: #{@name}")
    open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=setswitchon")
    @status = true
  end

  def switch_on_by_time
    if Time.now > @on_time and Time.now < @off_time
      @logger.info("enable Switch: #{@name}")
      open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=setswitchon")
      @status = true
    end
  end

  def switch_off
    @logger.info("disable Switch: #{@name}")
    open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=setswitchoff")
    @status = false
  end

  def switch_off_by_time
    if Time.now > @off_time
      @logger.info("disable Switch: #{@name}")
      open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=setswitchoff")
      @status = false
    end
  end
end
