require 'spec_helper'

describe Switch do
  before :each do
    @switch = Switch.new(123)
    end
    
    describe "#initial settings" do
      it "switch should default to true" do
        expect(@switch.status).to eq true
      end
    end

    describe "#switch_on" do
      it "switches on sets status to true" do
        @switch.switch_off
        @switch.switch_on
        expect(@switch.status).to eq true
      end
    end
    
    describe "#switch_off" do
      it "switches off sets status to false" do
        @switch.switch_off
        expect(@switch.status).to eq false
      end
    end
end