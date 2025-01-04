# frozen_string_literal: true

require_relative 'lib/config'
require 'aws-sdk-s3'

current_dir = File.basename(Dir.getwd)
check_dir(current_dir)

@s3 = Aws::S3::Client.new(region: 'us-west-2')

puts '-=> Build step: copy assets to s3'

def upload_file_to_s3(object_key, file, content_type)
  begin
    @s3.put_object(
      bucket: S3_BUCKET,
      key: object_key,
      body: File.open(file, 'rb'),
      acl: 'public-read',
      content_type: content_type
    )
  rescue Aws::S3::Errors::ServiceError => e
    return "\n#{e.message}"
  end
  return "OK\n"
end

s3_asset_files.each do |file|
  type = get_file_type(file)
  content_type = CONTENT_TYPES[type]
  object_key = "#{type}/#{file}"
  file_path = "#{S3_ASSETS_DIR}/#{object_key}"
  print "-   Putting #{S3_BUCKET}/#{object_key} as #{content_type} ... "
  print upload_file_to_s3(object_key, file_path, content_type)
end
