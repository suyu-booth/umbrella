# /env_test.rb
require "http"
require "json"
require "dotenv/load"

# pp ENV.fetch("GMAPS_KEY")
# pp ENV.fetch("OPENAI_KEY")

s = gets.chomp


gmap_resp = HTTP
  .follow(strict: false)
  .get(
    "https://maps.googleapis.com/maps/api/geocode/json",
    {
      :params => {
        "address" => s,
        "key" => ENV.fetch("GMAPS_KEY"),
      },
      :form => {
      },
    }
  )

gmap_hash = JSON.parse(gmap_resp.to_s)
gps = gmap_hash["results"][0]['geometry']['location']

pw_resp = HTTP
.follow(strict: false)
.get(
  "https://api.pirateweather.net/forecast/#{ENV.fetch("PRIVATE_WEATHER_KEY")}/#{gps['lat']},#{gps['lng']}",
)
pw_hash = JSON.parse(pw_resp.to_s)
pp "Current temperature at #{s} is #{pw_hash['currently']['temperature'].to_i} degree F"
pp "Weather at #{s} in the next hour is #{pw_hash['hourly']['data'][1]['summary']}"

ub = false
1.upto(12) do |counter|
  prep_prob = pw_hash['hourly']['data'][counter]['precipProbability']
  if prep_prob>0.1
    pp "#{counter} hours from now, the precipitation probability is #{prep_prob}"
    ub = true
  end 
end
if ub
  pp "You might want to carry an umbrella!"
else pp "You probably won’t need an umbrella today."
end 
