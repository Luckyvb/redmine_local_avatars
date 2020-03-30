require File.expand_path('../../test_helper', __FILE__)

class UsersControllerTest < Redmine::ControllerTest
  fixtures :users, :email_addresses, :groups_users, :roles, :user_preferences,
           :enumerations,
           :projects, :projects_trackers, :enabled_modules,
           :members, :member_roles

  include Redmine::I18n

  def setup
    @request.session[:user_id] = 1
  end

  def test_edit_with_change_avatar_tab
    get :edit,
        params: { id: 2 }

    assert_response :success
    assert_select 'a#tab-avatar'
  end
end
