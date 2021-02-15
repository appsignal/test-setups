PadrinoExample::App.controllers do
  # GET /
  get "/" do
    render "root/index"
  end

  # GET /slow
  get "/slow" do
    sleep 2
    render "root/slow"
  end

  # GET /error
  get "/error" do
    raise "error"
  end
end
