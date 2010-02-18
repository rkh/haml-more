require "haml"
require "sass/more"

module Haml
  module More
    include Haml::Helpers
    Sinatra.helpers self if defined? Sinatra

    def self.registered(klass)
      klass.helpers self
    end

    def content_for(name, &block)
      name = name.to_s
      @content_for ||= Hash.new {|h,k| h[k] = [] }
      @content_for[name] << block if block
      @content_for[name]
    end

    def yield_content(name, *args)
      haml_helper do
        content_for(name).each do |block|
          result = block.call(*args)
          haml_concat result unless block_is_haml? block
        end
      end
    end

    def get_content(name, *args)
      non_haml { yield_content(name, *args) }
    end

    private

    # Will make use of capture_haml depending on whether it is called from
    # within Haml code or not. Thus helpers may be shared between Haml and
    # others (like ERB), but still enjoy all the fancy Haml::Helpers tools.
    def haml_helper(&block)
      return capture_haml(&block) unless is_haml?
      yield
    end

  end
end