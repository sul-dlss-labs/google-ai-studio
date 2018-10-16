# Plug in a druid, fetch the IIIF manifest, find the images, print the labels via Google Cloud Vision API
# https://cloud.google.com/vision/

# Setup:
# gem install faraday
# gem install iiif_google_cv
# gem install google-cloud   # see https://github.com/googleapis/google-cloud-ruby

# You then need to have a valid .json service acccount key as described here:
# see https://cloud.google.com/vision/docs/quickstart?authuser=1
# and you need to set the "GOOGLE_APPLICATION_CREDENTIALS" environment file with the location of this json file

# NOTE: Only works with unrestricted public images on PURL pages

require 'json'
require 'faraday'
require 'google/cloud/vision'
require 'iiif_google_cv'

project_id = "sul-ai-studio" # Your Google Cloud Platform project ID

puts "Enter druid (no prefix):"
druid = gets.chomp

iiif_manifest_url = "https://purl.stanford.edu/#{druid}/iiif/manifest"

puts iiif_manifest_url
puts

client = IiifGoogleCv::Client.new(manifest_url: iiif_manifest_url)
images = client.image_resources

# Instantiates a client
vision = Google::Cloud::Vision.new project: project_id

images.each do |image|
  # Performs label detection on the image file
  labels = vision.image(image).labels

  puts "Labels for #{image}:"
  labels.each do |label|
    puts label.description
  end
  puts

end
