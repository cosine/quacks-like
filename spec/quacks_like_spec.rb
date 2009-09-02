$LOAD_PATH.unshift "lib"

require 'quacks_like'


describe QuacksLike do

  def duck_type_process_status (object = nil, *ignore_methods)
    object ||= Object.new
    code = <<-__EOF__
      class << object
        attr_reader :to_i, :pid
        def coredump?; false; end 
        def exited?; true; end 
        def signaled?; false; end 
        def stopped?; false; end 
        def stopsig; nil; end 
        def success?; @to_i.zero?; end 
        def termsig; nil; end 
        def & (other); @to_i & other; end
        def >> (other); @to_i >> other; end
        alias exitstatus to_i
        alias to_int to_i
      end 
      object.instance_variable_set(:@to_i, 0)
      object.instance_variable_set(:@pid, 12345)
    __EOF__

    code = ignore_methods.inject(code.split(/\n/, -1)) do |code, m|
      code.reject { |line| line =~ /\bdef #{m}\b/ }
    end.join("\n")

    eval(code)
    object
  end


  describe 'basic use' do
    it "should say an Array quacks like an Array" do
      Array.new.should quack_like_an(Array)
    end

    it "should say an Array does not quack like a Hash" do
      Array.new.should_not quack_like_a(Hash)
    end

    it "should say a Process::Status quacks like a Process::Status" do
      %x"(exit 0)"
      $?.should quack_like_a(Process::Status)
    end

    it "should say an object duck-typed like a Process::Status quacks like a Process::Status" do
      a = duck_type_process_status
      a.should_not be_an_instance_of(Process::Status)   # proof of !cheating
      a.should quack_like_a(Process::Status)
    end

    it "should find fault if a method is missing from the target" do
      a = duck_type_process_status(nil, :stopsig)
      a.should_not quack_like_a(Process::Status)
    end

    it "should find fault if a method has an incompatible arity" do
      a = duck_type_process_status
      class << a; def stopsig (a); a; end; end
      a.should_not quack_like_a(Process::Status)
    end
  end


  describe '.matches?' do
    it "should return true for an Array matching an Array" do
      quack_like_an(Array).matches?(Array.new).should be_true
    end

    it "should return false for a Hash matching an Array" do
      quack_like_a(Hash).matches?(Array.new).should be_false
    end

    # Other tests omitted given they're effectively covered above.
  end


  describe '.failure_message_for_should' do
    it "should return a String with mis-match data" do
      m = quack_like_a(Hash)
      m.matches?(Array.new)
      m.failure_message_for_should.should =~ /\brespond\b.*\bhas_key?\b/
    end

    it "should return a String with mis-match data on arity problems" do
      a = Array.new
      class << a; def join (a, b, c, d); super(a); end; end
      m = quack_like_a(Array)
      m.matches?(a)
      m.failure_message_for_should.should =~ /\bjoin\b.*\barity\b/
    end
  end


  describe '.failure_message_for_should_not' do
    it "should return a String stating that it expected a mis-match" do
      m = quack_like_a(Array)
      m.matches?(Array.new)
      m.failure_message_for_should_not.should =~ /./    # any text will do
    end
  end


  describe '.arity_compare' do
    RESULTS_CHART = [
      {[0, 0] => true},
      {[0, -1] => true},
      {[0, 1] => false},
      {[0, -2] => false},
      {[1, 1] => true},
      {[1, 2] => false},
      {[1, 0] => false},
      {[1, -1] => true},
      {[1, -2] => true},
      {[1, -3] => false},
      {[2, 2] => true},
      {[2, 3] => false},
      {[2, 1] => false},
      {[2, 0] => false},
      {[2, -1] => true},
      {[2, -2] => true},
      {[2, -3] => true},
      {[2, -4] => false},
      {[-1, -1] => true},
      {[-1, -2] => false},
      {[-1, 0] => false},
      {[-1, 1] => false},
      {[-2, -2] => true},
      {[-2, -1] => true},
      {[-2, 0] => false},
      {[-2, 1] => false},
      {[-2, -3] => false}
    ]

    RESULTS_CHART.each do |result_data|
      result_data.each_pair do |params, result|
        it "should be #{result} when given parameters #{params.inspect}" do
          m = quack_like_an(Object)
          m.__send__(:arity_compare, *params).should == result
        end
      end
    end
  end
end

