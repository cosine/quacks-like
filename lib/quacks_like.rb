#
# Copyright (c) 2009, Michael H. Buselli
# See LICENSE for details on permitted use.
#

#
# QuacksLike is a module for RSpec to add matchers that test if an
# object is fully duck-typed to pretend to be another class.  This kind
# of thing is really only necessary when passing such an object as the
# return value in an API where you don't know exactly how it will be
# consumed, but it needs to "quack like an Array" or something.  It does
# its job by checking every instance method in the class that the target
# object needs to "quack like" and makes sure the target both responds
# to that method name and that the arity of the method is appropriate.
#
# Usage (in RSpec files):
#   require 'quacks_like'
#
#   it "should return an object that quacks like a Hash" do
#     my_func.should quack_like_a(Hash)
#   end
#
#   it "should return an object that does not quack like an Array" do
#     my_func.should_not quack_like_an(Array)
#   end
#
class QuacksLike
  def initialize (quack_class)
    @quack_class = quack_class
  end

  def arity_compare (quack_arity, target_arity)
    if quack_arity >= 0
      target_arity == quack_arity or target_arity.between?(-1 - quack_arity, -1)
    else
      target_arity.between?(quack_arity, -1)
    end
  end
  private :arity_compare

  def matches? (target)
    @target = target
    @mismatches = []

    @quack_class.instance_methods.each do |m|
      if not @target.respond_to?(m)
        @mismatches.push "does not respond to :#{m}"
      elsif not arity_compare(q = @quack_class.instance_method(m).arity,
                              t = @target.method(m).arity)
        @mismatches.
            push "quacking method :#{m} has arity #{q} but found arity #{t}"
      end
    end

    @mismatches.empty?
  end

  def failure_message_for_should
    [@target.inspect, @mismatches.join(', ')].join(' ')
  end

  def failure_message_for_should_not
    "expected #{@target.inspect} to not quack like a(n) #{@quack_class.inspect}"
  end
end


def quack_like_a (quack_class)
  QuacksLike.new(quack_class)
end
alias quack_like_an quack_like_a

