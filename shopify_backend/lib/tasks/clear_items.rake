# lib/tasks/clear_items.rake

namespace :db do
  desc 'Clear all items from the database'
  task :clear_items => :environment do
    # Clear the database
    Item.delete_all
    
    # Clear the LRU cache
    LruCacheManager.cache.clear

    puts 'All items deleted from the database.'
  end
end
