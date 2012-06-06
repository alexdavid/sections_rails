module SectionsRails

  require "sections_rails/railtie" if defined?(Rails)
  
  def section combined_name, options = {}
    out = []

    # Split the parameter into file name and directory name.
    split_names = combined_name.to_s.split '/'
    filename = split_names[-1]
    directory = (split_names.size > 1 ? split_names[0..-2] : []).join '/'
    directory += '/' if directory.size > 0
    directory_path = "#{Rails.root}/app/sections/#{directory}#{filename}"    # Directory of section: /app/sections/admin/logo

    # Add assets of section when in dev mode.
    file_path = "#{directory_path}/#{filename}"                              # Base path of filename in section: /app/sections/admin/logo/logo
    if Rails.env != 'production'

      # Include JS assets.
      if options.has_key? :js
        if options[:js]
          out << javascript_include_tag("#{directory}#{filename}/#{options[:js]}")
        end
      else
        if File.exists?("#{file_path}.js") || File.exists?("#{file_path}.js.coffee") || File.exists?("#{file_path}.coffee")
          out << javascript_include_tag("#{directory}#{filename}/#{filename}")
        end
      end

      # Include CSS assets.
      if options.has_key? :css
        if options[:css]
          out << stylesheet_link_tag("#{directory}#{filename}/#{options[:css]}")
        end
      else
        if File.exists?("#{file_path}.css") || File.exists?("#{file_path}.css.scss") || File.exists?("#{file_path}.css.sass") || File.exists?("#{file_path}.scss") || File.exists?("#{file_path}.sass") 
          out << stylesheet_link_tag("#{directory}#{filename}/#{filename}")
        end
      end
    end

    # Render the section partial into the view.
    partial_path = "#{directory_path}/_#{filename}.html"
    if options.has_key? :partial
      if options[:partial] == :tag
        # :partial => :tag given --> render the tag.
        out << content_tag(:div, '', :class => filename)
      elsif options[:partial]
        # some value for :partial given --> render the given partial.
        out << render(:partial => "/../sections/#{directory}#{filename}/#{options[:partial]}", :locals => options[:locals])
      else
        # :partial => false or nil given --> render nothing
      end
    else
      # No :partial option given --> render the file or tag per convention.
      if File.exists?("#{partial_path}.erb") || File.exists?("#{partial_path}.haml")
        out << render(:partial => "/../sections/#{directory}#{filename}/#{filename}", :locals => options[:locals])
      else
        out << content_tag(:div, '', :class => filename)
      end
    end
    out.join("\n").html_safe
  end
  
end

ActionView::Base.send :include, SectionsRails
