require File.join(File.dirname(__FILE__), 'lib', 'htmlgrid/grid.rb')

spec = Gem::Specification.new do |s|
   s.name        = "htmlgrid"
   s.version     = VERSION
   s.summary     = "HtmlGrid is a Html-ToolKit for Ruby Webframeworks."
   s.description = "Not much to say."
   s.author      = "Masaomi Hatakeyama, Zeno R.R. Davatz"
   s.email       = "mhatakeyama@ywesee.com, zdavatz@ywesee.com"
   s.platform    = Gem::Platform::RUBY
   s.license     = "GPL v2.1"
   s.files       = Dir.glob("{bin,lib,test}/**/*") + Dir.glob("*.txt")
   s.add_development_dependency "hoe"
   s.homepage	 = "https://github.com/zdavatz/htmlgrid/"
end

