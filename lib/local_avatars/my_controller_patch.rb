require_dependency 'my_controller'

class MyController
  helper :local_avatars

  def avatar_edit
    @user = User.current
  end
end
