# Using the Google Cloud Speech to Text API for Project South and Ginsberg audio.
# Fetches a list of audio files from the specified google cloud bucket and runs
# the google cloud speech to text.
# https://cloud.google.com/speech-to-text

# setup:
# export `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`
# gem install google-cloud-speech
# gem install google-cloud-storage

# Right now audio files must be in the project_south google cloud bucket
require "google/cloud/speech"
require "google/cloud/storage"

storage = Google::Cloud::Storage.new project_id: "sul-ai-studio"
bucket  = storage.bucket "project_south"
speech = Google::Cloud::Speech.new
config = { 
          encoding:          :FLAC,
          language_code:     "en-US",
          enable_automatic_punctuation: true
         }
storage_paths = []
bucket.files.each do |file|
  storage_paths << "gs://project_south/#{file.name}"
end

storage_paths.each do |path|
  file_name = /[^\/]+$/.match(path).to_s.split(".")[0]
  audio  = { uri: path }
  # [START speech_transcribe_async_gcs]
  operation = speech.long_running_recognize config, audio
  puts "Operation started"

  operation.wait_until_done!

  raise operation.results.message if operation.error?

  results = operation.response.results
  # [END speech_transcribe_async_gcs]

  our_transcription_array = []

  results.each do |result|
    result.alternatives.each do |alternative|
      our_transcription_array << alternative.transcript
    end
  end


  File.open(file_name + ".txt", "w+") do |f|
    our_transcription_array.each { |element| f.puts(element) }
  end
end
