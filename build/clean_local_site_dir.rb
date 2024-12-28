# frozen_string_literal: true

require 'fileutils'
require_relative 'lib/config'

@files_to_keep = ROOT_PAGES.map { |file| "build/site/#{file}" }

unless File.expand_path(__dir__).include?('Code/modjeska.us')
  abort 'EXIT: Not running from a safe directory!'
end

# Remove HTML files
Dir.glob('build/site/**/*.html') do |file|
  unless @files_to_keep.include?(file)
    puts "Deleting: #{file}"
    FileUtils.rm(file)
  end
end

# Remove empty directories
Dir.glob('build/site/**/').reverse_each do |dir|
  next if REQUIRED_FILES.map { |f| "#{BUILD_DIR}/#{f}/" }.include?(dir)
  next unless Dir.empty?(dir)
  puts "Deleting empty directory: #{dir}"
  Dir.rmdir(dir)
end
