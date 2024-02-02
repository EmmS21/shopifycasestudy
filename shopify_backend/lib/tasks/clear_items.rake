# lib/tasks/clear_items.rake

namespace :db do
    desc 'Clear all items from the database'
    task :clear_items => :environment do
      Item.delete_all
      puts 'All items deleted from the database.'
    end
  end
  