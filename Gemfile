source "http://rubygems.org"

gemspec

group :debugger do
  if /^2/.match?(RUBY_VERSION)
    gem "pry-byebug"
  end
  gem "pry-doc"
end
