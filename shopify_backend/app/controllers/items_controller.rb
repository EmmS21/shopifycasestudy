class ItemsController < ApplicationController
    def index
        cache_key = "items/all"
        items = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
            Item.all.to_a
        end
        render json: items
    end
    #   items = Item.all
    #   render json: items
    # end
  
    def create
      item = Item.new(item_params)
      if item.save
        Rails.cache.delete("items/all")
        render json: item, status: :created
        # render json: item, status: :created
      else
        render json: item.errors, status: :unprocessable_entity
      end
    end
  
    def update
      item = Item.find(params[:id])
      if item.update(item_params)
        Rails.cache.delete("items/all")
        render json: item
      else
        render json: item.errors, status: :unprocessable_entity
      end
    end
  
    def destroy
      item = Item.find(params[:id])
      if item.destroy
        Rails.cache.delete("items/all")
        head :no_content
      else
        render json: { error: "Item could not be deleted" }, status: :unprocessable_entity
      end
    end
  
    private
  
    def item_params
      params.require(:item).permit(:name, :description)
    end
  end
  