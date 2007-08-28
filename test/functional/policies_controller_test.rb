##
##
## myExperiment - a social network for scientists
##
## Copyright (C) 2007 University of Manchester/University of Southampton
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU Affero General Public License
## as published by the Free Software Foundation; either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Affero General Public License for more details.
##
## You should have received a copy of the GNU Affero General Public License
## along with this program; if not, see http://www.gnu.org/licenses
## or write to the Free Software Foundation,Inc., 51 Franklin Street,
## Fifth Floor, Boston, MA 02110-1301  USA
##
##

require File.dirname(__FILE__) + '/../test_helper'
require 'policies_controller'

# Re-raise errors caught by the controller.
class PoliciesController; def rescue_action(e) raise e end; end

class PoliciesControllerTest < Test::Unit::TestCase
  fixtures :policies

  def setup
    @controller = PoliciesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:policies)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_policy
    old_count = Policy.count
    post :create, :policy => { }
    assert_equal old_count+1, Policy.count
    
    assert_redirected_to policy_path(assigns(:policy))
  end

  def test_should_show_policy
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_policy
    put :update, :id => 1, :policy => { }
    assert_redirected_to policy_path(assigns(:policy))
  end
  
  def test_should_destroy_policy
    old_count = Policy.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Policy.count
    
    assert_redirected_to policies_path
  end
end
