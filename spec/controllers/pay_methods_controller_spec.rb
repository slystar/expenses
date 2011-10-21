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

describe PayMethodsController do

  # This should return the minimal set of attributes required to create a valid
  # PayMethod. As you add validations to PayMethod, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  describe "GET index" do
    it "assigns all pay_methods as @pay_methods" do
      pay_method = PayMethod.create! valid_attributes
      get :index
      assigns(:pay_methods).should eq([pay_method])
    end
  end

  describe "GET show" do
    it "assigns the requested pay_method as @pay_method" do
      pay_method = PayMethod.create! valid_attributes
      get :show, :id => pay_method.id.to_s
      assigns(:pay_method).should eq(pay_method)
    end
  end

  describe "GET new" do
    it "assigns a new pay_method as @pay_method" do
      get :new
      assigns(:pay_method).should be_a_new(PayMethod)
    end
  end

  describe "GET edit" do
    it "assigns the requested pay_method as @pay_method" do
      pay_method = PayMethod.create! valid_attributes
      get :edit, :id => pay_method.id.to_s
      assigns(:pay_method).should eq(pay_method)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new PayMethod" do
        expect {
          post :create, :pay_method => valid_attributes
        }.to change(PayMethod, :count).by(1)
      end

      it "assigns a newly created pay_method as @pay_method" do
        post :create, :pay_method => valid_attributes
        assigns(:pay_method).should be_a(PayMethod)
        assigns(:pay_method).should be_persisted
      end

      it "redirects to the created pay_method" do
        post :create, :pay_method => valid_attributes
        response.should redirect_to(PayMethod.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved pay_method as @pay_method" do
        # Trigger the behavior that occurs when invalid params are submitted
        PayMethod.any_instance.stub(:save).and_return(false)
        post :create, :pay_method => {}
        assigns(:pay_method).should be_a_new(PayMethod)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        PayMethod.any_instance.stub(:save).and_return(false)
        post :create, :pay_method => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested pay_method" do
        pay_method = PayMethod.create! valid_attributes
        # Assuming there are no other pay_methods in the database, this
        # specifies that the PayMethod created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        PayMethod.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => pay_method.id, :pay_method => {'these' => 'params'}
      end

      it "assigns the requested pay_method as @pay_method" do
        pay_method = PayMethod.create! valid_attributes
        put :update, :id => pay_method.id, :pay_method => valid_attributes
        assigns(:pay_method).should eq(pay_method)
      end

      it "redirects to the pay_method" do
        pay_method = PayMethod.create! valid_attributes
        put :update, :id => pay_method.id, :pay_method => valid_attributes
        response.should redirect_to(pay_method)
      end
    end

    describe "with invalid params" do
      it "assigns the pay_method as @pay_method" do
        pay_method = PayMethod.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PayMethod.any_instance.stub(:save).and_return(false)
        put :update, :id => pay_method.id.to_s, :pay_method => {}
        assigns(:pay_method).should eq(pay_method)
      end

      it "re-renders the 'edit' template" do
        pay_method = PayMethod.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PayMethod.any_instance.stub(:save).and_return(false)
        put :update, :id => pay_method.id.to_s, :pay_method => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested pay_method" do
      pay_method = PayMethod.create! valid_attributes
      expect {
        delete :destroy, :id => pay_method.id.to_s
      }.to change(PayMethod, :count).by(-1)
    end

    it "redirects to the pay_methods list" do
      pay_method = PayMethod.create! valid_attributes
      delete :destroy, :id => pay_method.id.to_s
      response.should redirect_to(pay_methods_url)
    end
  end

end