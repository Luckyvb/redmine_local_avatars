Redmine::Plugin.register :redmine_local_avatars do
  name 'Redmine Local Avatars plugin'
  author 'Andrew Chaika, Luca Pireddu, Ricardo Santos and Alexander Meindl, !Lucky'
  description 'This plugin lets users upload avatars directly into Redmine'
  version '1.0.1'
  requires_redmine version_or_higher: '4.1'
end

require_dependency 'local_avatars/hooks'
Rails.configuration.to_prepare do
  require_dependency 'local_avatars/my_controller_patch'
  require_dependency 'local_avatars/user_patch'
  require_dependency 'local_avatars/users_controller_patch'
  require_dependency 'local_avatars/group_patch'
  require_dependency 'local_avatars/groups_controller_patch'
end

Rails.application.config.after_initialize do
  AvatarsHelper.include LocalAvatars::AvatarsHelperPatch
end
