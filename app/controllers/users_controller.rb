# myExperiment: app/controllers/users_controller.rb
#
# Copyright (c) 2007 University of Manchester and the University of Southampton.
# See license.txt for details.

class UsersController < ApplicationController

  contributable_actions = [:workflows, :files, :packs, :blogs]
  show_actions = [:show, :news, :friends, :groups, :credits, :tags, :favourites] + contributable_actions

  before_filter :login_required, :except => [:index, :new, :create, :search, :all, :confirm_email, :forgot_password, :reset_password] + show_actions
  
  before_filter :find_users, :only => [:all]
  before_filter :find_user, :only => show_actions
  before_filter :find_user_auth, :only => [:edit, :update, :destroy]
  
  before_filter :invalidate_listing_cache, :only => [:update, :destroy]
  
  # GET /users;search
  def search

    @query = params[:query]
    
    results = SOLR_ENABLE ? User.find_by_solr(@query, :limit => 100).results : []
    
    # Only show activated users!
    @users = results.select { |u| u.activated? }
    
    respond_to do |format|
      format.html # search.rhtml
    end
  end
  
  # GET /users
  def index
    respond_to do |format|
      format.html # index.rhtml
    end
  end
  
  # GET /users/all
  def all
    respond_to do |format|
      format.html # all.rhtml
    end
  end

  # GET /users/1
  def show

    @tab = "News" if @tab.nil?

    @user.salt = nil
    @user.crypted_password = nil
    
    respond_to do |format|
      format.html # show.rhtml
    end
  end

  def news
    @tab = "News"
    render :action => 'show'
  end

  def friends
    @tab = "Friends"
    render :action => 'show'
  end

  def groups
    @tab = "Groups"
    render :action => 'show'
  end

  def workflows
    @tab = "Workflows"
    render :action => 'show'
  end

  def files
    @tab = "Files"
    render :action => 'show'
  end
  
  def packs
    @tab = "Packs"
    render :action => 'show'
  end

  def blogs
    @tab = "Blogs"
    render :action => 'show'
  end

  def credits
    @tab = "Credits"
    render :action => 'show'
  end

  def tags
    @tab = "Tags"
    render :action => 'show'
  end
  
  def favourites
    @tab = "Favourites"
    render :action => 'show'
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1;edit
  def edit
    
  end

  # POST /users
  def create
    if params[:user][:username] && params[:user][:password] && params[:user][:password_confirmation]
      params[:user].delete("openid_url") if params[:user][:openid_url] # strip params[:user] of it's openid_url if username and password is provided
    end
    
    unless params[:user][:name]
      if params[:user][:username]
        params[:user][:name] = params[:user][:username].humanize # initializes username (if one isn't entered)
      else
        params[:user][:name] = params[:user][:openid_url]
      end
    end
    
    # Reset certain fields (to prevent injecting the values)
    params[:user][:email] = nil;
    params[:user][:email_confirmed_at] = nil
    params[:user][:activated_at] = nil
    
    @user = User.new(params[:user])
    
    respond_to do |format|
      if @user.save
        # DO NOT log in user yet, since account needs to be validated and activated first (through email).
        Mailer.deliver_account_confirmation(@user, confirmation_hash(@user.unconfirmed_email), base_host)
        
        # If required, copy the email address to the Profile
        if params[:make_email_public]
          @user.profile.email = @user.unconfirmed_email
          @user.profile.save
        end
        
        flash[:notice] = "Thank you for registering! We have sent a confirmation email to #{@user.unconfirmed_email} with instructions on how to activate your account."
        format.html { redirect_to(:action => "index") }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /users/1
  def update
    # openid url's must be validated and updated separately
    # FIXME: shouldn't the line below be for params[:user][:openid_url]
    params.delete("openid_url") if params[:openid_url]
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        
        # Check to see if user tried to set the new email address to the same as an existing one
        if !@user.unconfirmed_email.blank? and @user.unconfirmed_email == @user.email
          # Reset the field
          @user.unconfirmed_email = nil;
          @user.save
          
          flash.now[:error] = 'The new email address you are trying to set is the same as your current email address'
        else
          # If a new email address was set, then need to send out a confirmation email
          if params[:user][:unconfirmed_email]
            Mailer.deliver_update_email_address(@user, confirmation_hash(@user.unconfirmed_email), base_host)
            flash.now[:notice] = "We have sent an email to #{@user.unconfirmed_email} with instructions on how to confirm this new email address"
          elsif params[:update_type]
            case params[:update_type]
              when "upd_t_up"; flash.now[:notice] = 'You have successfully updated your password'
              when "upd_t_displname"; flash.now[:notice] = 'You have successfully updated your display name'
              when "upd_t_notify"; flash.now[:notice] = 'You have successfully updated notification options'
            end
          else
              flash.now[:notice] = 'You have successfully updated your account' # general message to be displayed when hidden field 'update_type' was not created for a certain form on the page
          end
        end
        
        #format.html { redirect_to user_url(@user) }
        format.html { render :action => "edit" }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /users/1
  def destroy
    flash[:notice] = 'Please contact the administrator to have your account removed.'
    redirect_to :action => :index
    
    #@user.destroy
    
    # the user MUST be logged in to destroy their account
    # it is important to log them out afterwards or they'll 
    # receive a nasty error message..
    #session[:user_id] = nil
    
    #respond_to do |format|
    #  flash[:notice] = 'User was successfully destroyed'
    #  format.html { redirect_to users_url }
    #end
  end
  
  # GET /users/confirm_email/:hash
  # TODO: NOTE: this action is not "API safe" yet (ie: it doesnt cater for a request with an XML response)
  def confirm_email
    # NOTE: this action is used for both:
    # - new users who sign up with username/password and need to confirm their email address
    # - existing users who want to change their email address (but old email address is still active) 
        
    @users = User.find :all

    confirmed = false
    
    for user in @users
      unless user.unconfirmed_email.blank?
        # Check if hash matches user, in which case confirm the user's email
        if confirmation_hash(user.unconfirmed_email) == params[:hash]
          confirmed = user.confirm_email!
          # BEGIN DEBUG
          puts "ERRORS!" unless user.errors.empty?
          user.errors.full_messages.each { |e| puts e } 
          #END DEBUG
          if confirmed
            self.current_user = user
            confirmed = false if !logged_in?
          end
          @user = user
          break
        end
      end
    end
    
    respond_to do |format|
      if confirmed
        flash[:notice] = "Thank you for confirming your email. Your account is now active (if it wasn't before), and the new email address registered on your account. We hope you enjoy using myExperiment!"
        format.html { redirect_to user_url(@user) }
      else
        flash[:error] = "Invalid confirmation URL"
        format.html { redirect_to(:controller => "session", :action => "new") }
      end
    end
  end
  
  # GET /users/forgot_password
  # POST /users/forgot_password
  # TODO: NOTE: this action is not "API safe" yet (ie: it doesnt cater for a request with an XML response)
  def forgot_password
    
    if request.get?
      # forgot_password.rhtml
    elsif request.post?
      user = User.find_by_email(params[:email])

      respond_to do |format|
        if user
          user.reset_password_code_until = 1.day.from_now
          user.reset_password_code =  Digest::SHA1.hexdigest( "#{user.email}#{Time.now.to_s.split(//).sort_by {rand}.join}" )
          user.save!
          Mailer.deliver_forgot_password(user, base_host)
          flash[:notice] = "Instructions on how to reset your password have been sent to #{user.email}"
          format.html { render :action => "forgot_password" }
        else
          flash[:error] = "Invalid email address: #{params[:email]}"
          format.html { render :action => "forgot_password" }
        end
      end
    end
    
  end
  
  # GET /users/reset_password
  # TODO: NOTE: this action is not "API safe" yet (ie: it doesnt cater for a request with an XML response)
  def reset_password
    user = User.find_by_reset_password_code(params[:reset_code])
    
    respond_to do |format|
      if user
        if user.reset_password_code_until && Time.now < user.reset_password_code_until
          user.reset_password_code = nil
          user.reset_password_code_until = nil
          if user.save
            self.current_user = user
            if logged_in?
              flash[:notice] = "You can reset your password here"
              format.html { redirect_to(:action => "edit", :id => user.id) }
            else
              flash[:error] = "An unknown error has occurred. We are sorry for the inconvenience. You can request another password reset here."
              format.html { render :action => "forgot_password" }
            end
          end
        else
          flash[:error] = "Your password reset code has expired"
        format.html { redirect_to(:controller => "session", :action => "new") }
        end
      else
        flash[:error] = "Invalid password reset code"
        format.html { redirect_to(:controller => "session", :action => "new") }
      end
    end 
  end
  
  def timeline
    respond_to do |format|
      format.html # timeline.rhtml
    end
  end
  
  # For simile timeline
  def users_for_timeline
    @users = User.find(:all, :conditions => [ "users.activated_at IS NOT NULL AND users.created_at > ? AND users.created_at < ?", params[:start].to_time, params[:end].to_time ], :include => [ :profile ] )
    respond_to do |format|
      format.json { render :partial => 'users/timeline_json', :layout => false }
    end
  end
  
