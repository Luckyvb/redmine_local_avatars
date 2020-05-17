class AvatarController < ApplicationController
  before_action :find_user, except: :my_avatar_edit
  before_action :find_group, except: :my_avatar_edit
  before_action :require_login, :check_if_edit_allowed, only: %i[update destroy]
  before_action :find_uploaded_attachment, only: :update

  helper :attachments
  helper :local_avatars
  include LocalAvatarsHelper

  def my_avatar_edit; end

  def show
    principal = @group.is_a?(Group) ? @group : @user
    av = principal.attachments.where(description: 'avatar').first
    if av
      send_file(av.diskfile, filename: filename_for_content_disposition(av.filename),
                             type: av.content_type, disposition: (av.image? ? 'inline' : 'attachment'))
    else
      render_404
    end
  end

  def update
    if @uploaded_attachment.present?
      principal = @group.is_a?(Group) ? @group : @user
      principal.attachments.where(description: 'avatar').destroy_all
      crop_values = params.values_at(:crop_w, :crop_h, :crop_x, :crop_y)
      crp = crop_image(@uploaded_attachment.diskfile, crop_values) do |f|
        @uploaded_attachment.destroy
        principal.save_attachments([{ 'file' => f, 'description' => 'avatar' }])
        principal.save
      end
      logger.error("crp is #{crp} and params is #{params[:attachment]}")
      principal.save_attachments([params[:attachment].update(description: 'avatar')]) unless crp

      flash[:notice] = l(:message_avatar_uploaded) if principal.save
    end

    if principal == User.current
      redirect_to my_account_path
    else
      if principal.is_a?(User)
        redirect_to edit_user_path(id: principal.id, tab: 'avatar')
      else
        redirect_to edit_group_path(id: principal.id, tab: 'avatar')
      end
    end
  end

  # used by sidebar to destroy own user account
  def destroy
    @user.attachments.where(description: 'avatar').destroy_all
    flash[:notice] = l(:avatar_deleted)
    redirect_to my_account_destroy_path
  end

  def upload
    @attachment = Attachment.new(file: params[:attachment][:file])
    @attachment.author = User.current
    @attachment.description = 'avatar'
    @attachment.filename = params[:filename].presence || Redmine::Utils.random_hex(16)
    @attachment.save

    respond_to { |format| format.js }
  end

  private

  def find_user
    id = params[:user_id].presence || params[:id]
    @user = id.present? ? User.find(id) : User.current
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_group
    id = params[:group_id].presence || params[:id]
    @group = id.present? ? Group.find(id) : nil
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_if_edit_allowed
    deny_access unless User.current.admin? || @user == User.current
  end

  def find_uploaded_attachment
    return if params[:attachment].blank? || params[:attachment][:token].blank?

    @uploaded_attachment = Attachment.find_by_token(params[:attachment][:token]) # rubocop:disable Rails/DynamicFindBy
  end
end
