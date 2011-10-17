require 'spec_helper'

describe "pay_methods/show.html.haml" do
  before(:each) do
    @pay_method = assign(:pay_method, stub_model(PayMethod,
      :pay_method => "Pay Method"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Pay Method/)
  end
end
