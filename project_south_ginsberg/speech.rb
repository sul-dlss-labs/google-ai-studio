# Using the Google Cloud Speech to Text API for Project South and Ginsberg audio.
# Fetches a list of audio files from the specified google cloud bucket and runs
# the google cloud speech to text.
# https://cloud.google.com/speech-to-text

# setup:
# `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`
# You can get the service account file from the Google Cloud Platform Dashboard:
#    API & Services --> Credentials --> "Manage Service Accounts" under "Service Account Keys" -->
#       edit the key for "speech-to-text" --> "CREATE KEY" --> Download the JSON version
# gem install google-cloud-speech
# gem install google-cloud-storage
# Put audio files in project_south bucket in FLAC format (or set different bucket name below)
# ensure the bucket is accessible to the speech-to-text service account

# run with `ruby project_south_ginsberg/speech.rb`

# the bucket name to look for files in
bucket_name = "audio_ua"

# optionally skip the following files in the bucket, set an empty array to include all files
# (useful if you are running multiple times and have already completed some)
skip = %w(bb169jj6514_sh gv425rr3983_b_sh)

require "google/cloud/speech"
require "google/cloud/storage"
require "fileutils"

storage = Google::Cloud::Storage.new project_id: "sul-ai-studio"
bucket  = storage.bucket bucket_name
speech = Google::Cloud::Speech.new
config = {
          encoding:          :FLAC,
          language_code:     "en-US",
          enable_automatic_punctuation: true,
          enable_word_time_offsets: true
         }
storage_paths = []

raise "no files found in #{bucket_name}" if bucket.files.size == 0

bucket.files.each do |file|
  storage_paths << "gs://#{bucket_name}/#{file.name}"
end

total = storage_paths.count
success_count = 0
error_count = 0
skipped_count = 0
start_time = Time.now

puts "Speech to text started at #{start_time}"

puts "Found #{total} files in #{bucket_name}"

storage_paths.each_with_index do |path, n|

  puts ""
  puts "[#{n + 1} of #{total}] : #{Time.now} : Working on #{path}"
  file_name = /[^\/]+$/.match(path).to_s.split(".")[0]

  if skip.include? file_name
    puts "SKIPPING #{file_name}"
    next
  end

  audio  = { uri: path }
  dirname = File.join("./output/#{file_name}")
  FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

  begin

    # [START speech_transcribe_async_gcs]
    operation = speech.long_running_recognize config, audio
    puts "*** operation started"

    operation.wait_until_done!

    raise operation.results.message if operation.error?
    puts "*** operation completed"

    results = operation.response.results
    # [END speech_transcribe_async_gcs]

    our_transcription_array = []

    results.each_with_index do |result, i|
      result.alternatives.each { |alternative| our_transcription_array << alternative.transcript }
      File.open("#{File.join(dirname,file_name)}_#{i}.json", "w+") { |f| f.puts(result.to_json) }
    end

    File.open("#{File.join(dirname,file_name)}.txt", "w+") { |f| our_transcription_array.each { |element| f.puts(element) } }

    success_count += 1

  rescue StandardError => e

    puts "**** error occurred: #{e.message}"
    error_count += 1

  end

end

end_time = Time.now
puts ""
puts "Speech to text completed at #{end_time}, ~#{((end_time - start_time)/60).ceil} minutes"
puts "Total = #{total}, success = #{success_count}, error = #{error_count}, skipped = #{skipped_count}"
