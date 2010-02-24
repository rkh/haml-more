require "haml/more"
require "monkey"

module Haml::More::CoffeeScript
  include Haml::Filters::Base

  # Also allow :coffee_script besides :coffeescript
  Haml::Filters.defined["coffee_script"] = self

  class Compiler
    attr_accessor :coffee_directory, :coffee_url

    def self.available_compilers
      @available_compilers ||= []
    end

    def self.inherited(klass)
      Compiler.available_compilers << klass
    end

    def self.new(*args)
      return super unless self == Compiler
      available_compilers.each do |klass|
        klass.new(*args).tap { |c| return c if c.available? }
      end
      raise RuntimeError, "no compiler available (should not happen!)"
    end

    def initialize(*args)
      @available = true
      @coffee_directory = File.expand_path "../../../../vendor/coffee-script", __FILE__
      @coffee_url = "http://jashkenas.github.com/coffee-script"
    end

    def dependencies(prefix = nil)
      @dependencies ||= %w[rewriter lexer parser scope nodes].map { |l| "lib/#{l}.js" }
      prefix ? @dependencies.map { |file| prefix / file } : @dependencies
    end

    def files
      dependencies coffee_directory
    end

    def urls
      dependencies coffee_url
    end

    def javascript(text)
      Haml::Filters::Javascript.render_with_options text, :attr_wrapper => "'"
    end

    def compile_statement(text)
      "CoffeeScript.compile(#{text.inspect}, {no_wrap: true});"
    end

    def available?
      !!@available
    end

    def not_available!
      @available = false
    end
  end

  class JohnsonCompiler < Compiler
    attr_accessor :runtime
    def initialize(runtime = nil)
      super
      require "johnson"
      @runtime = runtime || Johnson::Runtime.new
      prepare_runtime
    rescue LoadError
      not_available!
    end
    
    def available?
      # CoffeeScript currently not working properly on Spidermonkey
      false
    end

    def prepare_runtime
      runtime.load(*files)
    end

    def render(text)
      runtime.evaluate compile_statement(text)
    end
  end

  class NodeCompiler < Compiler
    attr_accessor :command
    def initialize(command = nil)
      super
      @command = `which #{command || "node"}`.strip
      not_available! if @command.empty?
    end

    def render(text)
      sanitized = text.inspect.gsub("\\n", "\n").gsub("\\r", "\r")
      javascript `#{command} #{coffee_directory}/bin/coffee -p -e #{sanitized}`
    end
  end

  class ClientCompiler < Compiler
    def initialize
      @script_tag = "<script type=\"text/javascript\" src=%s></script>\n"
      super
    end
    
    attr_accessor :skip_scripts, :script_tag
    def skip_scripts?
      !!@skip_scripts
    end

    def render(text)
      result = ""
      urls.each { |u| result << (script_tag % u.inspect) } unless skip_scripts?
      result << javascript("eval(#{compile_statement(text)})")
    end
  end

  class << self
    attr_writer :compiler
    def compiler
      @compiler ||= Compiler.new
    end
  end

  def render(text)
    Haml::More::CoffeeScript.compiler.render text
  end
end
