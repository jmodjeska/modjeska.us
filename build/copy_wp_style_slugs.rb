# frozen_string_literal: true

require_relative 'lib/builder'
require_relative 'lib/config'
require 'fileutils'

#
# 2024.12.23
#
# AWS Amplify rewrites don't work as expected, so it's not currently possible
# to redirect or rewrite the old WP-style slugs for my pictures directory -
# like /pictures-snow-day - to my preferred structure, /pictures/snow-day.
#
# To work around this for now, make a copy of each HTML file in the root
# with the 'pictures-snow-day' naming convention, and create a directory
# for the post with the content copied in an index.html file.
#
# Ensure this script runs after the build in amplify.yml.
#

current_dir = File.basename(Dir.getwd)
check_dir(current_dir)

puts '-=> Build step: copy files to support WP-style slugs'

@b = Builder.new

@b.required_files.each do |dir|
  Dir.each_child("#{BUILD_DIR}/#{dir}") do |file|
    next if file == 'index.html'
    next unless File.extname(file) == '.html'
    source = "#{BUILD_DIR}/#{dir}/#{file}"
    slug = @b.file_slug(file, dir)
    root_level_dir = "#{BUILD_DIR}/#{slug}"

    puts "-=> Copying #{source} to ..."

    puts "-   #{root_level_dir}.html"
    FileUtils.cp(source, "#{root_level_dir}.html")

    puts "-   #{BUILD_DIR}/#{dir}/#{slug}/index.html"
    FileUtils.mkdir_p("#{BUILD_DIR}/#{dir}/#{slug}")
    FileUtils.cp(source, "#{BUILD_DIR}/#{dir}/#{slug}/index.html")

    puts "-   #{root_level_dir}/index.html"
    FileUtils.mkdir_p(root_level_dir)
    FileUtils.cp(source, "#{root_level_dir}/index.html")
  end
end
