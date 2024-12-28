# frozen_string_literal: true

require_relative '../build/lib/builder'

def create_instance_vars
  test_template_file = 'spec/support/test_template.html'
  test_data_file = 'spec/support/test_data.yml'
  test_data_bad = 'spec/support/test_data_bad.yml'
  out_file_1 = 'spec/support/snow-day.html'
  out_file_2 = 'spec/support/spain-2019.html'

  @test_template = File.read(File.expand_path(test_template_file, Dir.pwd))
  @test_data = YAML.load_file(File.expand_path(test_data_file, Dir.pwd))
  @test_data_bad = YAML.load_file(File.expand_path(test_data_bad, Dir.pwd))
  @stub_output_1 = File.read(File.expand_path(out_file_1, Dir.pwd))
  @stub_output_2 = File.read(File.expand_path(out_file_2, Dir.pwd))
end

describe 'Build pipeline' do
  before(:all) do
    create_instance_vars
  end

  before(:each) do
    @b = Builder.new
    stub_const 'FOOTER', 'spec/support/footer.html'
  end

  it 'verifies that a list of required files was built' do
    files = @b.build_file_list
    expected_count = @b.required_dirs.count * @b.required_files.count
    expect(files.count).to eq expected_count
    expect(files.any? { |s| s.include?('templates/code.html') }).to be true
    expect(files.any? { |s| s.include?('data/code.yml') }).to be true
  end

  it 'identifies which required directories have filenames in common' do
    known_files = [
      'path/to/templates/a.html',
      'path/to/templates/b.html',
      'path/to/templates/c.html',
      'path/to/templates/d.html',
      'path/to/data/a.yml',
      'path/to/data/c.yml',
      'path/to/data/e.yml',
      'path/to/data/f.yml'
    ]
    @b.check_files
    expect(@b.directories_to_build(known_files)).to eq %w[a c]
  end

  it 'returns true if a data object has posts' do
    data = { 'posts' => { a: 'hello', b: 'world' } }
    expect(@b.check_for_posts(data)).to be true
  end

  it 'returns false if a data object has no posts' do
    data = { a: 'hello', b: 'world' }
    expect(@b.check_for_posts(data)).to be false
  end

  it 'returns true if the data object conforms to the template' do
    match = @b.match_data_to_template(@test_template, @test_data)
    expect(match).to be true
  end

  it 'returns false if the data object does not conform to the template' do
    match = @b.match_data_to_template(@test_template, @test_data_bad)
    expect(match).to be false
  end

  it 'merges data into a template' do
    merge = @b.merge_data_to_template(@test_template, @test_data)
    expect(merge).to eq [@stub_output_1, @stub_output_2]
  end
end

describe 'Production env validations' do
  it 'checks for the existence of required files' do
    @b = Builder.new
    expect(@b.check_files).to be true
  end
end

describe 'HTML file operations' do
  it 'returns the correct file slug for a file in the pictures dir' do
    @b = Builder.new
    expect(@b.file_slug('snow-day.html', 'pictures')).to eq 'pictures-snow-day'
  end

  it 'returns the correct file slug for a file in another dir' do
    @b = Builder.new
    expect(@b.file_slug('zoom-meetings.html', 'words')).to eq 'zoom-meetings'
  end
end
