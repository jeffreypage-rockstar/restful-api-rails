Hyper
=========

Server
---------

The server application requires ruby 2.1 and uses grape and goliath.

* [grape](https://github.com/intridea/grape)
* [goliath](https://github.com/postrank-labs/goliath)

Admin
---------

The admin application is built using rails 4.1.

Development
------------

### setup

You need a .env file in project root folder with some variables assigned. Ask a developer for a valid .env file before continue.

### set the database

Hyper applications use a PostgreSQL database to store data. It also requires the `uuid-ossp` extension to be enabled. To do so, in a Debian-based system run:
    $ sudo apt-get install postgresql-contrib

Create the hyper PostgreSQL user with db create and superuser permissions with:
    $ sudo -u postgres createuser --createdb --pwprompt --superuser hyper

After that, run:

    $ rake db:setup

### run the application

Run the server instance with goliath:

    $ ruby server.rb -sv -p 4000

Run the admin instance with thin:

    $ rails server
    
Testing
--------

All the unit and integration tests are run for admin and api with a single command:

    $ rspec


Production
-----------

You can use [foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html) to start both admin and api application in a single server:

    $ RACK_ENV=production foreman start -c api=3,admin=1
    
The command above starts 3 api server instances with goliath and one instance of puma server. Puma is auto manages the number of works and threads to deal with admin connections. Take a look at [puma config file](config/puma.rb) for settings.