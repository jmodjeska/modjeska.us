# frozen_string_literal: true

require_relative 'builder'
require 'fileutils'

#
# 2024.12.23
#
# AWS Amplify rewrites don't work as expected, so it's not currently possible
# to redirect or rewrite the old WP-style slugs - like /pictures-snow-day - to
# my preferred structure, /pictures/snow-day.
#
# To work around this for now, make a copy of each HTML file in the root
# with the 'pictures-snow-day' naming convention.
#
# Ensure this script runs after the build in amplify.yml.
#

execution_dir = 'modjeska.us'
current_dir = File.basename(Dir.getwd)
build_dir = 'build/site'

unless execution_dir == current_dir
  abort 'EXIT: Call this script from the root project directory, ' \
    "#{execution_dir} (currently calling from '#{current_dir})'."
end

puts '-=> Build step: copy files to support WP-style slugs'

@b = Builder.new

@b.required_files.each do |dir|
  Dir.each_child("#{build_dir}/#{dir}") do |file|
    next if file == 'index.html'
    next unless File.extname(file) == '.html'

    # pictures-snow-day.html
    slug = "#{dir}-#{file}"

    # snow-day
    basename = File.basename(file, File.extname(file))

    # /build/site/pictures/snow-day.html
    source = "#{build_dir}/#{dir}/#{file}"

    # /build/site/pictures-snow-day.html
    root_level_file = "#{build_dir}/#{slug}"

    # /build/site/pictures-snow-day
    slug_equivalent_dir = "#{build_dir}/#{dir}-#{basename}"

    # /build/site/pictures-snow-day/index.html
    index_file = "#{build_dir}/#{dir}-#{basename}/index.html"

    # Create root-level HTML pages: /pictures-snow-day.html
    puts "-=> Copying #{source} to #{root_level_file}"
    FileUtils.cp(source, root_level_file)

    # Create root-level directories: /pictures-snow-day/index.html
    # This handles /pictures-snow-day/ with the trailing slash
    puts "-=> Copying #{source} to #{index_file}"
    FileUtils.mkdir_p(slug_equivalent_dir)
    FileUtils.cp(source, index_file)
  end
end
