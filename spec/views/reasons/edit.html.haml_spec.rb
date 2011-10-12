require 'spec_helper'

describe "reasons/edit.html.haml" do
  before(:each) do
    @reason = assign(:reason, stub_model(Reason,
      :reason => "MyString"
    ))
  end

  it "renders the edit reason form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => reasons_path(@reason), :method => "post" do
      assert_select "input#reason_reason", :name => "reason[reason]"
    end
  end
end
