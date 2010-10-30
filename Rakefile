require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "makandra_resource_controller"
    s.summary = "Rails RESTful controller abstraction plugin."
    s.email = "github@makandra.com"
    s.homepage = "http://github.com/makandra/resource_controller"
    s.description = ""
    s.authors = ["James Golick", "Brian Quinn", "Derek Kastner", "Sean Schofield", "Henning Koch"]
    file_list = FileList.new("[A-Z]*.*", "{bin,generators,lib,test,spec,rails}/**/*") do |f|
      f.exclude(/\.sqlite3/)
      f.exclude(/\.log/)
    end
    s.files = file_list
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Generate documentation for the ResourceController plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = '../rdoc'
  rdoc.title    = 'ResourceController'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('../README.rdoc')
  rdoc.rdoc_files.include('../lib/**/*.rb')
end

task :rc_test do
  Dir.chdir('test')
  load 'Rakefile'
  Rake::Task['test'].execute
end

task :default => :rc_test
