# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new
namespace :bench do
  Dir.glob("bench/*.rb").sort.each do |file|
    name = File.basename(file, ".rb")

    desc "Run #{name} benchmark"
    task name.to_sym do
      ruby file
    end
  end

  desc "Run all benchmarks"
  task :all do
    Dir.glob("bench/*.rb").sort.each do |file|
      puts
      puts "=" * 80
      puts "Running #{File.basename(file)}"
      puts "=" * 80

      ruby file
    end
  end
end

require "rake/extensiontask"

task build: :compile

GEMSPEC = Gem::Specification.load("hikari_buffer.gemspec")

Rake::ExtensionTask.new("hikari_buffer", GEMSPEC) do |ext|
  ext.lib_dir = "lib/hikari_buffer"
end

task default: %i[clobber compile spec rubocop]
