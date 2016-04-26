#!/usr/bin/env ruby
# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'htmlgrid/version'
require "bundler/gem_tasks"
require 'rake/testtask'
require "rspec/core/rake_task"

if /java/i.match(RUBY_PLATFORM)
  puts "Don't build C-Library for JRUBY under RUBY_PLATFORM is #{RUBY_PLATFORM}"
else
  desc 'rebuild the C-library'
  task :rebuild do
    require "#{File.dirname(__FILE__)}/test/rebuild"
  end
  task :test => :rebuild
end

require 'minitest/reporters'
MiniTest::Reporters.use!

Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
end


# dependencies are now declared in htmlgrid.gemspec
desc 'Offer a gem task like hoe'
task :gem => :build do
  Rake::Task[:build].invoke
end

task :spec => :clean

require 'rake/clean'
CLEAN.include FileList['pkg/*.gem']
# vim: syntax=ruby
