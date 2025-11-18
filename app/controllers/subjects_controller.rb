class SubjectsController < ApplicationController
  before_action :set_subject, only: %i[edit update destroy]

  def index
    @subjects = Subject.all.order(:name)
  end

  def new
    @subject = Subject.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      @subjects = Subject.all.order(:name)
      respond_to do |format|
        flash[:notice] = 'Tema creado correctamente'
        format.turbo_stream
        format.html { redirect_to destinations_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_create }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @subject.update(subject_params)
      respond_to do |format|
        flash[:notice] = 'Tema actualizado correctamente'
        format.turbo_stream
        format.html { redirect_to subjects_path, notice: 'Tema actualizado con éxito.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_update }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @subject.destroy
    respond_to do |format|
      @show_empty = Subject.none?
      @subjects = Subject.all.order(:name)

      flash[:info] = 'Tema eliminado correctamente'
      format.turbo_stream
      format.html { redirect_to subjects_path, notice: 'Tema eliminado con éxito.' }
    end
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :priority)
  end
end
