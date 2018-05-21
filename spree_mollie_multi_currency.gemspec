# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_mollie_multi_currency'
  s.version     = '3.1.0'
  s.summary     = 'Use the Mollie PSP in your Spree storefront'
  s.description = s.summary
  s.required_ruby_version = '>= 2.1.0'

  s.author    = 'Isabella Santos'
  s.email     = 'isabella.cdossantos@gmail.com'
  #s.homepage  = ''

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.1.0'
  s.add_dependency 'mollie-ruby-multi-version', '0.3.1.3'
  s.add_dependency 'rest-client', '~> 2.0'

  s.add_development_dependency 'poltergeist', '~> 1.5.0'
  s.add_development_dependency 'capybara', '~> 2.4'
  #s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 5.0.0.beta1'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'byebug'
end
