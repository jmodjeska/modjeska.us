# frozen_string_literal: true

require_relative 'lib/config'
require_relative 'lib/builder'
require_relative 'lib/local'

check_dir(File.basename(Dir.getwd))

@b = Builder.new

puts '-=> Build step: write posts from data files + templates'

puts '-=> Checking for required files ...'
unless @b.check_files
  puts '-=> Some files were missing; proceeding without them ...'
  @b.ignore_missing_directories
end

build_list = @b.directories_to_build
if build_list.nil? || build_list.empty?
  abort 'EXIT: Intersection of data and templates ie empty!'
end
puts "-=> Building directories: #{build_list.join(', ')} ..."

# If on a local dev env, setup the styles to work locally

if local?(File.expand_path(__dir__))
  puts '-=> Uncommenting assets for local dev ...'
  loc = Local.new
  page = PAGE_PARTS['@@STYLE@@']
  loc.uncomment(page, 'local-dev-')
  loc.comment(page, 'responsive-style-css')
  loc.comment(page, 'bootstrap-css')
else
  puts '-=> Skipped asset commenting in non-local env'
end

# Write pages if directory is in the build list

build_list.each do |cat|
  template_f = @b.file_list.detect { |e| e.include?("templates/#{cat}.html") }
  data_file = @b.file_list.detect { |e| e.include?("data/#{cat}.yml") }
  template = File.read(template_f)
  data = YAML.load_file(data_file)

  unless @b.check_for_posts(data)
    puts "-=> No post data found in the file #{data_file}"
    next
  end

  unless @b.match_data_to_template(template, data)
    puts "-=> Data doesn't conform to template for the file #{data_file}"
    next
  end

  puts "-=> Building pages for #{cat} ..."
  @b.merge_data_to_template(template, data).each_with_index do |page, i|
    filename = "#{data['posts'][i]['slug']}.html"
    puts "-   #{filename}"
    File.write("#{BUILD_DIR}/#{cat}/#{filename}", page)
  end
end

# Create root pages

puts '-=> Building root pages ...'
ROOT_PAGES.each do |page|
  puts "-   #{page}"
  @b.build_root_page("root-pages/#{page}", "#{BUILD_DIR}/#{page}")
end
