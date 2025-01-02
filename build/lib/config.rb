# frozen_string_literal: true

EXECUTION_DIR = 'modjeska.us'
BUILD_DIR = 'build/site'

# Don't include reserved parts in template merging
RESERVED_PAGE_PARTS = %w[nav head footer].freeze

# Page parts
FOOTER = 'page-parts/footer.html'
HEAD = 'page-parts/head.html'
NAV = 'page-parts/nav.html'

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
S3_PATHS = %w[css js].freeze

# Directory location check
def check_dir(current_dir)
  return if current_dir == EXECUTION_DIR
  abort 'EXIT: Call this script from the root project directory, ' \
    "#{EXECUTION_DIR} (currently calling from '#{current_dir})'."
end
