
require 'rake/gempackagetask'
require 'spec/rake/spectask'

gemspec_file = 'quacks-like.gemspec'
spec = nil
eval File.read(gemspec_file), binding, gemspec_file, 1


Rake::GemPackageTask.new(spec) {}


desc "Run the RSpec tests"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.spec_opts = ['-c', '-f s']
end


desc "Clean up generated files and directories"
task :clean do |t|
  rm_rf "pkg"
end


task :default => :gem
