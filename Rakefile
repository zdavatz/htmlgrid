# -*- ruby -*-

require 'rubygems'
require 'bundler'
require 'hoe'

# Hoe.plugin :compiler
# Hoe.plugin :cucumberfeatures
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline
# Hoe.plugin :inline
# Hoe.plugin :manifest
# Hoe.plugin :newgem
# Hoe.plugin :racc
# Hoe.plugin :rubyforge
# Hoe.plugin :rubyforge
# Hoe.plugin :website


require 'rubygems'
require 'bundler'
require 'hoe'

ENV['RDOCOPT'] = '-c utf8'

Hoe.plugin :git

Hoe.spec('htmlgrid') do |p|
   p.developer('Masaomi Hatakeyama, Zeno R.R. Davatz','mhatakeyama@ywesee.com, zdavatz@ywesee.com')
   p.license('GPL v2.1')
   p.remote_rdoc_dir = 'htmlgrid'
   p.extra_deps << ['ruby-ole', '>=1.0']
end

if /java/i.match(RUBY_PLATFORM)
  puts "Don't build C-Library for JRUBY under RUBY_PLATFORM is #{RUBY_PLATFORM}"
else
  desc 'rebuild the C-library'
  task :rebuild do
    require "#{File.dirname(__FILE__)}/test/rebuild"
  end
  task :test => :rebuild
end

#require 'minitest/reporters'
#MiniTest::Reporters.use!

#Rake::TestTask.new do |t|
#  t.pattern = "test/test_*.rb"
#end

# vim: syntax=ruby
