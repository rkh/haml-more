Haml::More and Sass::More
=========================

Adds more functionality to Haml and Sass.

BigBand
-------

Haml::More and Sass::More are part of the [BigBand](http://github.com/rkh/big_band) stack.
Check it out if you are looking for fancy Sinatra extensions.

Haml extensions
---------------

* `content_for` and `yield_content` (like in Rails, you know?)

        // some_file.haml
        = yield_content(:foo)
        .content
          = haml :another_file
        
        // another_file.haml
        - content_for(:foo)
          %b bar
        .something
          %h1 cool, huh?

* adds `:coffee_script` for inline [CoffeeScript](http://jashkenas.github.com/coffee-script/)

        %head
          %title CoffeScript example
          :coffee_script
            if happy and knows_it
              claps_hands()
              cha_cha_cha()
        %body
          content

SassScript extensions
---------------------

* `min` and `max`

        .someClass
          width = max(100px, !someSize * 3)
          height = min(!a, !b, 20%)

Usage with Sinatra
------------------

Classic style:

    require "sinatra"
    require "haml/more"

Modular:

    require "sinatra/base"
    require "haml/more"
    
    class Foo < Sinatra::Base
      helpers Haml::More
    end


Usage without Sinatra
---------------------

Using just Sass::More (if you're in Merb or Rails):

    # in some initializer or something
    require "sass/more"

Without anything:

    require "haml/more"
    scope = Object.new
    scope.extend Haml::More
    puts Haml::Engine.new("%p some haml code").render(scope)
