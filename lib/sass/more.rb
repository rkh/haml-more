require "sass"

module Sass
  module More
    ::Sass::Script::Functions.send :include, self

    def min(*args)
      args.min { |a, b| a.value <=> b.value }
    end

    def max(*args)
      args.max { |a, b| a.value <=> b.value }
    end

  end
end
