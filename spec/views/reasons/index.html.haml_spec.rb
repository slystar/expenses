require 'spec_helper'

describe "reasons/index.html.haml" do
  before(:each) do
    assign(:reasons, [
      stub_model(Reason,
        :reason => "Reason"
      ),
      stub_model(Reason,
        :reason => "Reason"
      )
    ])
  end

  it "renders a list of reasons" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Reason".to_s, :count => 2
  end
end
