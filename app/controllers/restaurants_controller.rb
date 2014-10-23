class RestaurantsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def index
    respond_with restaurants.order( rating: :desc )
  end

  def pick
    respond_with picked_restaurant
  end

  def create
    respond_with restaurants.create( restaurant_params )
  end
  
  def update
    if restaurant_params.key?( "rating" ) && restaurant_params[:rating] != restaurant.rating
      params[:rating_count] = restaurant.rating_count + 1
    end
    respond_with restaurant.update( restaurant_params )
  end

  def destroy
    respond_with restaurant.destroy
  end

  private

  def restaurants
    @restaurants ||= Restaurant.all
  end

  def restaurant
    @restaurant ||= restaurants.find(params[:id])
  end
  
  def picked_restaurant
    @picked_restaurants ||= restaurants.where( "last_visit < ?", [ DateTime.yesterday ] ).order( rating: :desc, last_visit: :asc ).first
    @picked_restaurants ||= restaurants.order( rating: :desc, last_visit: :asc ).first
  end

  def restaurant_params
    params.permit( :name, :rating, :last_visit, :rating_count )
  end
  
end
