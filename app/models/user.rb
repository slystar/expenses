class User < ActiveRecord::Base
  attr_accessible :user_name, :password, :password_confirmation
  has_secure_password
  validates_presence_of :user_name
  validates_presence_of :password, :on => :create
end
