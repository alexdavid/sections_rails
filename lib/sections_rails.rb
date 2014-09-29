module SectionsRails
  require 'action_view'
  require "sections_rails/section"
  require "sections_rails/railtie" #if defined?(Rails)

  def section name_or_options, locals = {}, &block
    if name_or_options.is_a? String
      name = name_or_options
      options = { locals: locals }
    else
      name = name_or_options[:name]
      options = name_or_options
    end

    SectionsRails::Section.new(name, self, options).render &block
  end
end

ActionView::Base.send :include, SectionsRails
