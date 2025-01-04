# frozen_string_literal: true

require 'yaml'
require_relative 'config'

# Build pipeline functions
class Builder
  attr_reader :required_dirs, :required_files, :file_list

  def initialize
    @required_files = REQUIRED_FILES
    @required_dirs = REQUIRED_DIRECTORIES
    @file_list = build_file_list
  end

  def build_file_list
    list = []
    @required_files.product(@required_dirs.to_a) do |basename, (dir, ext)|
      list << File.expand_path("#{dir}/#{basename}.#{ext}", Dir.pwd)
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
    return data.is_a?(Hash) && data.key?('posts')
  end

  # Convert post data keys (e.g., 'title') into tags ('@@TITLE@@')
  def transform_keys_to_tags(post_data)
    return post_data['posts'][0].keys.map { |key| "@@#{key.upcase}@@" }
  end

  # Validates data.yml will merge correctly into template.html
  def match_data_to_template(template, data)
    tags = template.scan(/@@.*?@@/).flatten.uniq
    tags -= PAGE_PARTS.keys
    return transform_keys_to_tags(data).sort == tags.sort
  end

  # Returns an array of posts
  def merge_data_to_template(template, data)
    return false unless check_for_posts(data)
    return false unless match_data_to_template(template, data)
    output = []
    data['posts'].each_with_index do |post, i|
      temp = template.dup
      post.each { |k, v| temp.gsub!("@@#{k.upcase}@@", v.to_s) }
      output[i] = add_page_parts(temp)
    end
    return output
  end

  # Add page parts
  def add_page_parts(content)
    content.prepend(File.read(PAGE_PARTS[:top]))
    PAGE_PARTS.each do |k, v|
      next if k.is_a?(Symbol)
      content.gsub!(k, File.read(v))
    end
    content << (File.read(PAGE_PARTS[:footer]))
    return content
  end

  # Identifies the file slug name
  def file_slug(file, dir)
    basename = File.basename(file, File.extname(file))
    return dir == 'pictures' ? "#{dir}-#{basename}" : basename
  end

  # Builds a root page
  def build_root_page(input_filename, output_filename)
    content = File.read(input_filename)
    content = add_page_parts(content)
    File.write(output_filename, content)
    return File.exist?(output_filename)
  end
end
