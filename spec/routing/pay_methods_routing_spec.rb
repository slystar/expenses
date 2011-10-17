require "spec_helper"

describe PayMethodsController do
  describe "routing" do

    it "routes to #index" do
      get("/pay_methods").should route_to("pay_methods#index")
    end

    it "routes to #new" do
      get("/pay_methods/new").should route_to("pay_methods#new")
    end

    it "routes to #show" do
      get("/pay_methods/1").should route_to("pay_methods#show", :id => "1")
    end

    it "routes to #edit" do
      get("/pay_methods/1/edit").should route_to("pay_methods#edit", :id => "1")
    end

    it "routes to #create" do
      post("/pay_methods").should route_to("pay_methods#create")
    end

    it "routes to #update" do
      put("/pay_methods/1").should route_to("pay_methods#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/pay_methods/1").should route_to("pay_methods#destroy", :id => "1")
    end

  end
end
