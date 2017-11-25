require File.join(File.dirname(__FILE__), 'spec_helper.rb')

describe Dvi::LsR do
  it "can find cmr10.tfm." do
    File.basename(Dvi::LsR.default.find("cmr10.tfm")).should == "cmr10.tfm"
  end

  it "cmr10.tfm should exist." do
    File.exist?(Dvi::LsR.default.find("cmb10.tfm")).should be_true
  end
end
