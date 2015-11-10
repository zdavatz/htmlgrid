source "http://rubygems.org"

gem 'sbsm'

group :development, :test do
  gem 'rake'
  gem "minitest"
  gem "minitest-reporters"
  gem 'simplecov'
  gem 'test-unit'
end

group :development do
  gem 'racc'
  gem 'travis-lint'
  gem 'rspec'
end

group :debugger do
  if /^2/.match(RUBY_VERSION)
    gem 'pry-byebug'
  else
    gem 'pry'
    gem 'pry-debugger'
  end
end