# frozen_string_literal: true

require_relative 'builder'

execution_dir = 'modjeska.us'
current_dir = File.basename(Dir.getwd)
build_dir = 'build/site'

unless execution_dir == current_dir
  abort 'EXIT: Call the build script from the root project directory, ' \
    "#{execution_dir} (currently calling from '#{current_dir})'."
end

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

# Write pages if directory is in the build list
build_list.each do |cat|
  template_f = @b.file_list.detect { |e| e.include?("templates/#{cat}.html") }
  data_f = @b.file_list.detect { |e| e.include?("data/#{cat}.yml") }
  template = File.read(template_f)
  data = YAML.load_file(data_f)

  unless @b.check_for_posts(data)
    puts "-=> No post data found in the file #{data_f}"
    next
  end

  unless @b.match_data_to_template(template, data)
    puts "-=> Data doesn't conform to template for the file #{data_file}"
    next
  end

  puts "-=> Building pages for #{cat} ..."
  @b.merge_data_to_template(template, data).each_with_index do |page, i|
    filename = "#{data['posts'][i]['slug']}.html"
    puts "-=> Building #{filename} ..."
    File.write("#{build_dir}/#{cat}/#{filename}", page)
  end
end
