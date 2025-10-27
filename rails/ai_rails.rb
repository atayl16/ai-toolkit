# frozen_string_literal: true
# AI Rails Template - Alisha's opinionated Rails setup
# Usage: rails new myapp -d postgresql --css=tailwind -m ~/.ai-toolkit/rails/ai_rails.rb

TOOLKIT_PATH = File.expand_path('~/.ai-toolkit')

# TIER 1: Essential (always included)
gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'overcommit', require: false
  gem 'dotenv-rails'
  # Note: Rails 8+ includes brakeman by default (bin/brakeman)
  gem 'bundler-audit', require: false
end

# TIER 2: Optional (performance, debugging, docs - can be skipped)
# Uncomment these when needed:
# gem_group :development, :test do
#   gem 'bullet'                      # N+1 query detection
#   gem 'rack-mini-profiler'          # Performance profiling
#   gem 'annotate'                    # Model annotations
#   gem 'database_cleaner-active_record'  # Test isolation
#   gem 'simplecov', require: false   # Test coverage
# end
# gem_group :development do
#   gem 'rails-erd', require: false   # ERD generation
# end

after_bundle do
  # Install RSpec
  rails_command 'g rspec:install'

  # Copy config templates from toolkit
  template_dir = "#{TOOLKIT_PATH}/templates/rails"
  
  copy_file "#{template_dir}/.rubocop.yml", '.rubocop.yml'
  copy_file "#{template_dir}/.overcommit.yml", '.overcommit.yml'
  copy_file "#{template_dir}/Justfile", 'Justfile'
  copy_file "#{template_dir}/.erdconfig", '.erdconfig'
  
  # Update RuboCop target Ruby version dynamically
  gsub_file '.rubocop.yml', 'TargetRubyVersion: 3.3', "TargetRubyVersion: #{RUBY_VERSION[0..2]}"

  # TIER 2: SimpleCov setup (only if gem is present)
  if File.exist?('Gemfile') && File.read('Gemfile').include?('simplecov')
    append_to_file 'spec/rails_helper.rb', <<~RUBY

      require 'simplecov'
      SimpleCov.start 'rails' do
        enable_coverage :branch
        add_filter %w[bin/ db/ config/ spec/]
      end
    RUBY
  end

  # TIER 2: Bullet & MiniProfiler setup (only if gems are present)
  bullet_exists = File.exist?('Gemfile') && File.read('Gemfile').include?('bullet')
  if bullet_exists
    environment <<~RUBY, env: 'development'
      config.after_initialize do
        Bullet.enable = true
        Bullet.bullet_logger = true
      end
    RUBY
  end
  
  # MiniProfiler setup (only if gem is present)
  if File.exist?('Gemfile') && File.read('Gemfile').include?('rack-mini-profiler')
    environment <<~RUBY, env: 'development'
      Rack::MiniProfiler.config.enable_hotwire_turbo_drive_support = true
    RUBY
  end

  # TIER 2: Install Annotate (only if gem is present)
  if File.exist?('Gemfile') && File.read('Gemfile').include?('annotate')
    generate 'annotate:install'
  end

  # Install Overcommit hooks
  run 'bundle exec overcommit --install'

  # Create custom bin/setup script
  remove_file 'bin/setup'
  copy_file "#{template_dir}/bin_setup", 'bin/setup'
  run 'chmod +x bin/setup'

  # Create necessary directories
  run 'mkdir -p reports docs ai'

  # Initialize git and make first commit
  git :init
  git add: '.'
  # Use --no-verify to skip Overcommit hooks on initial commit (Rails-generated files have style issues)
  git commit: %q(-m "Bootstrap app with AI Rails template" --no-verify)

  say '✓ AI Rails template applied successfully!', :green
  say ''
  say 'Next steps:', :yellow
  say '  cd #{app_name}'
  say '  bin/setup'
  say '  just test'
  say '  dev scans'
end
