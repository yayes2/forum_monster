require 'rails/generators'
require 'rails/generators/migration'

class Community::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  desc "Installs the Community Forum Engine."
  
  argument :user_model, :type => :string, :required => true, :desc => "Your user model name."
  
  attr_reader :singular_camel_case_name, :plural_camel_case_name, :singular_lower_case_name, :plural_lower_case_name
  
  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end
  
  # Generate the migration timestamp
  
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_controllers
    template "controllers/forums_controller.rb", "app/controllers/forums_controller.rb"
    template "controllers/topics_controller.rb", "app/controllers/topics_controller.rb"
    template "controllers/posts_controller.rb", "app/controllers/posts_controller.rb"
  end

  def create_models
    @singular_camel_case_name = user_model.singularize.camelize
    @plural_camel_case_name = user_model.pluralize.camelize
    @singular_lower_case_name = user_model.singularize.underscore
    @plural_lower_case_name = user_model.pluralize.underscore
  	
  	template "models/forum.rb", "app/models/forum.rb"
    template "models/topic.rb", "app/models/topic.rb"
    template "models/post.rb", "app/models/post.rb"
  end

  def create_views
    directory "views/forums", "app/views/forums"
    directory "views/topics", "app/views/topics"
    directory "views/posts", "app/views/posts"
    template  "public/stylesheets/community.css", "public/stylesheets/community.css"
    template  "public/images/ruby.png", "public/images/ruby.png"
  end

  def create_migrations
    migration_template 'migrations/forums.rb', 'db/migrate/create_forums_table.rb'
    sleep(1)
    migration_template 'migrations/topics.rb', 'db/migrate/create_topics_table.rb'
    sleep(1)
    migration_template 'migrations/posts.rb', 'db/migrate/create_posts_table.rb'
    sleep(1)
    migration_template 'migrations/user.rb', 'db/migrate/update_users_table.rb'
  end
  
  def create_routes
    route "resources :forums do
    resources :topics, :shallow => true, :except => :index do
      resources :posts, :shallow => true, :except => [:index, :show]
    end
  end"
  end
end