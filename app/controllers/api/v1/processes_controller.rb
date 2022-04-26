# frozen_string_literal: true

module Api::V1
  class ProcessesController < Api::V1::BaseController
    has_scope(:product) { |c, s, v| s.for_product(v) }
    has_scope(:machine) { |c, s, v| s.for_machine(v) }
    has_scope(:license) { |c, s, v| s.for_license(v) }
    has_scope(:user) { |c, s, v| s.for_user(v) }
    has_scope(:status) { |c, s, v| s.with_status(v) }

    before_action :scope_to_current_account!
    before_action :require_active_subscription!
    before_action :authenticate_with_token!
    before_action :set_process, only: %i[show update destroy]

    def index
      @processes = apply_pagination(policy_scope(apply_scopes(current_account.machine_processes)).preload(:machine, :license, :policy, :product, :group))
      authorize @processes

      render jsonapi: @processes
    end

    def show
      authorize @process

      render jsonapi: @process
    end

    def create
      @process = current_account.machine_processes.new(process_params)
      authorize @process

      if @process.save
        ProcessHeartbeatWorker.perform_in(
          @process.interval + MachineProcess::HEARTBEAT_DRIFT,
          @process.id,
        )

        BroadcastEventService.call(
          event: 'process.created',
          account: current_account,
          resource: @process,
        )

        render jsonapi: @process, status: :created, location: v1_account_process_url(@process.account, @process)
      else
        render_unprocessable_resource(@process)
      end
    end

    def update
      authorize @process

      if @process.update(process_params)
        BroadcastEventService.call(
          event: 'process.updated',
          account: current_account,
          resource: @process,
        )

        render jsonapi: @process
      else
        render_unprocessable_resource(@process)
      end
    end

    def destroy
      authorize @process

      BroadcastEventService.call(
        event: 'process.deleted',
        account: current_account,
        resource: @process,
      )

      @process.destroy
    end

    private

    def set_process
      scoped_processes = policy_scope(current_account.machine_processes)

      # FIXME(ezekg) We're using an instance variable here instead of an
      #              attr_reader because Rails has an internal process
      #              method that conflicts.
      @process = scoped_processes.find(params[:id])

      Current.resource = @process
    end

    typed_parameters format: :jsonapi do
      options strict: true

      on :create do
        param :data, type: :hash do
          param :type, type: :string, inclusion: %w[process processes]
          param :id, type: :string, optional: true
          param :attributes, type: :hash do
            param :pid, type: :string
            param :metadata, type: :hash, allow_non_scalars: true, optional: true
          end
          param :relationships, type: :hash do
            param :machine, type: :hash do
              param :data, type: :hash do
                param :type, type: :string, inclusion: %w[machine machines]
                param :id, type: :string
              end
            end
          end
        end
      end

      on :update do
        param :data, type: :hash do
          param :type, type: :string, inclusion: %w[process processes]
          param :id, type: :string, inclusion: [controller.params[:id]], optional: true, transform: -> (k, v) { [] }
          param :attributes, type: :hash do
            if current_bearer&.has_role?(:admin, :developer, :sales_agent, :support_agent, :product)
              param :metadata, type: :hash, allow_non_scalars: true, optional: true
            end
          end
        end
      end
    end
  end
end