require 'open-uri'
require_relative 'fritzclient.rb'

class Switch

  def initialize(id)
    @id = id
    @status = true
    @hostname = "fritz.box"
    @passwort = ""
    @client = FritzClient.new(@hostname, @passwort, false)
  end

  def switch_on
    if @status == false
      puts "#{Time.now} - enable Switch: #{@id}"
      @client.enable_fritz_dect(@id)
      @status = true
    end
  end

  def switch_off
    if @status == true
      puts "#{Time.now} - disable Switch: #{@id}"
      @client.disable_fritz_dect(@id)
      @status = false
    end
  end
end