# lib/tasks/high_load_simulation.rake

namespace :high_load do
    desc 'Run high load simulation for reads, writes, and updates'
    task :simulate => :environment do
      require 'faker'
      require 'benchmark'
      require 'net/http'
      require 'json'
  
      # Define the endpoint URLs
      read_endpoint = URI.parse('http://127.0.0.1:3000/items')
      write_endpoint = URI.parse('http://127.0.0.1:3000/write_items')
  
    # Track metrics
      combined_latencies = [] # Store latencies for all actions combined
      read_error_count = 0
      write_error_count = 0
      update_error_count = 0
      database_query_times = []
      cache_hits = 0 # Initialize cache hit count
      cache_misses = 0 # Initialize cache miss count
      cache_evictions = 0 # Initialize cache eviction count
      iterations = 1000
  
      # Set the maximum number of retries
      max_retries = 2
  
      # Run for 10 minutes (600 seconds)
      end_time = Time.now + 10 * 60
  
      while Time.now < end_time
        remaining_time = (end_time - Time.now).to_i
        minutes_left = remaining_time / 60
        puts "Time left: #{minutes_left} minutes"
  
        # High Load Reads (X200)
        iterations.times do
          retry_count = 0
          success = false
  
          until success || retry_count >= max_retries
            begin
              combined_latency = Benchmark.realtime do # Measure combined latency
                http = Net::HTTP.new(read_endpoint.host, read_endpoint.port)
                http.read_timeout = 120 # Set a timeout of 60 seconds
  
                response = http.get(read_endpoint.request_uri)
                if response.code == '200'
                  items = JSON.parse(response.body)
                  # Log the number of fetched items
                  puts "Fetched #{items.length} items"
                  success = true
                  cache_hits += 1
                else
                  read_error_count += 1
                  puts "Error fetching items: #{response.code}"
                  cache_misses += 1
                end
              end
            rescue Net::ReadTimeout
              retry_count += 1
              puts "Read request timed out. Retrying (Attempt #{retry_count}/#{max_retries})..."
              sleep(2) # Add a delay before retrying
            end
          end
  
          if !success
            puts "Read request failed after #{max_retries} attempts. Skipping..."
          end
  
          combined_latencies << combined_latency # Store combined latency for reads
        end
  
        # High Load Writes (X200)
        iterations.times do
          retry_count = 0
          success = false
  
          until success || retry_count >= max_retries
            begin
              combined_latency = Benchmark.realtime do # Measure combined latency
                http = Net::HTTP.new(write_endpoint.host, write_endpoint.port)
                http.read_timeout = 60 # Set a timeout of 60 seconds
  
                item = Item.new(
                  name: Faker::Commerce.product_name,
                  description: Faker::Lorem.sentence,
                  price: Faker::Commerce.price(range: 0..100.0)
                )
  
                if item.save
                  # Log the name of the created item
                  puts "Item created: #{item.name}"
                  success = true
                  cache_evictions += 1
                else
                  write_error_count += 1
                  puts "Error creating item: #{item.errors.full_messages.join(', ')}"
                end
              end
            rescue Net::ReadTimeout
              retry_count += 1
              puts "Write request timed out. Retrying (Attempt #{retry_count}/#{max_retries})..."
              sleep(2) # Add a delay before retrying
            end
          end
  
          if !success
            puts "Write request failed after #{max_retries} attempts. Skipping..."
          end
  
          combined_latencies << combined_latency # Store combined latency for writes
        end
  
        # High Load Updates (X200)
        iterations.times do
          retry_count = 0
          success = false
  
          until success || retry_count >= max_retries
            begin
              combined_latency = Benchmark.realtime do # Measure combined latency
                random_item = Item.offset(rand(Item.count)).first
                if random_item.update(
                  name: Faker::Commerce.product_name,
                  description: Faker::Lorem.sentence,
                  price: Faker::Commerce.price(range: 0..100.0)
                )
                  # Log the updated item
                  puts "Item updated: #{random_item.name}"
                  success = true
                  cache_evictions += 1
                else
                  update_error_count += 1
                  puts "Error updating item: #{random_item.errors.full_messages.join(', ')}"
                end
              end
            rescue Net::ReadTimeout
              retry_count += 1
              puts "Update request timed out. Retrying (Attempt #{retry_count}/#{max_retries})..."
              sleep(2) # Add a delay before retrying
            end
          end
  
          if !success
            puts "Update request failed after #{max_retries} attempts. Skipping..."
          end
  
          combined_latencies << combined_latency # Store combined latency for updates
        end
  
        # Measure and log database query execution time
        query_time = Benchmark.realtime do
          # Simulate a database query (replace with your actual query)
          Item.first
        end
        database_query_times << query_time
  
        sleep 1
      end
  
      # Calculate and print combined metrics for High Load Reads, Writes, and Updates
      average_combined_latency = combined_latencies.reduce(:+) / combined_latencies.length
      total_errors = read_error_count + write_error_count + update_error_count
  
      # Calculate and print the average database query execution time
      average_query_time = database_query_times.reduce(:+) / database_query_times.length

      # Calculate and print cache metrics
      total_requests = iterations * 3 # Total read, write, and update requests
      cache_hit_rate = (cache_hits.to_f / total_requests) * 100
      cache_miss_rate = (cache_misses.to_f / total_requests) * 100
      cache_eviction_rate = (cache_evictions.to_f / total_requests) * 100

  
      puts "Combined High Load Metrics:"
      puts "  Average Combined Latency: #{average_combined_latency} seconds" # Average latency for all actions combined
      puts "  Total Errors: #{total_errors}"
      puts "  Average Database Query Time: #{average_query_time} seconds"
      puts "Cache Metrics:"
      puts "  Cache Hit Rate: #{cache_hit_rate}%"
      puts "  Cache Miss Rate: #{cache_miss_rate}%"
      puts "  Cache Eviction Rate: #{cache_eviction_rate}%"  
    end
  end
