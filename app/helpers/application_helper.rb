module ApplicationHelper

  def link_to_external(name, url, opts = {})
    link_to name, external_url(url), opts.merge(target: '_blank')
  end

  def fa_icon_link_to(title, icon, url, html_opts = {})
    link_to url, html_opts.reverse_merge(title: title) do
      fa_icon icon
    end
  end

  def fa_icon_and_text_link_to(title, icon, url, html_opts = {})
    link_to url, html_opts.reverse_merge(title: title) do
      fa_icon(icon) + ' ' + title
    end
  end

  #if url doesn't contain the protocol then add it here
  def external_url(url)
    if url.blank?
      ''
    else
      url.match(/^http(s?):\/\//) ? url : "http://#{url}"
    end
  end

  #standard way to render a value in a show view
  def show_value(value, label)
    render 'shared/show_value', label: label, value: value
  end

  #standard way to render a field of a model in a show view, with custom label if needed
  def show_field(model, field, label = nil)
    label ||= field.to_s.titlecase
    show_value(model.send(field), label)
  end

  def show_present_value(value, label)
    show_value(value, label) if value.present?
  end

  def show_present_field(model, field, label = nil)
    show_field(model, field, label) if model.send(field).present?
  end

  def generic_confirm_message
    Settings.classes.application_helper.generic_confirm_message
  end

  def wiki_link(label)
    fa_icon_link_to label, Settings.icon.wiki_link, Settings.medusa.wiki_url, target: '_blank'
  end

  def cache_key_for_all(klass)
    count = klass.cache_count
    max_updated_at = klass.maximum(:updated_at) rescue nil
    "#{klass.to_s.pluralize.underscore}/all-#{count}-#{max_updated_at}"
  rescue
    #if there is an error force the cache to clear
    UUID.generate
  end

  #If available get the count from solr, which is much faster for classes
  #with a lot of records. Otherwise hit the database.
  def cache_count(klass)
    if klass.respond_to?(:search)
      klass.search {keyword ''}.total
    else
      klass.count
    end
  end

  #TODO Obviously this could be much more general in the future
  def has_notifications?
    current_user and Application.group_resolver.is_ad_admin?(current_user) and
        Workflow::AccrualJob.awaiting_admin.present?
  end

end
