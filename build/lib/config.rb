# frozen_string_literal: true

require 'fileutils'

EXECUTION_DIR = 'modjeska.us'
BUILD_DIR = 'build/site'
MAX_WIDTH = 80

# Static page parts for page builder
PAGE_PARTS = {
  :top         => 'page-parts/top.html',
  :footer      => 'page-parts/footer.html',
  '@@SCRIPT@@' => 'page-parts/script.html',
  '@@STYLE@@'  => 'page-parts/style.html',
  '@@GTAG@@'   => 'page-parts/gtag.html',
  '@@NAV@@'    => 'page-parts/nav.html'
}.freeze

ASSET_TYPES = {
  'css' => 'style',
  'js'  => 'script'
}.freeze

# Core elements to build the site
REQUIRED_FILES = %w[code pictures words].freeze
REQUIRED_DIRECTORIES = { 'templates': 'html', 'data': 'yml' }.freeze
ROOT_PAGES = [
  'index.html',
  '404.html',
  'code/index.html',
  'words/index.html',
  'pictures/index.html'
].freeze

# S3 config
S3_BUCKET = 'i.modjeska.us'
S3_ASSETS_DIR = 's3'
CONTENT_TYPES = {
  'css' => 'text/css',
  'js'  => 'application/javascript'
}.freeze

# Directory location check
def check_dir(current_dir)
  return if current_dir == EXECUTION_DIR
  abort 'EXIT: Call this script from the root project directory, ' \
    "#{EXECUTION_DIR} (currently calling from '#{current_dir})'."
end

# Locality check
def local?(dir)
  return dir.include?('Dropbox/Code')
end

# Truncate string for CLI output
def truncate(string)
  return string.length > MAX_WIDTH ? "#{string[0...MAX_WIDTH]}..." : string
end

# File extension
def get_file_type(file)
  return File.extname(file)[1..]
end

# Identify the template file where an asset is referenced
def find_template(asset)
  Dir.glob('page-parts/*.html').each do |f|
    return f if File.readlines(f).any? { |line| line.include?(asset) }
  end
end

# Enumerate files in S3 directories for assets we actively build
def s3_asset_files
  files = []
  CONTENT_TYPES.each_key do |dir|
    Dir.each_child("#{S3_ASSETS_DIR}/#{dir}") do |file|
      next unless CONTENT_TYPES.key?(get_file_type(file))
      files << file
    end
  end
  return files
end
