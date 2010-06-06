require "haml"
require "sass/more"
require "monkey"

module Haml
  module More

    # skip autoload lines
    extend Monkey::Autoloader

    # Base class for all all Haml helper
    module AbstractHelper
      module ClassMethods
        def registered(klass)
          klass.helpers self
        end
      end

      def self.included(klass)
        klass.extend ClassMethods
        super
      end

      include Haml::Helpers

      # Will make use of capture_haml depending on whether it is called from
      # within Haml code or not. Thus helpers may be shared between Haml and
      # others (like ERB), but still enjoy all the fancy Haml::Helpers tools.
      def haml_helper(&block)
        return capture_haml(&block) unless is_haml?
        yield
      end

    end

    def self.included(klass)
      Haml::More::CoffeeScript.activate
      klass.send :include, Haml::More::ContentFor, Haml::More::Javascript
      super
    end

    ::Sinatra.helpers self if defined? ::Sinatra

  end
end