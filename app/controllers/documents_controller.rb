class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: [:show, :download]

  def index
    @documents = current_user.documents
  end

  def new
    @document = Document.new
  end

  def create
    @document = current_user.documents.build(document_params) 

    if @document.save
      redirect_to documents_path, notice: "Document uploaded successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # optionally display document info or preview
  end

  def download
    # send the file as attachment
    if @document.file.attached?
      redirect_to rails_blob_url(@document.file, disposition: "attachment")
    else
      redirect_to documents_path, alert: "File not found."
    end
  end

  private

  def set_document
    @document = current_user.documents.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title, :file)
  end
end
