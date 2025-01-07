# frozen_string_literal: true

require 'optparse'
require 'rspec'
require_relative 'lib/config'
require_relative 'lib/version'
require_relative 'lib/local'

# Local cleanup operations to run before committing changes
# Do not include this script in the Amplify build

# Safety checks

check_dir(File.basename(Dir.getwd))
abort 'EXIT: Only run this locally' unless local?(File.expand_path(__dir__))

# Parse command line options

flags = {}
parser = OptionParser.new do |o|
  o.on('-v', '--skip-ver', "Don't version assets") { flags[:skipver]   = true }
  o.on('-t', '--skip-tests', "Don't run tests")    { flags[:skiptests] = true }
  o.on('-c', '--skip-clean', "Don't clean files")  { flags[:skipclean] = true }
end
parser.parse!

# RSpec

unless flags[:skiptests]
  puts '-=> Running tests ... '
  rspec_output = RSpec::Core::Runner.run(['spec'])
  abort 'EXIT: Some tests failed' unless rspec_output.zero?
end

# Clean files and dirs

unless flags[:skipclean]
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
end

# Rev asset versions

unless flags[:skipver]
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
end

# Comment out local dev assets; uncomment production assets

puts '-=> Commenting out local assets in style template ...'

loc = Local.new
page = PAGE_PARTS['@@STYLE@@']
loc.comment(page, 'local-dev-')
loc.uncomment(page, 'responsive-style-css')
loc.uncomment(page, 'bootstrap-css')

# End

puts '-=> All pre-commit operations complete.'
