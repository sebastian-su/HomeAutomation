require 'listen'
require 'yaml'

require_relative 'house.rb'

class HomeAutomation
  @current_dir = File.expand_path File.dirname(__FILE__)
  @config = YAML.load(File.open("#{@current_dir}/config/default.yml"))
  @house = House.new(@config['ain'])
  @folder = @config['path']
  @activity = false

  #Thread.new {
  #  listener = Listen.to(@folder) do
  #    @activity=true
  #  end
  #  listener.start
  #  sleep
  #}

  while true do
    if @activity==true
      @house.switch_all_on_at_night
      @activity=false
      sleep 120
    else
      @house.switch_all_off
      sleep 1
    end
  end
end
