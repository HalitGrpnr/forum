class TopicsController < ApplicationController
  load_and_authorize_resource

  before_action :set_topic, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:new, :edit]

  # GET /topics
  # GET /topics.json
  def index
    @topics = Topic.all.page params[:page]

    respond_to do |format|
      format.json { render json: @topics }
      format.html
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @posts = @topic.posts
    @categories = @topic.categories

    respond_to do |format|
      format.json { render json: @topic }
      format.html
    end
  end

  # GET /topics/new
  def new
    @topic = Topic.new
  end

  # GET /topics/1/edit
  def edit
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = current_user.topics.create(topic_params)

    params[:category_ids].each do |category_id|
      CategoryTopic.create(topic_id: @topic.id, category_id: category_id.to_i)
    end

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: t('topic_created') }
        format.json { render :show, status: :created, location: @topic }
      else
        format.html { render :new }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topics/1
  # PATCH/PUT /topics/1.json
  def update

    params[:category_ids].each do |category_id|
      category = Category.find(category_id.to_i)
      unless @topic.categories.include?(category)
        CategoryTopic.create(topic_id: @topic.id, category_id: category_id.to_i)
      end
    end

    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to @topic, notice: 'Topic was successfully updated.' }
        format.json { render :show, status: :ok, location: @topic }
      else
        format.html { render :edit }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic.destroy
    respond_to do |format|
      format.html { redirect_to topics_url, notice: 'Topic was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def remove_category
    @topic = Topic.friendly.find(params[:topic_id])
    @category = Category.find(params[:category_id])
    CategoryTopic.find_by_topic_id_and_category_id(@topic.id, @category.id).destroy
    respond_to do |format|
      format.js {render "remove"}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      @topic = Topic.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topic_params
      params.require(:topic).permit(:title)
    end

    def set_categories
      @categories = Category.all
    end
end
