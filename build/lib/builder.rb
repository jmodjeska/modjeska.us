# frozen_string_literal: true

require 'yaml'
require_relative 'config'

# Build pipeline functions
class Builder
  attr_reader :required_directories, :required_files, :file_list

  def initialize
    @required_files = REQUIRED_FILES
    @required_directories = REQUIRED_DIRECTORIES
    @file_list = build_file_list
  end

  def build_file_list
    list = []
    @required_files.each do |basename|
      @required_directories.each do |dir, ext|
        list << File.expand_path("#{dir}/#{basename}.#{ext}", Dir.pwd)
      end
    end
    return list
  end

  # Validates expected files are present
  def check_files
    temp_file_list = @file_list.dup
    expected_files_count = @file_list.count
    temp_file_list.delete_if do |file|
      next if File.exist?(file)
      puts "MISSING: #{file}"
      true
    end
    return temp_file_list.count == expected_files_count
  end

  # Removes directories from the build if their data or template is missing
  def ignore_missing_directories
    @file_list.delete_if { |f| !File.exist?(f) }
    return check_files
  end

  # Determine which web directories have the required data to build
  def directories_to_build(known_files = @file_list)
    directory_files = Hash.new { |h, k| h[k] = [] }
    known_files.each do |file|
      parent_dir = File.basename(File.dirname(file))
      filename = File.basename(file, File.extname(file))
      directory_files[parent_dir] << filename
    end
    return directory_files.values.reduce(:&)
  end

  # Validates that a YAML data blob contains post data
  def check_for_posts(data)
    return true if data.is_a?(Hash) && data.key?('posts')
    return false
  end

  # Validates that data.yml will merge correctly into template.html
  def match_data_to_template(template, data)
    data_keys = data['posts'][0].keys
    template_keys = template.scan(/@@(.*?)@@/).flatten.uniq.map(&:downcase)
    return true if data_keys.sort == template_keys.sort
    return false
  end

  # Returns an array of posts
  def merge_data_to_template(template, data)
    return false unless check_for_posts(data)
    return false unless match_data_to_template(template, data)
    output = []
    data['posts'].each_with_index do |post, i|
      temp = template.dup
      post.each { |k, v| temp.gsub!("@@#{k.upcase}@@", v.to_s) }
      output[i] = temp
      output[i] << File.read(FOOTER)
    end
    return output
  end

  # Identifies the file slug name
  def file_slug(file, dir)
    basename = File.basename(file, File.extname(file))
    return dir == 'pictures' ? "#{dir}-#{basename}" : basename
  end
end
