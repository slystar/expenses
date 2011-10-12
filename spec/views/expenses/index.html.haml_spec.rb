require 'spec_helper'

describe "expenses/index.html.haml" do
  before(:each) do
    assign(:expenses, [
      stub_model(Expense,
        :expense => "Expense"
      ),
      stub_model(Expense,
        :expense => "Expense"
      )
    ])
  end

  it "renders a list of expenses" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Expense".to_s, :count => 2
  end
end
