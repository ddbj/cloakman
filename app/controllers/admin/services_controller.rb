class Admin::ServicesController < ApplicationController
  layout "main"

  before_action :authenticate_admin!

  def index
    @services = Service.all
  end

  def show
    @service = Service.find(params[:id])
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)

    if @service.save
      redirect_to admin_service_path(@service), notice: "Service was successfully created."
    else
      flash.now[:alert] = @service.errors.full_messages_for(:base).join(" ")

      render :new, status: :unprocessable_content
    end
  end

  def destroy
    Service.find(params[:id]).destroy!

    redirect_to admin_services_path, notice: "Service was successfully destroyed."
  end

  private

  def service_params
    params.expect(service: [
      :username
    ])
  end
end
