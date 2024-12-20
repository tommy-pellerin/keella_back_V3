class CategoriesController < ApplicationController
  before_action :authenticate_user!, except: %i[ index ]
  before_action :set_category, only: %i[ show update destroy ]
  before_action :authorize_admin!, only: %i[ show create update destroy ]

  # GET /categories
  def index
    @categories = Category.all

    render json: @categories
  end

  # GET /categories/1
  def show
    render json: @category
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    if @category.save
      render json: @category, status: :created, location: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      render json: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /categories/1
  def destroy
    if @category.destroy
      render json: { message: "Category deleted successfully." }, status: :ok
    else
      render json: { error: "Failed to delete category" }, status: :unprocessable_entity
    end
  end

  private

  def authorize_admin!
    render json: { error: "Vous n'êtes pas administrateur, vous ne pouvez acceder à cette page." }, status: :unauthorized unless current_user.is_admin?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def category_params
    params.require(:category).permit(:title)
  end
end
