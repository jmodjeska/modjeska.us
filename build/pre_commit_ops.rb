# frozen_string_literal: true

require 'optparse'
require 'rspec'
require_relative 'lib/config'
require_relative 'lib/version'

unless File.expand_path(__dir__).include?('Code/modjeska.us')
  abort 'EXIT: Not running from a safe directory!'
end

# Parse command line options

flags = {}
parser = OptionParser.new do |o|
  o.on('-s', '--skip-rev', "Don't rev asset versions") { flags[:rev] = true }
end
parser.parse!

# RSpec

puts '-=> Running tests ... '

rspec_output = RSpec::Core::Runner.run(['spec'])
abort 'EXIT: Some tests failed' unless rspec_output.zero?

# Clean files and dirs

puts '-=> Deleting HTML files ...'

@files_to_keep = ROOT_PAGES.map { |file| "#{BUILD_DIR}/#{file}" }

Dir.glob("#{BUILD_DIR}/**/*.html") do |file|
  unless @files_to_keep.include?(file)
    puts truncate("-   Deleting: #{file}")
    FileUtils.rm(file)
  end
end

puts '-=> Deleting empty directories ...'

Dir.glob("#{BUILD_DIR}/**/").reverse_each do |dir|
  next if REQUIRED_FILES.map { |f| "#{BUILD_DIR}/#{f}/" }.include?(dir)
  next unless Dir.empty?(dir)
  puts truncate("-   Deleting empty directory: #{dir}")
  Dir.rmdir(dir)
end

# Rev asset versions

exit if flags[:rev]

puts '-=> Checking for CSS and JS asset changes ...'

@v = Version.new
@versions_to_update = []

s3_asset_files.each do |file|
  next unless @v.check_for_file_updates(file)
  @versions_to_update << file
  puts truncate("-   Changed: #{file}")
end

puts '-=> Updating asset versions ...' unless @versions_to_update.empty?

@versions_to_update&.each do |asset_name|
  template = find_template(asset_name)
  asset_versions = @v.links_in_template(template)
  new_ver = @v.increment_version(asset_versions[asset_name])
  puts truncate("-   Updating #{asset_name} in #{template} to v#{new_ver}")
  content = @v.replace_version(template, asset_name, new_ver)
  File.write(template, content)
end
