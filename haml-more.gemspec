SPEC = Gem::Specification.new do |s|

  # Get the facts.
  s.name             = "haml-more"
  s.version          = "0.4.0"
  s.description      = "Adds more functionality to Haml and Sass (part of BigBand)."

  # BigBand depedencies
  s.add_dependency "monkey-lib", "~> #{s.version}"

  # External dependencies
  s.add_dependency "haml", ">= 2.2.20"
  s.add_development_dependency "rspec", ">= 1.3.0"

  # Those should be about the same in any BigBand extension.
  s.authors          = ["Konstantin Haase"]
  s.email            = "konstantin.mailinglists@googlemail.com"
  s.files            = Dir["**/*.{rb,md}"] + Dir["vendor/**/*"] << "LICENSE"
  s.has_rdoc         = 'yard'
  s.homepage         = "http://github.com/rkh/#{s.name}"
  s.require_paths    = ["lib"]
  s.summary          = s.description
  
end