protected

  def find_users
    @users = User.find(:all, 
                       :order => "users.name ASC",
                       :page => { :size => 20, 
                                  :current => params[:page] },
                       :conditions => "users.activated_at IS NOT NULL",
                       :include => :profile)
                       
    @users.each do |user|
      user.salt = nil
      user.crypted_password = nil
    end
  end

  def find_user
    begin
      @user = User.find(params[:id], :include => [ :profile, :tags ])
    rescue ActiveRecord::RecordNotFound
      error("User not found", "is invalid (not owner)")
      return false
    end
    
    unless @user
      error("User not found", "is invalid (not owner)")
      return false
    end
    
    unless @user.activated?
      error("User not activated", "is invalid (not owner)")
      return false
    end
  end

  def find_user_auth
    begin
      @user = User.find(params[:id], :conditions => ["id = ?", current_user.id])
    rescue ActiveRecord::RecordNotFound
      error("User not found (id not authorized)", "is invalid (not owner)")
      return false
    end
    
    unless @user
      error("User not found (or not authorized)", "is invalid (not owner)")
      return false
    end
    
    unless @user.activated?
      error("User not activated (id not authorized)", "is invalid (not owner)")
      return false
    end
  end
  
  def invalidate_listing_cache
    if params[:id]
      expire_fragment(:controller => 'users_cache', :action => 'listing', :id => params[:id])
    end
  end
  
private

  def error(notice, message)
    flash[:error] = notice
    (err = User.new.errors).add(:id, message)
    
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end
  
  def confirmation_hash(string)
    Digest::SHA1.hexdigest(string + SECRET_WORD)
  end
end
