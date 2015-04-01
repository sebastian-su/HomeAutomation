require 'sun_times'
require 'open-uri'
require 'nokogiri'
require_relative 'switch.rb'

class House

  attr_reader :switches

  def initialize()
    @sid = Nokogiri::XML(open("http://fritz.box/login_sid.lua")).at_xpath('//SID/text()').to_s
    ains = open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@sid}&switchcmd=getswitchlist").read.strip.split(",")
    @switches = []
    ains.each do |ain|
      @switches.push(Switch.new(ain))
    end
    @sun_times = SunTimes.new
    @latitude = 52.633056
    @longitude = 13.55
    @sunrise = @sun_times.rise(Date.today, @latitude, @longitude).localtime
    @sunset =  @sun_times.set(Date.today, @latitude, @longitude).localtime
    @global_turn_off = Time.new(Date.today.year,Date.today.month,Date.today.day,23,0,0)
  end

  def switch_all_on
    @switches.each do |switch|
      switch.switch_on_by_time
    end
  end

  def switch_all_on_at_night
    if !daytime?
      @switches.each do |switch|
        switch.switch_on_by_time
      end
    end
  end

  def switch_all_off
    @switches.each do |switch|
      switch.switch_off_by_time
    end
  end

  def global_turn_off
    if Time.now >= @global_turn_off
      switch_all_off
    end
  end

  def switch_outdoor_lights_on
    if Time.now <= @global_turn_off
      switch_all_on
    end
  end

  def daytime?
    if Time.now > @sunrise and Time.now < @sunset
      return true
    else
      return false
    end
  end
end
