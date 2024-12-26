# frozen_string_literal: true

EXECUTION_DIR = 'modjeska.us'
BUILD_DIR = 'build/site'
FOOTER = 'page-parts/footer.html'

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
