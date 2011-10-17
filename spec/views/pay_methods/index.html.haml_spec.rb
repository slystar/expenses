require 'spec_helper'

describe "pay_methods/index.html.haml" do
  before(:each) do
    assign(:pay_methods, [
      stub_model(PayMethod,
        :pay_method => "Pay Method"
      ),
      stub_model(PayMethod,
        :pay_method => "Pay Method"
      )
    ])
  end

  it "renders a list of pay_methods" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Pay Method".to_s, :count => 2
  end
end
