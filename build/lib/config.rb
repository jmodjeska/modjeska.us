# frozen_string_literal: true

EXECUTION_DIR = 'modjeska.us'
BUILD_DIR = 'build/site'

# Don't include reserved parts in template merging
RESERVED_PAGE_PARTS = %w[nav head footer].freeze
FOOTER = 'page-parts/footer.html'
HEAD = 'page-parts/head.html'
NAV = 'page-parts/nav.html'

def check_dir(current_dir)
  return if current_dir == EXECUTION_DIR
  abort 'EXIT: Call this script from the root project directory, ' \
    "#{EXECUTION_DIR} (currently calling from '#{current_dir})'."
end

REQUIRED_DIRECTORIES = {
  'templates': 'html',
  'data': 'yml'
}.freeze

REQUIRED_FILES = %w[code pictures words].freeze

ROOT_PAGES = [
  'index.html',
  '404.html',
  'code/index.html',
  'words/index.html',
  'pictures/index.html'
].freeze
