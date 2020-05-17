module LocalAvatarsHelper
  def user_settings_tabs
    tabs = super
    tabs << { name: 'avatar', partial: 'avatar/edit_tab', label: :label_avatar }
    tabs
  end

  def group_settings_tabs(group)
    tabs = super
    tabs << { name: 'avatar', partial: 'avatar/edit_tab', label: :label_avatar }
    tabs
  end

  # Images will only be cropped if there are the necessary libraries.
  def can_crop_images?
    defined?(MiniMagick)
  end

  # Crops an image and stores it on a temporary file.
  #
  # <tt>filepath</tt> contains the path to the image that should be cropped and
  # <tt>crop_values</tt> must be a array with the values with the order
  # <tt>[W, H, X, Y]</tt>.
  #
  # If the necessary libraries aren't available <tt>crop_image</tt> returns nil
  # otherwise it returns the result of evaluating the +block+.
  #
  # Examples:
  #
  #     crop_image('/tmp/image.jpeg', [200, 200, 0, 0]) do |file|
  #       send_file file.path, :type => 'image/jpeg', :disposition => 'inline'
  #     end
  def crop_image(*args, &block)
    return unless defined? MiniMagick

    crop_image_with_mini_magick(*args, &block)
  end

  def crop_image_with_mini_magick(filepath, crop_values)
    img = MiniMagick::Image.open(filepath)
    if crop_values.all?
      img.crop format('%<width>sx%<height>s+%<x_offset>s+%<y_offset>s',
                      width: crop_values[0],
                      height: crop_values[1],
                      x_offset: crop_values[2],
                      y_offset: crop_values[3])
    end

    img.combine_options do |c|
      c.thumbnail '125x125^'
      c.gravity 'north'
      c.extent '125x125'
    end
    img.format('jpg')

    temporary_image(
      writer: ->(f) { img.write(f) },
      consumer: ->(f) { yield f }
    )
  end

  def temporary_image(options)
    file = Tempfile.open(['img', '.jpg'], Rails.root.join('tmp'), encoding: 'ascii-8bit') do |f|
      options[:writer].call(f)
      f
    end

    File.open(file.path, 'rb') do |f|
      def
        f.original_filename
        File.basename(path)
      end
      options[:consumer].call(f)
    end
  ensure
    file&.unlink
  end

  def plugin_image_path(source, options = {})
    plugin = options.delete(:plugin)
    if plugin
      source = "/plugin_assets/#{plugin}/images/#{source}"
    elsif current_theme&.images&.include?(source)
      source = current_theme.image_path(source)
    end
    path_to_image(source)
  end
end
