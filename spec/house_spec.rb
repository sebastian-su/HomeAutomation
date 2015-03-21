require 'spec_helper'

describe House do
  before :each do
    @house = House.new
    end

    describe "#initial settings" do
      it "should have 2 switches" do
        expect(@house.switches.length).to eq 2
      end
    end

    describe "#switch_all_on" do
      it "returns true for switched on switches" do
        @house.switch_all_on
        expect(@house.switches[0].status).to eq true
        expect(@house.switches[1].status).to eq true
      end
    end

    describe "#switch_all_off" do
      it "returns false for switched off switches" do
        @house.switch_all_off
        expect(@house.switches[0].status).to eq false
        expect(@house.switches[1].status).to eq false
      end
    end

    describe "#switch_all_on_at_night" do
      it "switches all on if its night" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,22,0,0)
        Time.stub(:now).and_return(@time_now)
        @house.switch_all_off
        @house.switch_all_on_at_night
        expect(@house.switches[0].status).to eq true
        expect(@house.switches[1].status).to eq true
      end

      it "does not switch if its daytime" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,12,0,0)
        Time.stub(:now).and_return(@time_now)
        @house.switch_all_off
        expect(@house.switches[0].status).to eq false
        @house.switch_all_on_at_night
        expect(@house.switches[0].status).to eq false
      end
    end

    describe "#global_turn_off" do
      it "switches all of if global turn off time is reached" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,23,0,0)
        Time.stub(:now).and_return(@time_now)
        @house.global_turn_off
        expect(@house.switches[0].status).to eq false
        expect(@house.switches[1].status).to eq false
      end
    end

    describe "#switch_outdoor_lights_on" do
      it "switches on if global turn off time is not reached" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,21,0,0)
        Time.stub(:now).and_return(@time_now)
        @house.switch_all_off
        @house.switch_outdoor_lights_on
        expect(@house.switches[0].status).to eq true
        expect(@house.switches[1].status).to eq true
      end

      it "does not switch on if global turn off time is reached" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,23,0,0)
        Time.stub(:now).and_return(@time_now)
        @house.switch_all_off
        @house.switch_outdoor_lights_on
        expect(@house.switches[0].status).to eq false
        expect(@house.switches[1].status).to eq false
      end
    end

    describe "#daytime?" do
      it "should return false during night" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,22,0,0)
        Time.stub(:now).and_return(@time_now)
        expect(@house.daytime?).to eq false
      end

      it "should return true at daytime" do
        @time_now = Time.new(Date.today.year,Date.today.month,Date.today.day,12,0,0)
        Time.stub(:now).and_return(@time_now)
        expect(@house.daytime?).to eq true
      end
    end
end
