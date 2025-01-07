# frozen_string_literal: true

require_relative '../build/lib/config'
require 'pathname'

describe 'Config verification' do
  before(:all) do
    abs_path = File.expand_path(__FILE__)
    @path = Pathname.new(abs_path).ascend do |dir|
      break dir if dir.basename.to_s == EXECUTION_DIR
    end
    @build_dir = "#{@path}/#{BUILD_DIR}"
  end

  it 'ensures build/site directory exists' do
    expect(File.exist?(@build_dir)).to be true
  end

  it 'ensures file parts exist' do
    PAGE_PARTS.each_value do |page_part|
      full_path = "#{@path}/#{page_part}"
      expect(File.file?(full_path)).to eq(true), "File missing: #{full_path}"
    end
  end

  it 'ensures asset directories exist' do
    ASSET_TYPES.each_key do |asset_type|
      full_path = "#{@path}/#{S3_ASSETS_DIR}/#{asset_type}"
      expect(File.exist?(full_path)).to eq(true), "Dir missing: #{full_path}"
    end
  end

  it 'ensures required template and data files exist' do
    REQUIRED_DIRECTORIES.each do |dir, ext|
      REQUIRED_FILES.each do |file|
        full_path = "#{@path}/#{dir}/#{file}.#{ext}"
        expect(File.file?(full_path)).to eq(true), "File missing: #{full_path}"
      end
    end
  end

  it 'ensures root pages exist' do
    ROOT_PAGES.each do |page|
      full_path = "#{@path}/root-pages/#{page}"
      expect(File.file?(full_path)).to eq(true), "File missing: #{full_path}"
    end
  end

  it 'returns false for a directory path without local dirs' do
    expect(local?('/path/to/Code/modjeska.us')).to be false
  end

  it 'returns true for a directory path with local dirs' do
    expect(local?('/path/to/Dropbox/Code/modjeska.us/build')).to be true
  end
end
