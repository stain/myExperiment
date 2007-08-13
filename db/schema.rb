# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 14) do

  create_table "blobs", :force => true do |t|
    t.column "contributor_id",   :integer
    t.column "contributor_type", :string
    t.column "local_name",       :string
    t.column "content_type",     :string
    t.column "data",             :binary
  end

  create_table "contributions", :force => true do |t|
    t.column "contributor_id",     :integer
    t.column "contributor_type",   :string
    t.column "contributable_id",   :integer
    t.column "contributable_type", :string
    t.column "policy_id",          :integer
    t.column "created_at",         :datetime
    t.column "updated_at",         :datetime
  end

  create_table "friendships", :force => true do |t|
    t.column "user_id",     :integer
    t.column "friend_id",   :integer
    t.column "created_at",  :datetime
    t.column "accepted_at", :datetime
  end

  create_table "memberships", :force => true do |t|
    t.column "user_id",     :integer
    t.column "network_id",  :integer
    t.column "created_at",  :datetime
    t.column "accepted_at", :datetime
  end

  create_table "messages", :force => true do |t|
    t.column "from",       :integer
    t.column "to",         :integer
    t.column "subject",    :string
    t.column "body",       :text
    t.column "reply_id",   :integer
    t.column "created_at", :datetime
    t.column "read_at",    :datetime
  end

  create_table "networks", :force => true do |t|
    t.column "user_id",    :integer
    t.column "title",      :string
    t.column "unique",     :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "permissions", :force => true do |t|
    t.column "contributor_id",   :integer
    t.column "contributor_type", :string
    t.column "policy_id",        :integer
    t.column "download",         :boolean,  :default => false
    t.column "edit",             :boolean,  :default => false
    t.column "view",             :boolean,  :default => false
    t.column "created_at",       :datetime
    t.column "updated_at",       :datetime
  end

  create_table "pictures", :force => true do |t|
    t.column "user_id", :integer
    t.column "data",    :binary
  end

  create_table "policies", :force => true do |t|
    t.column "contributor_id",     :integer
    t.column "contributor_type",   :string
    t.column "name",               :string
    t.column "download_public",    :boolean,  :default => true
    t.column "edit_public",        :boolean,  :default => true
    t.column "view_public",        :boolean,  :default => true
    t.column "download_protected", :boolean,  :default => true
    t.column "edit_protected",     :boolean,  :default => true
    t.column "view_protected",     :boolean,  :default => true
    t.column "created_at",         :datetime
    t.column "updated_at",         :datetime
  end

  create_table "profiles", :force => true do |t|
    t.column "user_id",     :integer
    t.column "picture_id",  :integer
    t.column "email",       :string
    t.column "website",     :string
    t.column "description", :text
    t.column "created_at",  :datetime
    t.column "updated_at",  :datetime
  end

  create_table "relationships", :force => true do |t|
    t.column "network_id",  :integer
    t.column "relation_id", :integer
    t.column "created_at",  :datetime
    t.column "accepted_at", :datetime
  end

  create_table "users", :force => true do |t|
    t.column "openid_url", :string
    t.column "name",       :string
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  create_table "workflow_versions", :force => true do |t|
    t.column "workflow_id",      :integer
    t.column "version",          :integer
    t.column "contributor_id",   :integer
    t.column "contributor_type", :string
    t.column "scufl",            :binary
    t.column "image",            :string
    t.column "title",            :string
    t.column "unique",           :string
    t.column "description",      :text
    t.column "created_at",       :datetime
    t.column "updated_at",       :datetime
  end

  create_table "workflows", :force => true do |t|
    t.column "contributor_id",   :integer
    t.column "contributor_type", :string
    t.column "scufl",            :binary
    t.column "image",            :string
    t.column "title",            :string
    t.column "unique",           :string
    t.column "description",      :text
    t.column "created_at",       :datetime
    t.column "updated_at",       :datetime
    t.column "version",          :integer
  end

end
