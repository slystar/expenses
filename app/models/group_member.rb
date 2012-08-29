class GroupMember < ActiveRecord::Base
    # Accessible attributes
    attr_accessible :user_id, :group_id

    # Relationshipts
    belongs_to :user
    belongs_to :group

    # Validations
    validates :user_id, :presence => true
    validates :group_id, :presence => true, :uniqueness => {:scope => :user_id}
    validates_presence_of :user
    validates_presence_of :group
end
