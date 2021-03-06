source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bundler', '~> 1.17', '>= 1.17.3'
gem 'rails', '4.2.7.1'
gem 'rake', '< 11.0'

# Use Postgresql as the database for Active Record
gem 'pg'

# used to schedule mail send
gem 'whenever', :require => false

# Use Bootstrap and SCSS for stylesheets
gem 'bootstrap-sass', '~> 3.3.6'
gem 'sass-rails', '>= 3.2'
gem 'bootstrap-growl-rails'

gem 'sprockets-rails', '2.3.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Jquery Ui
gem 'jquery-ui-rails'

gem 'tinymce-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# jQuery plugin for drop-in fix binded events problem caused by Turbolinks
#gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 2.3.1'

gem 'haml'
gem 'seed-fu', '~> 2.3'
gem 'simple_form'

# Used for API calls
gem 'httparty', '~> 0.13.1'

# Gem used for authentication
gem 'devise'

# Gem used for authorization
gem 'pundit'

# Exception notification
gem 'exception_notification', '~> 4.1.1'

# Gems for image upload
# File upload solution
gem 'carrierwave'
# Photo resizing
gem 'mini_magick'
# For AWS cloud storage
# gem 'fog'
# Delayed job
# gem 'delayed_job_active_record'
# Processes/Uploads image in the background
gem 'carrierwave_backgrounder'
# Daemons gem to activate Delayed job via Capistrano
gem 'daemons'

# Memcache client
gem 'dalli'
gem 'memcachier'

# For neested forms
gem 'cocoon'

# Text in Javascript file
gem 'gon'

# Get inputs from madloba:install task
gem 'highline'

gem 'font-awesome-sass'
gem 'will_paginate', '~> 3.1.0'

# jQuery DataTables plugin - provides all the basic DataTables files, and a few of the extras.
gem 'jquery-datatables-rails', '~> 3.4.0'

gem 'select2-rails'

# gem 'active_model_serializers'

gem 'dotenv-rails'

gem "recaptcha", require: "recaptcha/rails"

# model record heirarchy
gem 'ancestry', '~> 3.0', '>= 3.0.5'

# control order of lists
gem 'acts_as_list', '~> 0.9.19'

group :development, :test do

  # Mailcatcher
  # gem 'mailcatcher'

  # Capistrano
  # gem 'capistrano3-delayed-job', '~> 1.0'
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rbenv', '~> 2.0.3'
  gem 'capistrano-unicorn-nginx', '~> 4.0'

  # RSpec
  gem 'rspec-rails', '~> 3.3.3'
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails'

  gem 'awesome_print'

  gem 'haml-rails'
  gem 'pry-byebug'
  gem 'locales_export_import'
end

group :development do
  # add comments at top of model files of which fields are in the model
  gem 'annotate', '~> 2.7', '>= 2.7.4'
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'

  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'capybara-screenshot'
  # gem 'capybara-webkit'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# For Heroku deployments
# gem 'rails_12factor', group: :production
# gem 'unicorn'

# Translation
gem 'rails-i18n', '~> 4.0.0'
gem 'i18n-tasks', '~> 0.8.3'
gem 'globalize', '~> 5.0.0'
gem 'globalize-accessors'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]
