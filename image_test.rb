# TODO use this gem instead: https://github.com/mejackreed/iiif_google_cv

require 'json'
require 'faraday'
require 'google/cloud/vision'

project_id = "sul-ai-studio" # Your Google Cloud Platform project ID

puts "Enter druid:"
druid = gets.chomp

iiif_manifest_url = "https://purl.stanford.edu/#{druid}/iiif/manifest"
response = Faraday.get iiif_manifest_url

json_manifest = JSON.parse(response.body)

images = json_manifest["sequences"].map { |seq| seq["canvases"].first["images"].first["resource"]["@id"] }

# Instantiates a client
vision = Google::Cloud::Vision.new project: project_id

images.each do |image|
  # Performs label detection on the image file
  labels = vision.image(image).labels

  puts "Labels for #{image}:"
  labels.each do |label|
    puts label.description
  end
end
