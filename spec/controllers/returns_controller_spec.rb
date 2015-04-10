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

describe ReturnsController do

    before(:each) do
	# Login a user
	@new_user_id=0
	user=get_next_user
	request.session[:user_id] = user.id
	@exp=get_valid_expense
    end


  # This should return the minimal set of attributes required to create a valid
  # Return. As you add validations to Return, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
      {:description => Faker::Company.name, :expense_id => @exp.id, :transaction_date => Date.today, :user_id => @exp.user_id, :amount => @exp.amount - 1}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ReturnsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all returns as @returns" do
      return_obj = Return.create! valid_attributes
      get :index
      assigns(:returns).should eq([return_obj])
    end
  end

  describe "GET show" do
    it "assigns the requested return as @return" do
      return_obj = Return.create! valid_attributes
      get :show, {:id => return_obj.to_param}
      assigns(:return).should eq(return_obj)
    end
  end

  describe "GET new" do
    it "assigns a new return as @return" do
      get :new
      assigns(:return).should be_a_new(Return)
    end
  end

  describe "GET edit" do
    it "assigns the requested return as @return" do
      return_obj = Return.create! valid_attributes
      get :edit, {:id => return_obj.to_param}
      assigns(:return).should eq(return_obj)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Return" do
        expect {
          post :create, {:return => valid_attributes}
        }.to change(Return, :count).by(1)
      end

      it "assigns a newly created return as @return" do
        post :create, {:return => valid_attributes}
        assigns(:return).should be_a(Return)
        assigns(:return).should be_persisted
      end

      it "redirects to the created return" do
        post :create, {:return => valid_attributes}
        response.should redirect_to("#{returns_path}/new")
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved return as @return" do
        # Trigger the behavior that occurs when invalid params are submitted
        Return.any_instance.stub(:save).and_return(false)
        post :create, {:return => {  }}
        assigns(:return).should be_a_new(Return)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Return.any_instance.stub(:save).and_return(false)
        post :create, {:return => {  }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested return" do
        return_obj = Return.create! valid_attributes
        # Assuming there are no other returns in the database, this
        # specifies that the Return created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Return.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => return_obj.to_param, :return => { "these" => "params" }}
      end

      it "assigns the requested return as @return" do
        return_obj = Return.create! valid_attributes
        put :update, {:id => return_obj.to_param, :return => valid_attributes}
        assigns(:return).should eq(return_obj)
      end

      it "redirects to the return" do
        return_obj = Return.create! valid_attributes
        put :update, {:id => return_obj.to_param, :return => valid_attributes}
        response.should redirect_to(return_obj)
      end
    end

    describe "with invalid params" do
      it "assigns the return as @return" do
        return_obj = Return.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Return.any_instance.stub(:save).and_return(false)
        put :update, {:id => return_obj.to_param, :return => {  }}
        assigns(:return).should eq(return_obj)
      end

      it "re-renders the 'edit' template" do
        return_obj = Return.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Return.any_instance.stub(:save).and_return(false)
        put :update, {:id => return_obj.to_param, :return => {  }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested return" do
      return_obj = Return.create! valid_attributes
      expect {
        delete :destroy, {:id => return_obj.to_param}
      }.to change(Return, :count).by(-1)
    end

    it "redirects to the returns list" do
      return_obj = Return.create! valid_attributes
      delete :destroy, {:id => return_obj.to_param}
      response.should redirect_to(returns_url)
    end
  end

end
