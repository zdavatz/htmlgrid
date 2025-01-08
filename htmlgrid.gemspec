require File.join(File.dirname(__FILE__), "lib", "htmlgrid/version.rb")

Gem::Specification.new do |s|
  s.name = "htmlgrid"
  s.version = HtmlGrid::VERSION
  s.summary = "HtmlGrid is a Html-ToolKit for Ruby Webframeworks."
  s.description = "Not much to say."
  s.author = "Masaomi Hatakeyama, Zeno R.R. Davatz"
  s.email = "mhatakeyama@ywesee.com, zdavatz@ywesee.com"
  s.platform = Gem::Platform::RUBY
  s.license = "GPL v2.1"
  s.files = Dir.glob("{bin,lib,test}/**/*") + Dir.glob("*.txt")
  s.homepage = "https://github.com/zdavatz/htmlgrid/"
  s.metadata["changelog_uri"] = s.homepage + "/blob/master/History.md"

  s.add_dependency "sbsm", ">= 1.2.7"
  if !RUBY_VERSION.match?(/^2\.(2|3)/)
    s.add_development_dependency "rack", "~> 1.6.4"
  else
    s.add_development_dependency "rack", ">= 2.1.4"
  end
  s.add_development_dependency "psych", "< 4.0.0"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "flexmock"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "standardrb"
end
