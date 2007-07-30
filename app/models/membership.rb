class Membership < ActiveRecord::Base
  validates_presence_of :user_id
                            
  validates_presence_of :network_id
  
  belongs_to :user
  
  belongs_to :network
end
