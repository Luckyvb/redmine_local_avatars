jQuery(function ($) {
  "use strict";

  /* Cropper */
  $.widget('avatars.cropper', {
    options : {
      previewContainer: '#preview-box',
      cropXElem:        '#crop_x',
      cropYElem:        '#crop_y',
      cropWElem:        '#crop_w',
      cropHElem:        '#crop_h',

      // Private Attributes
      $previewOverflow: null, $previewElem: null, $cropboxElem: null,
      $cropboxContainer: null,

      img_width: 1, img_height: 1,
      edit_width: 0, edit_height: 0,
      preview_width: 0, preview_height: 0,

      hidden_preview: null, hidden_cropbox: null
    },

    _create: function () { var s = this.options, self = this;
      s.$cropboxContainer = this.element;
      s.preview_width = $(s.previewContainer).width();
      s.preview_height = $(s.previewContainer).height();
    },

    start: function (imageSource) { var s = this.options, self = this;
      $("<img>", { src: imageSource }).load(function () {
        s.img_width = this.width; s.img_height = this.height;

        self._initElements(imageSource);
        s.$cropboxElem.load(function () {
          s.edit_width = s.$cropboxElem.width();
          s.edit_height = s.$cropboxElem.height();

          self._initJcrop();
        });
        this.remove();
      });
    },

    stop: function () { var s = this.options;
      $(s.$cropboxContainer).contents().remove();
      s.$previewOverflow.remove();
      $(s.previewContainer + ' img').show();
    },

    _initJcrop: function () { var s = this.options, self = this;
      var side = Math.min(s.edit_width, s.edit_height);
      var offset = Math.max(0, (s.edit_width - side) / 2);
      s.$cropboxElem.Jcrop({
        onChange: self._updateCrop.bind(self),
        onSelect: self._updateCrop.bind(self),
        setSelect: [offset, 0, side, side],
        aspectRatio: 1
      });
    },

    _initElements: function (imageSource) { var s = this.options;
      // Create the preview element
      $(s.previewContainer + ' img').hide();
      s.$previewOverflow = $('<div>').css('overflow', 'hidden');
      s.$previewElem = $('<img>', { src: imageSource });
      s.$previewElem.appendTo(s.$previewOverflow);
      s.$previewOverflow.appendTo(s.previewContainer);

      // Create the cropbox element
      s.$cropboxElem = $('<img>', {'class': 'cropbox', src: imageSource});
      s.$cropboxElem.appendTo(s.$cropboxContainer);

      // Create the coordinate input elements
      $.each([s.cropX, s.cropY, s.cropW, s.cropH], function (i, val) {
        $('<input>', {name: val, type: 'hidden'})
          .appendTo(s.$cropboxContainer);
      });
    },

    _updateCrop: function (coords) { var s = this.options;
      var w = s.edit_width * s.preview_width / coords.w;
      var h = s.edit_height * s.preview_height / coords.h;
      var x = coords.x * s.preview_width / coords.w;
      var y = coords.y * s.preview_height / coords.h;
      s.$previewElem.css({
        width: Math.round(w) + 'px',
        height: Math.round(h) + 'px',
        marginLeft: '-' + Math.round(x) + 'px',
        marginTop: '-' + Math.round(y) + 'px'
      });

      var rx = s.img_width  / s.edit_width;
      var ry = s.img_height / s.edit_height;
      $('[name=' + s.cropX + ']', s.$cropboxContainer).val(Math.round(coords.x * rx));
      $('[name=' + s.cropY + ']', s.$cropboxContainer).val(Math.round(coords.y * ry));
      $('[name=' + s.cropW + ']', s.$cropboxContainer).val(Math.round(coords.w * rx));
      $('[name=' + s.cropH + ']', s.$cropboxContainer).val(Math.round(coords.h * ry));
    },

    destroy: function () {  var s = this.options;
      this.stop();
      $.Widget.prototype.destroy.call(this);
    }
  });

  /** WebCam Photographer */
  $.widget('avatars.photographer', {
    options: {
      resolutionWidth: null, resolutionHeight: null,
      swffile:         'sAS3Cam.swf',
      captureButton:   '#capture-webcam',
      startButton:     '#start-webcam',
      stopButton:      '#stop-webcam',
      camerasSelect:   '#capture-cameras select',

      filename: null, filefield: null,
      postUrl: '#', postData: {},
      StageScaleMode: 'noScale', StageAlign: 'TL',

      /* Private Fields */
      previewWidth: null, previewHeight: null,
      isCameraEnabled: false, cameraApi: null
    },

    _create: function () { var s = this.options, self = this;
      this.element.attr('id', 'photographer_' + this._random());
      this._initOptions();
      $(s.stopButton).click(function(e) { e.preventDefault(); self.stop(); });
      $(s.startButton).click(function(e) { e.preventDefault(); self.start(); });
    },

    _initOptions: function () { var s = this.options;
      s.previewWidth = $(this.element).width();
      s.previewHeight = $(this.element).height();

      if (s.filename === null) {
        s.filename = this._random() + '.jpg';
      }
      if (s.resolutionWidth === null) {
        s.resolutionWidth = s.previewWidth;
      }
      if (s.resolutionHeight === null) {
        s.resolutionHeight = s.previewHeight;
      }
    },

    disable: function () { $(this.options.startButton).prop('disabled', true); },
    enable: function () { $(this.options.startButton).prop('disabled', false); },

    start: function () { var s = this.options, self = this;
      $(s.startButton).prop('disabled', true);
      self._trigger('beforestart', null);

      $('<div>').appendTo(this.element).webcam($.extend(this.options, {
        noCameraFound:  function () { self._error('Web camera is not available') },
        swfApiFail:     function () { self._error('Internal camera plugin error') },
        cameraDisabled: function () { self._error('Please allow access to your camera') },
        cameraEnabled:  function () { self._cameraEnabled(this); }
      }));
    },

    stop: function () { var s = this.options;
      this._trigger('beforestop');

      this.element.children().remove();
      $(s.captureButton).prop('disabled', true).off('click');
      $(s.stopButton).hide().off('click');
      $(s.startButton).prop('disabled', false).show();
      $(s.camerasSelect).parent().hide();
      $(s.camerasSelect).children().remove();
      s.isCameraEnabled = false;
    },

    _cameraEnabled: function(api) { var s = this.options, self = this;
      if (s.isCameraEnabled) { return; }

      s.isCameraEnabled = true;
      s.cameraApi = api;

      setTimeout(function () {
        $(s.startButton).hide(); $(s.stopButton).show();
        self._showCamerasSelect();
        s.cameraApi.setCamera('0');
        self._trigger('afterstart', null, {api: s.cameraApi, cameras: s.cameraApi.getCameraList()});

        $(s.captureButton).prop('disabled', false);
      }, 750);

      $(s.captureButton).click(function (e) {
        e.preventDefault();
        var id = self.element.attr('id');
        self._trigger('beforeupload', null, {});
        s.cameraApi.saveAndPost({
          url:          s.postUrl,
          filename:     s.filename,
          filefield:    s.filefield,
          data:         s.postData,
          js_callback:  '(function (d) {jQuery(\'#' + id + '\').photographer(\'postCallback\', d);})'
        });
      });
    },

    _showCamerasSelect: function () { var s = this.options, self = this;
      var cams = s.cameraApi.getCameraList();
      if (cams.length <= 1) return;

      $(s.camerasSelect).parent().show();
      for (var i = 0; i < cams.length; i++) {
        $('<option>').attr('value', i).text(cams[i]).appendTo(s.camerasSelect);
      }
      $(s.camerasSelect).change(function () {
        if (!s.cameraApi.setCamera($(this).val())) {
          self._error('Unable to select camera');
        }
      });
    },

    _error: function (msg) {
      this._trigger('error', null, { message: msg })
    },

    postCallback: function (data) {
      this.stop();
      this._trigger('afterupload', null, { text: data });
    },


    destroy: function () {
      this.stop();
      $.Widget.prototype.destroy.call(this);
    },

    _random: function () {
      return Math.floor((Math.random()*99999));
    }
  });

  /** File Uploader */
  $.widget("avatars.uploader", {
    options : {
      attachmentId:         1,
      attachmentsContainer: '#attachments_fields',
      fileFieldContainer:   '.add_attachment',
      thisSelector:         '.add_attachment'
    },

    _create: function () { var self = this;
      this.element.attr('id', 'uploader_' + this._random());
      this.element.on('change', 'input[type=file]', function () { self.addInputFile(this); });
    },
    destroy: function () { $.Widget.prototype.destroy.call(this); },
    disable: function () { $(this.options.fileFieldContainer).find('input').prop('disabled', true); },
    enable: function () { $(this.options.fileFieldContainer).find('input').prop('disabled', false); },

    addInputFile: function (inputEl) { var s = this.options;
      var aFilename    = inputEl.value.split(/\/|\\/);
      var filename     = aFilename[aFilename.length - 1];

      var attachmentId = s.attachmentId++;
      var fileSpan = this.createInputField(filename, attachmentId);
      this._ajaxUpload(inputEl, filename, fileSpan, attachmentId);
    },

    createInputField: function (filename, attachmentId) { var s = this.options, self = this;
      var $fileSpan = $('<span>', { id: 'attachments_' + attachmentId });

      $(s.fileFieldContainer).hide();
      $fileSpan.on("remove", function () {
        $(s.fileFieldContainer).show();
        self._trigger("fileremove", null, { attachmentId: attachmentId });
      });

      $fileSpan.append(
        $('<input>', { type: 'text', 'class': 'filename readonly', name: 'attachment[filename]', readonly: 'readonly'}).val(filename),
        $('<a>&nbsp</a>').attr({ href: "#", 'class': 'remove-upload' }).click(this._removeFile).hide()
      ).appendTo(s.attachmentsContainer);

      return $fileSpan;
    },

    successAfterUpload: function (data) {
      var $fileSpan = $('#attachments_' + data.attachmentId);
      $fileSpan.append(
        $('<input>', { type: 'hidden', name: 'attachment[token]', value: data.token }),
        $('<input>', { type: 'hidden', name: 'attachment[content_type]', value: data.contentType }));
      $fileSpan.find('a.remove-upload')
        .attr({
          'data-remote': true,
          'data-method': 'delete',
          href: data.deletePath
        })
        .css('display', 'inline-block')
        .off('click');

      this._trigger("afterupload", null, data);
    },

    errorAfterUpload: function (data) {
      this._trigger("error", null, data);
    },

    _ajaxUpload: function (inputEl, filename, fileSpan, attachmentId) { var s = this.options, self = this;
      var clearedFileInput = $(inputEl).clone().val('');
      clearedFileInput.prependTo(s.fileFieldContainer);

      var progressSpan = $('<div>').insertAfter(fileSpan.find('input.filename'));
      progressSpan.progressbar();
      fileSpan.addClass('ajax-waiting');

      $('<form>').append(inputEl).ajaxSubmit({
        type:           'POST',
        url:            self.element.data('upload-path'),
        data:           {
          filename:      filename,
          attachment_id: attachmentId,
          uploader:      '#' + self.element.attr('id')
        },
        dataType:       'script',
        delegation:     true,
        beforeSend:     function (jqXhr) {
          jqXhr.setRequestHeader('Accept', 'application/js');
        },
        uploadProgress: function (e, pos, total, percentComplete) {
          progressSpan.progressbar('value', percentComplete);
        },
        beforeSubmit:   function (arr, $form, options) {
          fileSpan.removeClass('ajax-waiting').addClass('ajax-loading');
          $('input:submit', fileSpan.parents('form')).prop('disabled', true);
        },
        success:        function (data, statusText, xhr, $form) {
          progressSpan.progressbar('value', 100).remove();
        },
        error:          function (xhr, textStatus, errorThrown) {
          progressSpan.text(textStatus);
        },
        complete:       function (xhr) {
          fileSpan.removeClass('ajax-loading');
          $('input:submit', fileSpan.parents('form')).prop('disabled', false);
          $(inputEl).parent().remove();
        }
      });
    },

    _removeFile: function (e) {
      e.preventDefault();
      $(e.target).parent('span').remove();
    },

    _random: function () {
      return Math.floor((Math.random()*99999));
    }
  });
});
