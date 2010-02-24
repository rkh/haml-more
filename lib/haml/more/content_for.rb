require "haml/more"

module Haml::More::ContentFor
  include Haml::More::AbstractHelper

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
end
