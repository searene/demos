require File.join(File.dirname(__FILE__), "spec_helper")

describe "Validation::Errors" do
  setup do
    @errors = Validation::Errors.new
    class Validation::Errors
      attr_accessor :errors
    end
  end
  
  specify "should be clearable using #clear" do
    @errors.errors = {1 => 2, 3 => 4}
    @errors.clear
    @errors.errors.should == {}
  end
  
  specify "should be empty if no errors are added" do
    @errors.should be_empty
    @errors[:blah] << "blah"
    @errors.should_not be_empty
  end
  
  specify "should return errors for a specific attribute using #on or #[]" do
    @errors[:blah].should == []
    @errors.on(:blah).should == []

    @errors[:blah] << 'blah'
    @errors[:blah].should == ['blah']
    @errors.on(:blah).should == ['blah']

    @errors[:bleu].should == []
    @errors.on(:bleu).should == []
  end
  
  specify "should accept errors using #[] << or #add" do
    @errors[:blah] << 'blah'
    @errors[:blah].should == ['blah']
    
    @errors.add :blah, 'zzzz'
    @errors[:blah].should == ['blah', 'zzzz']
  end
  
  specify "should return full messages using #full_messages" do
    @errors.full_messages.should == []
    
    @errors[:blow] << 'blieuh'
    @errors[:blow] << 'blich'
    @errors[:blay] << 'bliu'
    msgs = @errors.full_messages
    msgs.size.should == 3
    msgs.should include('blow blieuh', 'blow blich', 'blay bliu')
  end
  
  specify "should be enumerable" do
    @errors[:blow] << 'blieuh'
    @errors[:blow] << 'blich'
    @errors[:blay] << 'bliu'
    @errors.size.should == 2
    self.should_receive(:hello).exactly(2)
    @errors.each {|e| self.hello}    
  end
  
end

describe Validation do
  setup do
    @c = Class.new do
      include Validation
      
      def self.validates_coolness_of(attr)
        validates_each(attr) {|o, a, v| o.errors[a] << 'is not cool' if v != :cool}
      end
    end
    
    @d = Class.new do
      attr_accessor :errors
      def initialize; @errors = Validation::Errors.new; end
    end
  end
  
  specify "should respond to validates, validations, has_validations?" do
    @c.should respond_to(:validations)
    @c.should respond_to(:has_validations?)
  end
  
  specify "should acccept validation definitions using validates_each" do
    @c.validates_each(:xx, :yy) {|o, a, v| o.errors[a] << 'too low' if v < 50}
    
    @c.validations[:xx].size.should == 1
    @c.validations[:yy].size.should == 1
    
    o = @d.new
    @c.validations[:xx].first.call(o, :aa, 40)
    @c.validations[:yy].first.call(o, :bb, 60)
    
    o.errors.full_messages.should == ['aa too low']
  end

  specify "should return true/false for has_validations?" do
    @c.has_validations?.should == false
    @c.validates_each(:xx) {1}
    @c.has_validations?.should == true
  end
  
  specify "should provide a validates method that takes block with validation definitions" do
    @c.validates do
      coolness_of :blah
    end
    @c.validations[:blah].should_not be_empty

    o = @d.new
    @c.validations[:blah].first.call(o, :ttt, 40)
    o.errors.full_messages.should == ['ttt is not cool']
    o.errors.clear
    @c.validations[:blah].first.call(o, :ttt, :cool)
    o.errors.should be_empty
  end
end

describe "A Validation instance" do
  setup do
    @c = Class.new do
      attr_accessor :score
      
      include Validation
      
      validates_each :score do |o, a, v|
        o.errors[a] << 'too low' if v < 87
      end
    end
    
    @o = @c.new
  end
  
  specify "should supply a #valid? method that returns true if validations pass" do
    @o.score = 50
    @o.should_not be_valid
    @o.score = 100
    @o.should be_valid
  end
  
  specify "should provide an errors object" do
    @o.score = 100
    @o.should be_valid
    @o.errors.should be_empty
    
    @o.score = 86
    @o.should_not be_valid
    @o.errors[:score].should == ['too low']
    @o.errors[:blah].should be_empty
  end
end

describe Validation::Generator do
  setup do
    $testit = nil
    
    @c = Class.new do
      include Validation
      
      def self.validates_blah
        $testit = 1324
      end
    end
  end
  
  specify "should instance_eval the block, sending everything to its receiver" do
    Validation::Generator.new(@c) do
      blah
    end
    $testit.should == 1324
  end
end

