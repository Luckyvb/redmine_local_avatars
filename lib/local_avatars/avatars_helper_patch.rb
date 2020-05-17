require_dependency 'application_helper'
require_dependency 'avatars_helper'

module LocalAvatars
  module AvatarsHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :avatar_without_local_avatar, :avatar
        alias_method :avatar, :avatar_with_local_avatar
      end
    end

    module InstanceMethods
      def avatar_with_local_avatar(user, options = {})
        if (user.is_a?(User) || user.is_a?(Group)) && user.attachments.exists?(description: 'avatar')
          if (size = options.delete(:size))
            options[:size] = "#{size}x#{size}"
          end

          classes = [GravatarHelper::DEFAULT_OPTIONS[:class]]
          classes << options[:class] if options[:class]
          options[:class] = classes.join(' ')

          unless options[:size]
            default_size = GravatarHelper::DEFAULT_OPTIONS[:size]
            options[:size] = "#{default_size}x#{default_size}"
          end
          if user.is_a?(User)
            image_tag user_avatar_url(user), options
          elsif user.is_a?(Group)
            image_tag group_avatar_url(user), options
          end
        else
          avatar_without_local_avatar(user, options)
        end
      end
    end
  end
end
