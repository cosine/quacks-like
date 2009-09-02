
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