describe "Validations" do
  setup do
    @c = Class.new do
      attr_accessor :value
      include Validation
    end
    @m = @c.new
  end

  specify "should validate acceptance_of" do
    @c.validates_acceptance_of :value
    @m.should be_valid
    @m.value = '1'
    @m.should be_valid
  end
  
  specify "should validate acceptance_of with accept" do
    @c.validates_acceptance_of :value, :accept => 'true'
    @m.value = '1'
    @m.should_not be_valid
    @m.value = 'true'
    @m.should be_valid
  end
  
  specify "should validate acceptance_of with allow_nil => false" do
    @c.validates_acceptance_of :value, :allow_nil => false
    @m.should_not be_valid
  end

  specify "should not validate acceptance_of with if => false" do
    @c.validates_acceptance_of :value, :allow_nil => false, :if => lambda {|m| false}
    @m.should be_valid
  end

  specify "should validate confirmation_of" do
    @c.send(:attr_accessor, :value_confirmation)
    @c.validates_confirmation_of :value
    
    @m.value = 'blah'
    @m.should_not be_valid
    
    @m.value_confirmation = 'blah'
    @m.should be_valid
  end

  specify "should not validate confirmation_of :if => false" do
    @c.send(:attr_accessor, :value_confirmation)
    @c.validates_confirmation_of :value, :if => lambda {|m| false}
    
    @m.value = 'blah'
    @m.should be_valid
  end

  specify "should validate format_of" do
    @c.validates_format_of :value, :with => /.+_.+/
    @m.value = 'abc_'
    @m.should_not be_valid
    @m.value = 'abc_def'
    @m.should be_valid
  end
  
  specify "should not validate format_of :if => false" do
    @c.validates_format_of :value, :with => /.+_.+/, :if => lambda {|m| false}
    @m.value = 'abc_'
    @m.should be_valid
  end
  
  specify "should raise for validate_format_of without regexp" do
    proc {@c.validates_format_of :value}.should raise_error(ArgumentError)
    proc {@c.validates_format_of :value, :with => :blah}.should raise_error(ArgumentError)
  end
  
  specify "should validate length_of with maximum" do
    @c.validates_length_of :value, :maximum => 5
    @m.should_not be_valid
    @m.value = '12345'
    @m.should be_valid
    @m.value = '123456'
    @m.should_not be_valid
  end

  specify "should validate length_of with minimum" do
    @c.validates_length_of :value, :minimum => 5
    @m.should_not be_valid
    @m.value = '12345'
    @m.should be_valid
    @m.value = '1234'
    @m.should_not be_valid
  end

  specify "should validate length_of with within" do
    @c.validates_length_of :value, :within => 2..5
    @m.should_not be_valid
    @m.value = '12345'
    @m.should be_valid
    @m.value = '1'
    @m.should_not be_valid
    @m.value = '123456'
    @m.should_not be_valid
  end

  specify "should not validate length_of :if => false" do
    @c.validates_length_of :value, :within => 2..5, :if => Proc.new {|m| m.value != nil}
    @m.should be_valid
  end

  specify "should validate length_of with is" do
    @c.validates_length_of :value, :is => 3
    @m.should_not be_valid
    @m.value = '123'
    @m.should be_valid
    @m.value = '12'
    @m.should_not be_valid
    @m.value = '1234'
    @m.should_not be_valid
  end
  
  specify "should validate length_of with allow_nil" do
    @c.validates_length_of :value, :is => 3, :allow_nil => true
    @m.should be_valid
  end

  specify "should validate numericality_of" do
    @c.validates_numericality_of :value
    @m.value = 'blah'
    @m.should_not be_valid
    @m.value = '123'
    @m.should be_valid
    @m.value = '123.1231'
    @m.should be_valid
  end

  specify "should not validate numericality_of :if => false" do
    @c.validates_numericality_of :value, :if => lambda {|m| m.value != 'blah'}
    @m.value = 'blah'
    @m.should be_valid
  end

  specify "should validate numericality_of with only_integer" do
    @c.validates_numericality_of :value, :only_integer => true
    @m.value = 'blah'
    @m.should_not be_valid
    @m.value = '123'
    @m.should be_valid
    @m.value = '123.1231'
    @m.should_not be_valid
  end
  
  specify "should validate presence_of" do
    @c.validates_presence_of :value
    @m.should_not be_valid
    @m.value = ''
    @m.should_not be_valid
    @m.value = 1234
    @m.should be_valid
  end

  specify "should not validate presence_of :if => false" do
    @c.validates_presence_of :value, :if => Proc.new {|s| false}
    @m.should be_valid
  end
  
  specify "should validate presence of :if => true" do
    @c.validates_presence_of :value, :if => Proc.new {|s| true}
    @m.should_not be_valid
  end
end

context "Superclass validations" do
  setup do
    @c1 = Class.new do
      include Validation
      attr_accessor :value
      validates_length_of :value, :minimum => 5
    end
    
    @c2 = Class.new(@c1) do
      validates_format_of :value, :with => /^[a-z]+$/
    end
  end
  
  specify "should be checked when validating" do
    o = @c2.new
    o.value = 'ab'
    o.valid?.should == false
    o.errors.full_messages.should == [
      'value is too short'
    ]

    o.value = '12'
    o.valid?.should == false
    o.errors.full_messages.should == [
      'value is too short',
      'value is invalid'
    ]

    o.value = 'abcde'
    o.valid?.should be_true
  end
  
  specify "should be skipped if skip_superclass_validations is called" do
    @c2.skip_superclass_validations

    o = @c2.new
    o.value = 'ab'
    o.valid?.should be_true

    o.value = '12'
    o.valid?.should == false
    o.errors.full_messages.should == [
      'value is invalid'
    ]

    o.value = 'abcde'
    o.valid?.should be_true
  end
end

context ".validates with block" do
  specify "should support calling .each" do
    @c = Class.new do
      attr_accessor :vvv
      
      include Validation
      validates do
        each :vvv do |o, a, v|
          o.errors[a] << "is less than zero" if v.to_i < 0
        end
      end
    end
    
    o = @c.new
    o.vvv = 1
    o.should be_valid
    o.vvv = -1
    o.should_not be_valid
  end
end