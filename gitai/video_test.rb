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
