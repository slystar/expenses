require 'spec_helper'

describe "expenses/show.html.haml" do
  before(:each) do
    @expense = assign(:expense, stub_model(Expense,
      :expense => "Expense"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Expense/)
  end
end
