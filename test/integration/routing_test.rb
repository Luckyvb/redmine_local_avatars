require File.expand_path('../../test_helper', __FILE__)

class RoutingTest < Redmine::RoutingTest
  test 'routing users' do
    should_route 'GET /users/1/avatar_destroy' => 'avatar#destroy', user_id: '1'
    should_route 'GET /users/1/avatar' => 'avatar#show', user_id: '1'
    should_route 'POST /users/1/avatar' => 'avatar#update', user_id: '1'
    # should_route 'POST /users/1/avatar/upload.:format' => 'avatar#upload', user_id: '1', format: :format
  end

  test 'routing my' do
    should_route 'GET /my/avatar_edit' => 'my#avatar_edit'
  end
end
