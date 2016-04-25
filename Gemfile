source "http://rubygems.org"

gemspec
gem 'sbsm', :git => 'https://github.com/ngiger/sbsm.git'

group :debugger do
  if /^2/.match(RUBY_VERSION)
    gem 'pry-byebug'
  end
  gem 'pry-doc'
end
