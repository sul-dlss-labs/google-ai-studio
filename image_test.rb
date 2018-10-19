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
require 'pp'

project_id = "sul-ai-studio" # Your Google Cloud Platform project ID

puts "Enter druid (no prefix):"
druid = gets.chomp

iiif_manifest_url = "https://purl.stanford.edu/#{druid}/iiif/manifest"

puts iiif_manifest_url
puts

client = IiifGoogleCv::Client.new(manifest_url: iiif_manifest_url)
images = client.image_resources

begin
  # Instantiates a client
  vision = Google::Cloud::Vision.new project: project_id

  images.each do |image|
    # Performs label detection on the image file
    results = vision.image(image)

    puts "Labels for #{image}:"
    results.labels.each do |label|
      puts "#{label.description} : #{label.score.round(2)}"
    end
    puts

    puts "Web entities for #{image}:"
    results.web.entities.each do |entity|
      puts "#{entity.description} : #{entity.score.round(2)}"
    end
    puts

  end

rescue Google::Cloud::InvalidArgumentError => e

  puts "ERROR"
  puts "Google returned an error! (\"#{e.message}\".   Its likely this image is restricted in some way (either not viewable at all or only as a thumbnail)"

rescue StandardError => e

  puts "ERROR"
  puts "Something bad happened and we don't know what. This might help: \"#{e.message}\"."

end
