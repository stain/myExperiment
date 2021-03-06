# myExperiment: app/models/policy.rb
#
# Copyright (c) 2007 University of Manchester and the University of Southampton.
# See license.txt for details.

class Policy < ActiveRecord::Base
  
  belongs_to :contributor, :polymorphic => true
  
  has_many :contributions,
           :dependent => :nullify,
           :order => "contributable_type ASC"
  
  has_many :permissions,
           :dependent => :destroy,
           :order => "created_at ASC"
  
  validates_presence_of :contributor, :name
  
  before_save do |policy|

    if policy.share_mode
      policy.public_view     = policy.share_mode < 3
      policy.public_download = policy.share_mode < 1
    end

    true
  end

  # THIS IS THE DEFAULT POLICY (see /app/views/policies/_list_form.rhtml)
  def self._default(c_utor, c_ution=nil)
    rtn = Policy.new(:name => "A default policy",  # "anyone can view and download and no one else can edit"
                     :contributor => c_utor,
                     :share_mode => 0,
                     :update_mode => 6,
                     :public_view => false,
                     :public_download => false)     
                     
    c_ution.policy = rtn unless c_ution.nil?
    
    return rtn
  end
  
  
  # Copies all the values from 'other' to self
  def copy_values_from(other)
    self.name = other.name
    self.contributor = other.contributor
    self.share_mode = other.share_mode
    self.update_mode = other.update_mode
    self.public_view = other.public_view
    self.public_download = other.public_download
  end
  
  
  # Deletes all User permissions - used in application.rb::update_policy()
  def delete_all_user_permissions
    self.permissions.each do |p|
      if p.contributor_type == 'User'
        p.destroy
      end
    end
  end

  def group_policy?
    contributor_type == "Network"
  end
end
