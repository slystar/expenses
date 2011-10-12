require 'spec_helper'

describe "reasons/show.html.haml" do
  before(:each) do
    @reason = assign(:reason, stub_model(Reason,
      :reason => "Reason"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Reason/)
  end
end
