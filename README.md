# Swagr

Simple web app skeleton creator for Ruby based on Sinatra, Slim, Coffeescript and d3.

## Installation

Install yourself as:

    $ gem install swagr

or add this line to your application's Gemfile:

    gem 'swagr'

And then execute:

    $ bundle

## Usage

Create a new Swagr web app in the directory <dir>:

    swagr create <dir>

and then you can add/removed/modify slim files in <dir>/views and coffescript files in <dir>/coffee. The standard setup includes simple examples of how to get basic communication from the Ruby program into the web app gui and how to update d3 graph components based on changes.