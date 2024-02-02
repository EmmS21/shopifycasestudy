require 'net/http'
require 'json'

loop do
    response = Net::HTTP.get_response(URI.parse('http://127.0.0.1:3000/items'))
    if response.code == '200'
        items = JSON.parse(response.body)
        puts "Fetched #{items.length} items"
    else
        puts "Error fetching items: #{response.code}"
    end
    sleep 1
end 