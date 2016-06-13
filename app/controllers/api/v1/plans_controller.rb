module Api::V1
  class PlansController < Api::V1::BaseController
    has_scope :page, type: :hash

    before_action :authenticate_with_token!, only: [:create, :update, :destroy]
    before_action :set_plan, only: [:show, :update, :destroy]

    # GET /plans
    def index
      @plans = Plan.all
      authorize @plans

      render json: @plans
    end

    # GET /plans/1
    def show
      authorize @plan

      render json: @plan
    end

    # POST /plans
    def create
      @plan = Plan.new plan_params
      authorize @plan

      if @plan.save
        render json: @plan, status: :created, location: v1_plan_url(@plan)
      else
        render json: @plan, status: :unprocessable_entity, adapter: :json_api, serializer: ActiveModel::Serializer::ErrorSerializer
      end
    end

    # PATCH/PUT /plans/1
    def update
      authorize @plan

      if @plan.update(plan_params)
        render json: @plan
      else
        render json: @plan, status: :unprocessable_entity, adapter: :json_api, serializer: ActiveModel::Serializer::ErrorSerializer
      end
    end

    # DELETE /plans/1
    def destroy
      authorize @plan

      @plan.destroy
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find_by_hashid params[:id]
      @plan || render_not_found
    end

    # Only allow a trusted parameter "white list" through.
    def plan_params
      params.require(:plan).permit :name, :price, :max_products, :max_users, :max_policies, :max_licenses
    end
  end
end
