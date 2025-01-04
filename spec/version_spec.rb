# frozen_string_literal: true

require_relative '../build/lib/version'

describe 'Version ops' do
  before(:all) do
    @style_file = 'spec/support/style.html'
    @script_file = 'spec/support/script.html'
    new_script_file = 'spec/support/new_script.html'
    new_style_file = 'spec/support/new_style.html'
    @new_script_content = File.read(File.expand_path(new_script_file, Dir.pwd))
    @new_style_content = File.read(File.expand_path(new_style_file, Dir.pwd))
  end

  before(:each) do
    @v = Version.new
  end

  it 'returns a hash of CSS files and versions in a template' do
    file_list = {
      'bootstrap-site-only.css' => '2.2',
      'modj-style.css'          => '2.3'
    }
    expect(@v.links_in_template(@style_file)).to eq file_list
  end

  it 'returns an array of JS files and versions in a template' do
    file_list = {
      'bootstrap.min.js' => '1.1',
      'jquery.min.js'    => '4.0',
      'newwindow.js'     => '1.0'
    }
    expect(@v.links_in_template(@script_file)).to eq file_list
  end

  it 'adds one tenth to a number' do
    expect(@v.increment_version('1.9')).to eq 2.0
  end

  it 'returns the JS file contents with an incremented version' do
    result = @v.replace_version(@script_file, 'jquery.min.js', '4.1')
    expect(result).to eq @new_script_content
  end

  it 'returns the CSS file contents with an incremented version' do
    result = @v.replace_version(@style_file, 'modj-style.css', '2.4')
    expect(result).to eq @new_style_content
  end
end
