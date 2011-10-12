require 'spec_helper'

describe "stores/new.html.haml" do
  before(:each) do
    assign(:store, stub_model(Store,
      :store => "MyString"
    ).as_new_record)
  end

  it "renders new store form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => stores_path, :method => "post" do
      assert_select "input#store_store", :name => "store[store]"
    end
  end
end
