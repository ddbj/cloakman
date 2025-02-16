class Admin::ReadersController < ApplicationController
  layout "main"

  before_action :authenticate_admin!

  def index
    @readers = Reader.all
  end

  def show
    @reader = Reader.find(params[:id])
  end

  def new
    @reader = Reader.new
  end

  def create
    @reader = Reader.new(reader_params)

    if @reader.save
      flash[:password] = @reader.password

      redirect_to admin_reader_path(@reader), notice: "Reader created successfully."
    else
      flash.now[:alert] = @reader.errors.full_messages_for(:base).join(" ")

      render :new, status: :unprocessable_content
    end
  end

  def destroy
    Reader.find(params[:id]).destroy!

    redirect_to admin_readers_path, notice: "Reader deleted successfully."
  end

  private

  def reader_params
    params.expect(reader: [
      :id
    ])
  end
end
