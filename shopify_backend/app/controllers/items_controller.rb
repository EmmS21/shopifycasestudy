# app/controllers/items_controller.rb
require 'lru_cache_manager'

class ItemsController < ApplicationController
  before_action :set_cache_key, only: [:index]
  before_action :set_item_cache_key, only: [:create, :update, :destroy]
  
  def index
    items = LruCacheManager.cache[cache_key]
    
    if items.nil?
      items = Item.where(category: params[:category]).to_a
      LruCacheManager.cache[cache_key] = items
    end
    
    render json: items
  end

  def create
    item = Item.new(item_params)
    if item.save
      # Invalidate the cache for the current category
      LruCacheManager.cache.delete(cache_key)
      
      # Additionally, invalidate the cache for the 'items' key to refresh the entire list
      LruCacheManager.cache.delete('items')
      
      render json: item, status: :created
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end
  

  def update
    item = Item.find(params[:id])
    if item.update(item_params)
      LruCacheManager.cache.delete(cache_key)
      render json: item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    item = Item.find(params[:id])
    if item.destroy
      LruCacheManager.cache.delete(cache_key)
      head :no_content
    else
      render json: { error: "Item could not be deleted" }, status: :unprocessable_entity
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :category)
  end

  def set_cache_key
    @cache_key = "items/#{params[:category]}/all"
  end

  def set_item_cache_key
    @item_cache_key = "items/#{params[:category]}/all"
  end

  def cache_key
    @@lru_cache_key ||= "items/#{params[:category]}/all"
  end
end
