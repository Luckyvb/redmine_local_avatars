require File.expand_path('../../test_helper', __FILE__)

class MyControllerTest < Redmine::ControllerTest
  fixtures :users, :email_addresses, :user_preferences, :roles, :projects, :members, :member_roles,
           :issues, :issue_statuses, :trackers, :enumerations, :custom_fields, :auth_sources, :queries,
           :enabled_modules, :journals

  def setup
    @request.session[:user_id] = 2
  end

  def test_account_with_change_avatar_link
    get :account

    assert_response :success
    assert_select 'a[href=?]', '/my/avatar_edit'
  end

  def test_edit_avatar
    get :avatar_edit

    assert_response :success
    assert_select 'form[action="/users/2/avatar"]'
  end
end
