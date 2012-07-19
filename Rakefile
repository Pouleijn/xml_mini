#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = '**/*_test.rb'
end

desc "Default Task"
task :default => "test"