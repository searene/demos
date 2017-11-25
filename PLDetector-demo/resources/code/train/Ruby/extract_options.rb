require File.join(File.dirname(__FILE__), 'spec_helper')

describe Array, "#extract_options!" do
  specify "should return an empty hash for an empty array" do
    [].extract_options!.should == {}
  end
  
  specify "should remove the last member and return it only if it's a hash" do
    a = [1, 2, 3]
    a.extract_options!.should == {}
    a.should == [1, 2, 3]

    a = [1, {1 => 2}, 3]
    a.extract_options!.should == {}
    a.should == [1, {1 => 2}, 3]

    a = [1, {1 => 2}]
    a.extract_options!.should == {1 => 2}
    a.should == [1]

    a = [{1 => 2}]
    a.extract_options!.should == {1 => 2}
    a.should == []
  end
end