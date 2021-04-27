require 'rake'
require 'rspec/core/rake_task'
require 'dotenv'

# load the .env file contents
Dotenv.load('dev.env')

task spec: 'spec:all'
task default: :spec

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)

    target = File.basename(dir)
    target = "_#{target}" if target == 'default'
    targets << target
  end

  task all: targets
  task default: :all

  targets.each do |target|
    original_target = target == '_default' ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = if original_target == 'SP2012R2AD.sposcar.local'
                             '192.168.2.19'
                           else
                             original_target
                           end
      t.pattern = "spec/#{original_target}/*_spec.rb"
    end
  end
end
