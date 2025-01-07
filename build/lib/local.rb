# frozen_string_literal: true

require_relative 'config'

# Swaps which stylesheets are active for local dev
class Local
  def comment(file_path, flag = 'local-dev-')
    lines = File.readlines(file_path)
    modified_lines = lines.map do |line|
      comment = line.include?(flag) && !line.include?('<!--')
      comment ? "  <!-- #{line.strip} -->" : line
    end
    File.open(file_path, 'w') do |file|
      modified_lines.each { |line| file.puts(line) }
    end
  end

  def uncomment(file_path, flag = 'local-dev-')
    lines = File.readlines(file_path)
    modified_lines = lines.map do |l|
      l.include?(flag) ? l.sub(/^  <!--\s*/, '  ').sub(/\s*-->$/, '') : l
    end
    File.open(file_path, 'w') do |file|
      modified_lines.each { |line| file.puts(line) }
    end
  end
end
