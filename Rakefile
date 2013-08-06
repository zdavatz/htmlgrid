# -*- ruby -*-

require 'rubygems'
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

Hoe.spec 'htmlgrid' do
  # HEY! If you fill these out in ~/.hoe_template/Rakefile.erb then
  # you'll never have to touch them again!
  # (delete this comment too, of course)
  license('GPL v2.1')
  developer('Masaomi Hatakeyama, Zeno R.R. Davatz', 'mhatakeyama@ywesee.com, zdavatz@ywesee.com')

  # self.rubyforge_name = 'htmlgridx' # if different than 'htmlgrid'
end

desc 'rebuild the C-library'
task :rebuild do
  require "#{File.dirname(__FILE__)}/test/rebuild"
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
end

task :test => :rebuild
# vim: syntax=ruby
