require 'spec_helper'

describe "pay_methods/new.html.haml" do
  before(:each) do
    assign(:pay_method, stub_model(PayMethod,
      :pay_method => "MyString"
    ).as_new_record)
  end

  it "renders new pay_method form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => pay_methods_path, :method => "post" do
      assert_select "input#pay_method_pay_method", :name => "pay_method[pay_method]"
    end
  end
end
