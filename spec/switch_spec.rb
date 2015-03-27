require 'spec_helper'

describe Switch do
  before :each do
    config = {"log_path"=>"ha.log",
              "path"=>"test/",
              "switches"=>{"123"=>{"on_time"=>"16:00", "off_time"=>"22:00", "nightly"=>false},
                            "456"=>{"on_time"=>"18:00", "off_time"=>"23:55", "nightly"=>true}}}
    YAML.stub(:load_file).and_return(config)
    @switch = Switch.new(123)
    end
    
    describe "#initial settings" do
      it "switch should default to true" do
        expect(@switch.status).to eq true
      end
    end

    describe "#switch_on" do
      it "switches on sets status to true" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,12,0,0)
        Time.stub(:now).and_return(@time_now)
        @switch.switch_off_by_time
        @switch.switch_on
        expect(@switch.status).to eq true
      end
    end

    describe "#switch_on" do
      it "switches should no switch on" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,23,0,0)
        Time.stub(:now).and_return(@time_now)
        @switch.switch_off
        @switch.switch_on_by_time
        expect(@switch.status).to eq false
      end
    end

    describe "#switch_off" do
      it "does not switche off" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,12,0,0)
        Time.stub(:now).and_return(@time_now)
        @switch.switch_off_by_time
        expect(@switch.status).to eq true
      end
    end

    describe "#switch_off" do
      it "switches off sets and status to false" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,23,55,0)
        Time.stub(:now).and_return(@time_now)
        @switch.switch_off
        expect(@switch.status).to eq false
      end
    end
end
