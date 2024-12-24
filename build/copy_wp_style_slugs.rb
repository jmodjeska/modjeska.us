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
    slug = "#{dir}-#{file}"
    puts "-=> Copying #{build_dir}/#{dir}/#{file} to #{build_dir}/#{slug}"
    FileUtils.cp("#{build_dir}/#{dir}/#{file}", "#{build_dir}/#{slug}")
  end
end
