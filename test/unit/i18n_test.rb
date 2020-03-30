require File.expand_path('../../test_helper', __FILE__)

class I18nTest < ActiveSupport::TestCase
  include Redmine::I18n

  def setup
    User.current = nil
  end

  def teardown
    set_language_if_valid 'en'
  end

  def test_valid_languages
    assert valid_languages.is_a?(Array)
    assert valid_languages.first.is_a?(Symbol)
  end

  def test_locales_validness
    lang_files_count = Dir[Rails.root.join('plugins/redmine_local_avatars/config/locales/*.yml')].size

    assert_equal 11, lang_files_count
    valid_languages.each do |lang|
      assert set_language_if_valid(lang)
      case lang.to_s
      when 'en'
        assert_equal 'Change local avatar', l(:button_change_avatar)
      when 'bg', 'de', 'es', 'fr', 'it', 'ja', 'pt-BR', 'ru', 'zh-TW', 'zh'
        assert_not l(:button_change_avatar) == 'Change local avatar', lang
      end
    end
  end
end
