require 'spec_helper'

describe "UserPayments" do
    before(:each) do
	# Login a user
	@new_user_id=0
	@user=get_next_user
	ApplicationController.any_instance.stub(:current_user).and_return(@user)
    end
  describe "GET /user_payments" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get user_payments_path
      response.status.should be(200)
    end
  end
end
