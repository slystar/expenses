require 'spec_helper'

describe "Stores" do
  describe "GET /stores" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get stores_path
      response.status.should be(200)
    end
    it "it should create a store" do
      visit "/stores"
      page.should have_content("New Store")
      click_on 'New Store'
    end
  end
end
