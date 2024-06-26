require "grape"
require "appsignal/integrations/grape"

# In memory database for posts
class Posts
  class << self
    def max_post_id
      all.map { |post| post[:id] }.max
    end

    def all
      @posts ||= [
        { :id => 1, :title => "Post 1." },
        { :id => 2, :title => "Post 2." },
        { :id => 3, :title => "Post 3." }
      ]
    end

    def find_by_id(id)
      all.find { |post| post[:id] == id }
    end
  end
end

module MyApp
  class BaseAPI < Grape::API
    insert_before Grape::Middleware::Error, Appsignal::Grape::Middleware
  end

  class PostsAPI < BaseAPI
    version "v1", :using => :header, :vendor => :unknown
    format :json
    prefix :api

    resource :posts do
      desc "Return a list of posts."
      get do
        Posts.all
      end

      desc "Return a post."
      params do
        requires :id, :type => Integer, :desc => "Post ID."
      end
      route_param :id do
        get do
          Posts.find_by_id(params[:id])
        end
      end

      desc "Create a post."
      params do
        requires :title, :type => String, :desc => "Post title"
      end
      post do
        post_id = Posts.max_post_id + 1
        post = { :id => post_id, :title => params[:title] }
        Posts.all << post
        post
      end

      desc "Update a post."
      params do
        requires :id, :type => Integer, :desc => "Post ID."
        requires :title, :type => String, :desc => "Post title"
      end
      put ":id" do
        post = Posts.find_by_id(params[:id])
        post[:title] = params[:title]
        post
      end

      desc "Delete a post."
      params do
        requires :id, :type => Integer, :desc => "Post ID."
      end
      delete ":id" do
        unless Posts.find_by_id(params[:id])
          raise "Post with id '#{params[:id]}' not found!"
        end
        Posts.all.delete_if { |post| post[:id] == params[:id] }
      end
    end
  end

  class API < BaseAPI
    version "v1", :using => :header, :vendor => :unknown
    content_type :html, "text/html"
    format :html
    mount PostsAPI

    desc "Index page"
    get do
      posts_list = []
      Posts.all.each do |post|
        posts_list << <<~HTML
          <li>
            <strong><a href="/api/posts/#{post[:id]}">Posts API show: #{post[:title]}</a></strong>
            <div>
              <div>Update command:</div>
              <code>curl -X PUT -d '{"title":"Updated post #{post[:id]}!"}' -H Content-Type:application/json http://localhost:4001/api/posts/#{post[:id]}</code>
            </div>
            <br>
            <div>
              <div>Delete command:</div>
              <code>curl -X DELETE -H Content-Type:application/json http://localhost:4001/api/posts/#{post[:id]}</code>
            </div>
          </li>
        HTML
      end
      <<~HTML
        <h1>Grape example app</h1>
        <ul>
          <li><a href="/slow">Slow request</a></li>
          <li><a href="/error">Error request</a></li>
          <li><a href="/api/posts">Posts API index <code>/api/posts</code></a></li>
        </ul>

        <h2>Posts</h2>
        <div>Create new Post command:</div>
        <code>curl -X POST -d '{"title":"New post #{Posts.max_post_id + 1}!"}' -H Content-Type:application/json http://localhost:4001/api/posts</code>

        <ul>
          #{posts_list.join}
        </ul>
      HTML
    end

    get "/slow" do
      sleep 3
      "Well that was slow"
    end

    get "/error" do
      raise "Error from a Grape app"
    end
  end
end
