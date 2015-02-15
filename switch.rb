require 'open-uri'
require 'nokogiri'

class Switch

  attr_reader :status

  def initialize(id)
    @id = id
    @status = true
    @@sid = Nokogiri::XML(open("http://fritz.box/login_sid.lua")).at_xpath('//SID/text()').to_s
  end

  def switch_on
    if @status == false
      puts "#{Time.now} - enable Switch: #{@id}"
      open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=setswitchon")
      @status = true
    end
  end

  def switch_off
    if @status == true
      puts "#{Time.now} - disable Switch: #{@id}"
      open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@@sid}&ain=#{@id}&switchcmd=setswitchoff")
      @status = false
    end
  end
end