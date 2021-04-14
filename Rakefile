#!/usr/bin/env ruby

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "htmlgrid/version"
require "bundler/gem_tasks"
require "rake/testtask"
require "rspec/core/rake_task"
require "standard/rake"

require "minitest/reporters"
MiniTest::Reporters.use!

Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
end

# dependencies are now declared in htmlgrid.gemspec
desc "Offer a gem task like hoe"
task gem: :build do
  Rake::Task[:build].invoke
end

task spec: :clean
task default: [:clean, :test, :build]

require "rake/clean"
CLEAN.include FileList["pkg/*.gem"]
# vim: syntax=ruby
