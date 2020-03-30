require File.expand_path('../../test_helper', __FILE__)

class AvatarControllerTest < Redmine::ControllerTest
  fixtures :users, :email_addresses, :user_preferences, :roles, :projects, :members, :member_roles,
           :issues, :issue_statuses, :trackers, :enumerations, :custom_fields, :auth_sources, :queries,
           :enabled_modules, :journals

  def setup
    @request.session[:user_id] = 2
  end

  def test_show_avatar
    get :show,
        params: { user_id: 2 }

    assert_response :not_found
  end

  def test_destroy_avatar
    get :destroy,
        params: { user_id: 2 }

    assert_response :redirect
  end
end
