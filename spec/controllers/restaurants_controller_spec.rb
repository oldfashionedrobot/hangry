require 'rails_helper'

RSpec.describe RestaurantsController, :type => :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe "GET pick" do
    it "chooses the restaurant whose last visit was the longest time ago" do
      rest1 = Restaurant.create!( name: "Resto", rating: 5, last_visit: Date.today - 7.days )
      rest2 = Restaurant.create!( name: "RestoTwo", rating: 1, last_visit: Date.today - 2.days )
      get :pick
      
      json = JSON.parse( response.body );
      expect( json["id"] ).to eq( rest1.id )
    end
    
    it "doesn't choose a restaurant that was visited yesterday" do
      rest1 = Restaurant.create!( name: "Resto", rating: 5, last_visit: Date.yesterday )
      rest2 = Restaurant.create!( name: "RestoTwo", rating: 1, last_visit: Date.today - 5.days )
      get :pick
      
      json = JSON.parse( response.body );
      expect( json["id"] ).to eq( rest2.id )
    end
    
    it "will choose a restaurant visited yesterday if there is nothing else" do
      rest1 = Restaurant.create!( name: "Resto", rating: 5, last_visit: Date.yesterday )
      rest2 = Restaurant.create!( name: "RestoTwo", rating: 1, last_visit: Date.yesterday )
      get :pick
      
      json = JSON.parse( response.body );
      expect( json["id"] ).to eq( rest1.id )
    end
    
    it "chooses the restaurant with the highest rating" do
      rest1 = Restaurant.create!( name: "Resto", rating: 5, last_visit: Date.today - 4.days )
      rest2 = Restaurant.create!( name: "RestoTwo", rating: 1, last_visit: Date.today - 4.days )
      get :pick
      
      json = JSON.parse( response.body );
      expect( json["id"] ).to eq( rest1.id )
    end
  end
  
  describe "GET index" do 
    it "returns all restaurants" do
      rest1 = Restaurant.create!( name: "Resto", rating: 5, last_visit: Date.yesterday )
      rest2 = Restaurant.create!( name: "RestoTwo", rating: 1, last_visit: Date.yesterday )
      get :index
      
      json = JSON.parse( response.body );
      expect( json.count ).to eq( Restaurant.count )
    end
    
    it "sorts by rating" do
      rest1 = Restaurant.create!( name: "Resto", rating: 5, last_visit: Date.yesterday )
      rest2 = Restaurant.create!( name: "RestoTwo", rating: 1, last_visit: Date.yesterday )
      get :index
      
      json = JSON.parse( response.body );
      expect( json[0]["id"] ).to eq( rest1.id )
    end
  end
  
  describe "POST create" do
    it "creates a new restaurant" do
      expect {
        post :create, name: "Testo", rating: 3
      }.to change {
        Restaurant.count
      }
      
      json = JSON.parse( response.body );
      expect( json["name"] ).to eq( "Testo" )
    end
  end
  
  describe "PUT update" do 
    it "updates specified params" do
      resto = Restaurant.create!( name: "Resto", rating: 5, last_visit: Date.yesterday )
      put :update, id: resto.id, name: "NewName", last_visit: Date.today, rating: 3
      
      resto2 = Restaurant.find( resto.id )
      
      expect( resto2.name ).to eq( "NewName" )
      expect( resto2.last_visit ).to eq( Date.today )
      expect( resto2.rating ).to eq( 3 )
    end
  end
  
  describe "DELETE destroy" do
    it "destroys the specified restaurant" do
      resto = Restaurant.create!( name: "Resto", rating: 5, last_visit: Date.yesterday )
      delete :destroy, id: resto.id
      
      expect( Restaurant.where( id: resto.id ).exists? ).to eq( false )
    end
  end

end
