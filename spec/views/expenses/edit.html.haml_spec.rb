require 'spec_helper'

describe "expenses/edit.html.haml" do
  before(:each) do
    @expense = assign(:expense, stub_model(Expense,
      :expense => "MyString"
    ))
  end

  it "renders the edit expense form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => expenses_path(@expense), :method => "post" do
      assert_select "input#expense_expense", :name => "expense[expense]"
    end
  end
end
