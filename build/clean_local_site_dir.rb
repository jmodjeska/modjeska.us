# frozen_string_literal: true

require 'fileutils'

@files_to_keep = [
  'build/site/index.html',
  'build/site/404.html',
  'build/site/code/index.html',
  'build/site/pictures/index.html',
  'build/site/words/index.html'
]

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
  if Dir.empty?(dir)
    puts "Deleting empty directory: #{dir}"
    Dir.rmdir(dir)
  end
end
