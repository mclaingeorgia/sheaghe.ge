Madloba
=======
Madloba is a free, open-source solution that connects people who have things to exchange. Each Madloba website uses a map that allows users to visualize at a glance what their neighbours have to give away or what they are looking for.

More information on [madloba.org](http://madloba.org).

### Deployment of Madloba onto a server

To deploy your Madloba instance, follow the steps in [the installation guide](https://github.com/etiennebaque/madloba/wiki/Madloba-installation-guide).

### Development
If you want run Madloba on your local machine, follow these steps:

1. Make sure you have these prerequisites installed:
  - [Git](https://github.com/etiennebaque/madloba/wiki/Install-Git-on-your-local-machine)
  - [Ruby 2.1.2](https://github.com/etiennebaque/madloba/wiki/Install-Ruby-on-your-local-machine)
  - [Bundler gem](http://bundler.io/)
  - [Postgresql](http://www.postgresql.org/download/)

2. Run the following commands:
    ```
    $ git clone git@github.com:etiennebaque/madloba.git
    $ cd madloba && bundle install
    ```
3. Database config: update the settings of your development database, by doing the following:
  - Make a copy of /config/app_environment_variables.rb.sample and name it /config/app_environment_variables.rb.
  - In /config/app_environment_variables.rb, set your database credentials. 

4. Once this is done, create your local database by running:
    ```
    $ bundle exec rake db:setup
    ```
5. That's it, you’re good to go! Start your local server:
    ```
    $ rails s
    ```

### Tests

This project uses [RSpec](https://github.com/rspec/rspec) for testing.

### Demo

Feel free to give Madloba a try at [demo.madloba.org](http://demo.madloba.org). Instructions about this demo can be found [here](https://github.com/etiennebaque/madloba/wiki/Madloba-demo-instructions).

### Contribution

(coming soon)

### License

Madloba is an Open Source Software released under the [GNU Geneal Public License - V2](http://www.gnu.org/licenses/gpl-2.0.html).