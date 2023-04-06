class GlobusTokensController < ApplicationController
  before_action :set_globus_token, only: %i[ show edit update destroy ]

  # GET /globus_tokens or /globus_tokens.json
  def index
    @globus_tokens = GlobusToken.all
  end

  # GET /globus_tokens/1 or /globus_tokens/1.json
  def show
  end

  # GET /globus_tokens/new
  def new
    @globus_token = GlobusToken.new
  end

  # GET /globus_tokens/1/edit
  def edit
  end

  # POST /globus_tokens or /globus_tokens.json
  def create
    @globus_token = GlobusToken.new(globus_token_params)

    respond_to do |format|
      if @globus_token.save
        format.html { redirect_to globus_token_url(@globus_token), notice: "Globus token was successfully created." }
        format.json { render :show, status: :created, location: @globus_token }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @globus_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /globus_tokens/1 or /globus_tokens/1.json
  def update
    respond_to do |format|
      if @globus_token.update(globus_token_params)
        format.html { redirect_to globus_token_url(@globus_token), notice: "Globus token was successfully updated." }
        format.json { render :show, status: :ok, location: @globus_token }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @globus_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /globus_tokens/1 or /globus_tokens/1.json
  def destroy
    @globus_token.destroy

    respond_to do |format|
      format.html { redirect_to globus_tokens_url, notice: "Globus token was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_globus_token
      @globus_token = GlobusToken.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def globus_token_params
      params.require(:globus_token).permit(:access_token, :expires_in, :body)
    end
end
