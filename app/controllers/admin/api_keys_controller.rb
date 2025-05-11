class Admin::APIKeysController < ApplicationController
  layout "main"

  before_action :authenticate_admin!

  def index
    @keys = APIKey.order(:name)
  end

  def show
    @key = APIKey.find(params.expect(:id))
  end

  def new
    @key = APIKey.new
  end

  def create
    @key = APIKey.new(key_params)

    if @key.save
      redirect_to admin_api_key_path(@key), status: :see_other, notice: "API key was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    APIKey.find(params.expect(:id)).destroy!

    redirect_to admin_api_keys_path, status: :see_other, notice: "API key was successfully destroyed."
  end

  private

  def key_params
    params.expect(api_key: [ :name ])
  end
end
