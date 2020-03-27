class AvatarController < ApplicationController
  before_action :find_user, except: :my_avatar_edit
  before_action :require_login, :check_if_edit_allowed, only: %i[update destroy]
  before_action :find_uploaded_attachment, only: :update

  helper :attachments
  helper :local_avatars
  include LocalAvatarsHelper

  def my_avatar_edit; end

  def show
    av = @user.attachments.where(description: 'avatar').first
    if av
      send_file(av.diskfile, filename: filename_for_content_disposition(av.filename),
                             type: av.content_type,
                             disposition: (av.image? ? 'inline' : 'attachment'))
    else
      render_404
    end
  end

  def update
    @user.attachments.where(description: 'avatar').destroy_all

    if @uploaded_attachment.present?
      crop_values = params.values_at(:crop_w, :crop_h, :crop_x, :crop_y)
      crp = crop_image(@uploaded_attachment.diskfile, crop_values) do |f|
        @uploaded_attachment.destroy
        @user.save_attachments([{ 'file' => f, 'description' => 'avatar' }])
        @user.save
      end
      logger.error("crp is #{crp} and params is #{params[:attachment]}")
      @user.save_attachments([params[:attachment].update(description: 'avatar')]) unless crp
    end

    flash[:notice] = l(:message_avatar_uploaded) if @user.save
    redirect_to_referer_or edit_my_avatar_path
  end

  def destroy
    @user.attachments.where(description: 'avatar').destroy_all
    flash[:notice] = l(:avatar_deleted)
    render nothing: true, status: :ok
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
    @user = if params[:id].present?
              User.find(params[:id])
            else
              User.current
            end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_if_edit_allowed
    deny_access unless User.current.admin? || @user == User.current
  end

  def find_uploaded_attachment
    return if params[:attachment].blank? || params[:attachment][:token].blank?

    @uploaded_attachment = Attachment.find_by_token(params[:attachment][:token])
  end
end
