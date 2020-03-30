module LocalAvatarsHelper
  def user_settings_tabs
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
    if defined? Magick
      crop_image_with_rmagick(*args, &block)
    elsif defined? MiniMagick
      crop_image_with_mini_magick(*args, &block)
    end
  end

  def crop_image_with_rmagick(filepath, crop_values, &block)
    img = Magick::Image.read(filepath).first.dup
    if crop_values.all?
      crop_values = crop_values[2..3] + crop_values[0..1]
      img.crop!(*crop_values.map(&:to_i))
    end
    img.resize_to_fill!(125, 125, Magick::NorthGravity)

    temporary_image(
      writer: ->(f) { img.write(f.path) },
      consumer: ->(f) { block.call(f) }
    )
  end

  def crop_image_with_mini_magick(filepath, crop_values, &block)
    img = MiniMagick::Image.open(filepath)
    img.crop sprintf('%sx%s+%s+%s', *crop_values) if crop_values.all?
    img.combine_options do |c|
      c.thumbnail '125x125^'
      c.gravity 'north'
      c.extent '125x125'
    end
    img.format('jpg')

    temporary_image(
      writer: ->(f) { img.write(f) },
      consumer: ->(f) { block.call(f) }
    )
  end

  def temporary_image(options)
    file = Tempfile.open(['img', '.jpg'], Rails.root.join('tmp'), encoding: 'ascii-8bit') do |f|
      options[:writer].call(f)
      f
    end

    File.open(file.path, 'rb') do |f|
      def f.original_filename; File.basename(path); end
      options[:consumer].call(f)
    end
  ensure
    file&.unlink
  end

  def plugin_image_path(source, options = {})
    if plugin = options.delete(:plugin)
      source = "/plugin_assets/#{plugin}/images/#{source}"
    elsif current_theme&.images&.include?(source)
      source = current_theme.image_path(source)
    end
    path_to_image(source)
  end
end
