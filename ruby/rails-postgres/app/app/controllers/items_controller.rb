class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  after_action :custom_instrumentation, only: [:index]

  # GET /items
  # GET /items.json
  def index
    Appsignal.add_breadcrumb('Items', 'index', 'Fetching all items')
    @items = Item.all
    Appsignal.add_breadcrumb('Items', 'index', 'Done fetching all items')
  end

  # GET /items/1
  # GET /items/1.json
  def show
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    ItemUpdater.update_all([@item], :attributes => item_params)
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def item_params
    params.require(:item).permit(:name, :description)
  end

  def custom_instrumentation
    Appsignal.instrument('ruby.fiber') do
      f = Fiber.new { puts 1; Fiber.yield; puts 2 }
      Appsignal.instrument('ruby.fiber-resume1') do
        f.resume
      end
      Appsignal.instrument('ruby.fiber-resume2') do
        f.resume
      end
    end
  end
end
