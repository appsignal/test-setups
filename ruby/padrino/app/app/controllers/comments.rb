PadrinoExample::App.controllers :comments, :parent => :posts do
  # GET /posts/:id/comments
  get "/" do
    "Hello comments!"
  end

  # GET /posts/:id/comments/slow
  get "/slow" do
    sleep 1
    "ZzZzZzZz"
  end

  # GET /posts/:id/comments/error
  get "/error" do
    raise "error"
  end
end
