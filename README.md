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

Create a new Swagr web app:

    swagr create <dir>

and then start the web app with:

    ruby <dir>/app.rb

and then access your web app by opening the browser and going to 0.0.0.0:4000. The default web app has a few simple examples of how to transfer data from a back-end, long-running Ruby computation and display it with a small amount of Coffeescript code that uses d3 to visualise progress. Very rudimentary for now.

After you have checked the default example you can add/removed/modify slim files in <dir>/views and coffescript files in <dir>/coffee and add your own backend and access it from app.rb.

NOTE! This is very early times and most things in Swagr are likely to change. There is no real "design" yet, I needed to get something up and running quickly.