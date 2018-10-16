# Experiments in using the Google Cloud Video Intelligence API for Gitai videos
#  Fetches a video from a google cloud bucket and submits to the Video Intelligence API, prints out labels and scence changes
# https://cloud.google.com/video-intelligence

# setup:
# gem install google-cloud   # see https://github.com/googleapis/google-cloud-ruby

# You also need to have a valid .json service acccount key as described here:
# see https://cloud.google.com/video-intelligence/docs/quickstart?authuser=1
# and you need to set the "GOOGLE_APPLICATION_CREDENTIALS" environment file with the location of this json file

# NOTE: The video needs to be in the gitai bucket in the sul-ai-studio project and needs to be public ("allUsers" --> Reader)

# TODO: figure out how to authenticate to videos that are not in google cloud and/or that are not set to be public
# TODO: figure out a better way of manging authorization to the google API without the use of local environment variables
#             (e.g. perhaps via a shared config setting somewhere)

puts "Enter filename to process:"
filename = gets.chomp

input_uri = "gs://gitai/#{filename}"

require "google/cloud/video_intelligence"
require "pp"
start_time = Time.now

puts
puts "Working on #{input_uri}..."

video_intelligence_service_client = Google::Cloud::VideoIntelligence.new
features = [:LABEL_DETECTION,:SHOT_CHANGE_DETECTION]
# Register a callback during the method call.
operation = video_intelligence_service_client.annotate_video(input_uri: input_uri, features: features) do |op|
  raise op.results.message if op.error?
  op_results = op.results
  # Process the results.

  metadata = op.metadata
  # Process the metadata.
end
operation.wait_until_done!

puts
puts "Labels:"

operation.results.annotation_results[0].shot_label_annotations.each do |annotation|
  puts annotation.entity.description
  annotation.segments.each do |s|
    puts "...#{s.segment.start_time_offset.seconds} - #{s.segment.end_time_offset.seconds} seconds"
  end
end

puts
puts "Scenes:"

operation.results.annotation_results[0].shot_annotations.each do |s|
  puts "#{s.start_time_offset.seconds} - #{s.end_time_offset.seconds} seconds"
end

end_time = Time.now

puts
puts "Analysis took #{((end_time - start_time)/60.0).round(2)} minutes"
