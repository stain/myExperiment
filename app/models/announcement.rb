# myExperiment: app/models/announcement.rb
#
# Copyright (c) 2007 University of Manchester and the University of Southampton.
# See license.txt for details.

class Announcement < ActiveRecord::Base

  attr_accessible :title, :body, :user_id

  belongs_to :user

  validates_presence_of :user_id

  format_attribute :body

  before_save :check_admin

  def check_admin
    if !self.user_id.blank? and self.user.admin?
      return true
    else
      errors.add(:base, "Only admin users can create announcements")
      return false
    end
  end
 
  # returns the 'last created' Announcements
  # the maximum number of results is set by #limit#
  def self.latest(limit=5)
    announcements = Announcement.find(:all,
              :conditions => ["created_at > :week", :week => 1.week.ago],
              :order => "created_at DESC",
              :limit => limit)
    announcements = [Announcement.last] if announcements.empty?
    announcements.compact
  end
end 