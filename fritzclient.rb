require 'rubygems'
require 'bundler/setup'
require 'patron'
require 'faraday'
require 'nokogiri'
require 'open-uri'
require 'nori'
require 'digest/md5'
require 'iconv'

class FritzClient

  def initialize(hostname, password, verbose=false)
    @sid = nil
    @hostname = hostname
    @password = password
    @uri = {
        :settings => "/cgi-bin/webcm?getpage=../html/de/menus/menu2.html",
        :login => "/login.lua",
        :login_sid => "/login_sid.lua",
        :home => "/home/home.lua",
        :webcm => "/cgi-bin/webcm",
        :system_status => "/cgi-bin/system_status"
    }
    @parser = Nori.new(:parser => :nokogiri)
    @conn = Faraday.new(:url => "http://#{@hostname}") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger if verbose
      faraday.adapter :patron do |session|
        session.handle_cookies
      end
    end
    @sid = login
  end

  def login
    response = @conn.post do |req|
      req.url @uri[:login]
      req.body = { "response" => self.build_response }
    end

    if response.headers.include?("Location")
      @sid = URI.parse(response.headers["Location"]).query.gsub('sid=','')
    end
    return @sid
  end

  def system_status
    status = @parser.parse(Nokogiri::XML(open("http://#{@hostname}#{@uri[:system_status]}")).to_s)
    return status["html"]["body"]
  end

  def enable_fritz_dect(ain)
    open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@sid}&ain=#{ain}&switchcmd=setswitchon")
  end

  def disable_fritz_dect(ain)
    open("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@sid}&ain=#{ain}&switchcmd=setswitchoff")
  end

  def wlan_device_active?(device)
    page_content = Net::HTTP.get(URI.parse("http://fritz.box/wlan/wlan_settings.lua"))
    if page_content.include? "wlan','1','1','#{device}','1','0','auto'"
      return true
    else
      return false
    end
  end

  def get_switch_list
    return Net::HTTP.get(URI.parse("http://fritz.box/webservices/homeautoswitch.lua?sid=#{@sid}&switchcmd=getswitchlist"))
  end

  protected
    def session_info
      @parser.parse(Nokogiri::XML(open("http://#{@hostname}#{@uri[:login_sid]}")).to_s)
    end

    def fritz_response(challenge)
      @md5magic = Digest::MD5.hexdigest(Iconv.conv('UTF-16LE', 'UTF-8', "#{challenge}-#{@password}"))
      @response = "#{challenge}-#{@md5magic}"
    end

    def build_response
      fritz_response(session_info["SessionInfo"]["Challenge"])
    end
end