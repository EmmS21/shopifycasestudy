class ItemsController < ApplicationController
  before_action :set_cache_key, only: [:index]
  before_action :set_item_cache_key, only: [:create, :update, :destroy]
  
  def index
    items = Rails.cache.fetch(@cache_key, expires_in: 5.minutes) do
      Item.where(category: params[:category]).to_a
    end
    render json: items
  end

  def create
    item = Item.new(item_params)
    if item.save
      Rails.cache.delete(@item_cache_key) 
      render json: item, status: :created
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  def update
    item = Item.find(params[:id])
    if item.update(item_params)
      Rails.cache.delete(@item_cache_key) # Invalidate cache for specific category
      render json: item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    item = Item.find(params[:id])
    if item.destroy
      Rails.cache.delete(@item_cache_key) # Invalidate cache for specific category
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
    # Use a cache key that includes the category parameter
    @cache_key = "items/#{params[:category]}/all"
  end

  def set_item_cache_key
    # Use a cache key that includes the category parameter
    @item_cache_key = "items/#{params[:category]}/all"
  end
end
