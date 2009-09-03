spec = Gem::Specification.new do |s|
  s.name = "quacks-like"
  s.version = "1.0.0"
  s.author = "Michael H Buselli"
  s.email = ["cosine@cosine.org", "michael@buselli.com"]
  #s.files = ["LICENSE"] + Dir["lib/**/*"]
  s.files = ["LICENSE", "lib/quacks_like.rb"]
  s.require_path = "lib"
  s.has_rdoc = true
  s.rubyforge_project = "quacks-like"
  s.homepage = "http://cosine.org/ruby/QuacksLike/"

  s.summary = "QuacksLike — RSpec matcher for duck-type testing"

  s.description = <<-__EOF__
    QuacksLike is a module for RSpec to add matchers that test if an
    object is fully duck-typed to pretend to be another class.  This
    kind of thing is really only necessary when passing such an
    object as the return value in an API where you don't know
    exactly how it will be consumed, but it needs to "quack like an
    Array" or something.  It does its job by checking every instance
    method in the class that the target object needs to "quack like"
    and makes sure the target both responds to that method name and
    that the arity of the method is appropriate.
  __EOF__
end
