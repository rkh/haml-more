require 'haml/more'
require 'forwardable'

module Haml::More::Javascript
  class Pattern
    attr_accessor :pattern, :default_version

    def self.google(default_version = 1, minified = false)
      new "http://ajax.googleapis.com/ajax/libs/%1$s/%2$s/%1$s#{'.min' if minified}.js",
      default_version
    end

    def new(pattern, default_version = 1)
      return super if pattern.respond_to? :to_str
      send(pattern, default_version)
    end

    def initialize(pattern, default_version = 1)
      @pattern, @default_version = pattern, default_version
    end

    def %(values)
      pattern.gsub("%V", "%2$s") % [values[0], values[1] || default_version, *values[2..-1]]
    end
  end

  module ClassMethods
    # here is an idea: map to hash, store in haml file
    DEFAULTS = [
      # http://code.google.com/apis/ajaxlibs/documentation/
      # lib,            pattern,  v,  min
      [ :jquery,        :google,  1,  true  ],
      [ :jqueryui,      :google,  1,  true  ],
      [ :prototype,     :google,  1         ],
      [ :scriptaculous, :google,  1         ],
      [ :mootools,      :google,  1,  true  ],
      [ :dojo,          :google,  1,  true  ],
      [ :swfobject,     :google,  2,  true  ],
      [ :yui,           :google,  2,  true  ], # for 3.x, see below
      [ "ext-core",     :google,  3         ],
      [ :webfont,       :google,  1         ],

      # others
      [ "chrome-frame",   "http://ajax.googleapis.com/ajax/libs/chrome-frame/%V/CFInstall.min.js"             ],
      [ :modernizr,       "http://github.com/Modernizr/Modernizr/raw/v%V/modernizr.js",               '1.1'   ],
      [ :hyphenator,      "http://hyphenator.googlecode.com/svn/tags/Version%%20%V/Hyphenator.js",    '3.0.0' ],
      [ :yui3,            "http://yui.yahooapis.com/combo?%V/build/yui/yui-min.js",                   '3.1.1' ],
      [ :sizzle,          "http://github.com/jeresig/sizzle/raw/master/sizzle.js"                             ],
      [ :underscore,      "http://github.com/documentcloud/underscore/raw/%V/underscore-min.js",      '1.0.2' ],
      [ :raphael,         "http://github.com/DmitryBaranovskiy/raphael/raw/v%V/raphael-min.js",       '1.4.3' ],
      [ :cufon,           "http://cufon.shoqolate.com/js/cufon-yui.js"                                        ],
      [ "coffee-script",  "http://github.com/jashkenas/coffee-script/raw/%V/extras/coffee-script.js", '0.6.2' ],
      [ :sammy,           "http://github.com/quirkey/sammy/raw/v%V/lib/min/sammy-%V.min.js",          '0.5.4' ]
    ]

    def included(klass)
      klass.send :include, Haml::More::JavaScript::InstanceMethods
      super
    end

    def javascript_default_pattern
      @javascript_default_pattern ||= Haml::More::JavaScript::Pattern.google
    end

    def javascript_guessing?
      true
    end

    def javascript_url_for(name, version = nil, *args)
      return javascript_url_map[name] % [name, version, *args] if javascript_url_map.includes? name
      javascript_default_pattern % [name, version, *args] if javascript_guessing?
    end

    def set_javascript(name, *args)
      javascript_url_map[name.to_s] = Haml::More::JavaScript::Pattern.new(*args)
    end

    def javascript_url_map
      return @javascript_url_map if @javascript_url_map
      @javascript_url_map = Hash.new { |h,k| h[k.to_s] unless k.respond_to? :to_str }
      DEFAULTS.each { |args| set_javascript(*args) }
    end
  end

  module InstanceMethods
    include Haml::More::AbstractHelper

    def javascript(*list)
      return javascript(list) if list.size == 2 and list.last.to_s =~ /^\d[\.\d]*$/
      haml_helper do
        list.each do |entry|
          entry = entry.to_a if entry.respond_to? to_a
          haml_tag :script, :type => "text/javascript", :src => self.class.javascript_url_for(*entry)
        end
      end
    end
  end

  def self.append_features(klass)
    klass.extend ClassMethods
  end
end
