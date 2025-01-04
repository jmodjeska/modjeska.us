# frozen_string_literal: true

require_relative 'config'

# Revs the version number on CSS and JS assets
class Version
  def check_for_file_updates(file)
    return system("git ls-files -m | grep #{file} > /dev/null")
  end

  def links_in_template(file)
    asset_type = ASSET_TYPES.find { |_, type| file.include?(type) }&.first
    links = {}
    regex = %r{/#{asset_type}/(.*?.#{asset_type})\?ver=(\d+\.\d+)"}
    File.read(file).scan(regex).each { |r| links[r[0]] = r[1] }
    return links
  end

  def increment_version(version)
    return (version.to_f + 0.1).round(1)
  end

  def replace_version(file, asset_name, new_ver)
    regex = %r{(https?://.*?/.*?#{asset_name}\?ver=)(\d+\.\d+)}
    return File.read(file).sub(regex) { "#{Regexp.last_match[1]}#{new_ver}" }
  end
end
