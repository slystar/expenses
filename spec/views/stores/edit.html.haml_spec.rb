require 'spec_helper'

describe "stores/edit.html.haml" do
  before(:each) do
    @store = assign(:store, stub_model(Store,
      :store => "MyString"
    ))
  end

  it "renders the edit store form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => stores_path(@store), :method => "post" do
      assert_select "input#store_store", :name => "store[store]"
    end
  end
end
