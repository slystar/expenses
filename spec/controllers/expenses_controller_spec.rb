require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ExpensesController do
    before(:each) do
	@attr=get_attr_expense
	# Login a user
	@new_user_id=0
	user=get_next_user
	request.session[:user_id] = user.id
    end

  # This should return the minimal set of attributes required to create a valid
  # Expense. As you add validations to Expense, be sure to
  # update the return value of this method accordingly.
    def valid_attributes
	@attr
    end

  describe "GET index" do
    it "assigns all expenses as @expenses" do
      expense = Expense.create! valid_attributes
      get :index
      assigns(:expenses).should eq([expense])
    end
  end

  describe "GET show" do
    it "assigns the requested expense as @expense" do
      expense = Expense.create! valid_attributes
      get :show, :id => expense.id.to_s
      assigns(:expense).should eq(expense)
    end
  end

  describe "GET new" do
    it "assigns a new expense as @expense" do
      get :new
      assigns(:expense).should be_a_new(Expense)
    end
  end

  describe "GET edit" do
    it "assigns the requested expense as @expense" do
      expense = Expense.create! valid_attributes
      get :edit, :id => expense.id.to_s
      assigns(:expense).should eq(expense)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Expense" do
        expect {
          post :create, :expense => valid_attributes
        }.to change(Expense, :count).by(1)
      end

      it "assigns a newly created expense as @expense" do
        post :create, :expense => valid_attributes
        assigns(:expense).should be_a(Expense)
        assigns(:expense).should be_persisted
      end

      it "redirects to the created expense" do
        post :create, :expense => valid_attributes
	response.should redirect_to("#{expenses_path}/new")
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved expense as @expense" do
        # Trigger the behavior that occurs when invalid params are submitted
        Expense.any_instance.stub(:save).and_return(false)
        post :create, :expense => {}
        assigns(:expense).should be_a_new(Expense)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Expense.any_instance.stub(:save).and_return(false)
        post :create, :expense => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested expense" do
        expense = Expense.create! valid_attributes
        # Assuming there are no other expenses in the database, this
        # specifies that the Expense created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Expense.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => expense.id, :expense => {'these' => 'params'}
      end

      it "assigns the requested expense as @expense" do
        expense = Expense.create! valid_attributes
        put :update, :id => expense.id, :expense => valid_attributes
        assigns(:expense).should eq(expense)
      end

      it "redirects to the expense" do
        expense = Expense.create! valid_attributes
        put :update, :id => expense.id, :expense => valid_attributes
        response.should redirect_to(expense)
      end
    end

    describe "with invalid params" do
      it "assigns the expense as @expense" do
        expense = Expense.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Expense.any_instance.stub(:save).and_return(false)
        put :update, :id => expense.id.to_s, :expense => {}
        assigns(:expense).should eq(expense)
      end

      it "re-renders the 'edit' template" do
        expense = Expense.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Expense.any_instance.stub(:save).and_return(false)
        put :update, :id => expense.id.to_s, :expense => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested expense" do
      expense = Expense.create! valid_attributes
      expect {
        delete :destroy, :id => expense.id.to_s
      }.to change(Expense, :count).by(-1)
    end

    it "redirects to the expenses list" do
      expense = Expense.create! valid_attributes
      delete :destroy, :id => expense.id.to_s
      response.should redirect_to(expenses_url)
    end
  end

end
