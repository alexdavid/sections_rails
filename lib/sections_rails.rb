module SectionsRails
  require 'action_view'
  require "sections_rails/section"
  require "sections_rails/railtie" #if defined?(Rails)

  def section name, locals = {}, options = {}, &block
    options[:locals] = locals
    SectionsRails::Section.new(name, self, options).render &block
  end
end

ActionView::Base.send :include, SectionsRails
