namespace :interpret do
  desc 'Copy all the translations from config/locales/*.yml into DB backend'
  task :migrate => [:environment, "tmp:cache:clear"] do
    Interpret::Translation.dump
  end

  desc 'Synchronize the keys used in db backend with the ones on *.yml files'
  task :update => [:environment, "tmp:cache:clear"] do
    Interpret::Translation.update
  end
end


def get_value_from_yaml_by_ckey(locale, ckey)
  old_backend = I18n.backend
  I18n.backend = I18n::Backend::Simple.new
  old = I18n.locale
  I18n.locale = locale
  res = I18n.t(ckey)
  I18n.locale = old
  I18n.backend = old_backend
  res
end

# Fem que les claus a bd pel locale donat corresponguin al hash original de contrast dict
def put_in_sync_with_db(dict, locale, prefix = "", existing = nil)
  if existing.nil?
    translations = Interpret::Translation.locale(locale).all
    existing = Interpret::Translation.as_hash(translations)
    existing = existing.first[1] unless existing.empty?
  end

  dict.keys.each do |x|
    existing.delete(x)

    if dict[x].kind_of?(Hash)
      put_in_sync_with_db(dict[x], locale, "#{prefix}#{x}.", existing[x])
    else
      old = Interpret::Translation.where(:locale => locale, :key => "#{prefix}#{x}").first
      if !old
        Interpret::Translation.create :locale => locale,
                           :key => "#{prefix}#{x}",
                           :value => get_value_from_yaml_by_ckey(locale, "#{prefix}#{x}")
        Interpret.logger.info("[translations:update] Created new key for locale: [#{locale}], key: [#{prefix}#{x}]")
      end
    end
  end

  if prefix.blank?
    remove_old_keys_in_db(existing, locale)
  end
end

def remove_old_keys_in_db(dict, locale, prefix = "")
  dict.keys.each do |x|
    if dict[x].kind_of?(Hash)
      remove_old_keys_in_db(dict[x], locale, "#{prefix}#{x}.")
    else
      old = Interpret::Translation.where(:locale => locale, :key => "#{prefix}#{x}").first
      Interpret.logger.info("[translations:update] Removed unused key [#{prefix}#{x}] for locale [#{locale}]. The value was [#{old.value}]")
      old.delete
    end
  end
end



