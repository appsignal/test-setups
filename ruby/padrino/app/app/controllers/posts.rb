PadrinoExample::App.controllers :posts do
  # GET /posts
  get "/" do
    render :index
  end

  # GET /posts/slow
  get "/slow" do
    sleep 2
    render :slow
  end

  # GET /posts/error
  get "/error" do
    raise "error"
  end

  # GET /posts/action1/:id
  # get :action1, with: :id do
  get "/action1/:id" do
    "Posts action1 #{params[:id]}"
  end

  # GET /posts/action2
  get :posts_action2, :map => "/posts/action2" do
    %(Maps to `:posts_action2`, with static url "/posts/action2")
  end

  # GET /posts/action/:id
  get :action3, :with => :id do
    %(Maps to `:posts`, with dynamic url "/posts/action3/:id" => "/posts/action3/#{params[:id]}")
  end
end

