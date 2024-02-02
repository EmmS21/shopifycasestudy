require 'faker'

loop do
    item = Item.new(
        name: Faker::Commerce.product_name,
        description: Faker::Lorem.sentence
    )
    if item.save
        puts "Item created: #{item.name}"
    else
        puts "Error creating item: #{item.errors.full_messages.join(', ')}"
    end
    sleep 1
end