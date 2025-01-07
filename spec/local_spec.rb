# frozen_string_literal: true

require_relative '../build/lib/local'
require 'tempfile'

describe 'Stylesheet commenting for local dev' do
  let(:temp_file) { Tempfile.new('test_file') }
  let(:uncommented_file) { File.read('spec/support/local_dev_test_file.html') }
  let(:commented_file) { File.read('spec/support/local_dev_test_file2.html') }

  before(:each) do
    @loc = Local.new
  end

  after do
    temp_file.close
    temp_file.unlink
  end

  context 'when commenting out lines' do
    it 'wraps lines with comments' do
      temp_file.write(uncommented_file)
      temp_file.rewind
      @loc.comment(temp_file.path)
      content = File.read(temp_file.path).chomp
      expect(content).to eq commented_file
    end
  end

  context 'when uncommenting lines' do
    it 'removes the comment wrapping' do
      temp_file.write(commented_file)
      temp_file.rewind
      @loc.uncomment(temp_file.path)
      content = File.read(temp_file.path).chomp
      expect(content).to eq uncommented_file
    end
  end
end
