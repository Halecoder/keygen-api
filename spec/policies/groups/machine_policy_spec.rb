# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe Groups::MachinePolicy, type: :policy do
  subject { described_class.new(record, account:, bearer:, token:, group:) }

  with_role_authorization :admin do
    with_scenarios %i[accessing_a_group accessing_its_machines] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_machine] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show
          end

          allows :show
        end

        with_default_permissions do
          without_token_permissions do
            denies :show
          end

          allows :show
        end

        without_permissions do
          denies :show
        end
      end
    end

    with_scenarios %i[accessing_another_account accessing_a_group accessing_its_machines] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_another_account accessing_a_group accessing_its_machine] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          denies :show
        end

        with_wildcard_permissions do
          denies :show
        end

        with_default_permissions do
          denies :show
        end

        without_permissions do
          denies :show
        end
      end
    end
  end

  with_role_authorization :product do
    with_scenarios %i[accessing_a_group accessing_its_machines] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_machine] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          allows :show
        end

        with_default_permissions do
          allows :show
        end

        without_permissions do
          denies :show
        end
      end
    end
  end

  with_role_authorization :license do
    with_scenarios %i[accessing_its_group accessing_its_machines] do
      with_token_authentication do
        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_its_group accessing_its_machine] do
      with_license_authentication do
        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end

      with_token_authentication do
        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_machines] do
      with_token_authentication do
        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_machine] do
      with_license_authentication do
        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end

      with_token_authentication do
        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end
    end
  end

  with_role_authorization :user do
    with_scenarios %i[accessing_a_group as_group_owner accessing_its_machines] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group as_group_owner accessing_its_machine] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          allows :show
        end

        with_default_permissions do
          allows :show
        end

        without_permissions do
          denies :show
        end
      end
    end

    with_scenarios %i[accessing_its_group accessing_its_machines] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :index }

          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_its_group accessing_its_machine] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :show }

          denies :show
        end

        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_machines] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :index }

          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_machine] do
      with_token_authentication do
        with_permissions %w[group.machines.read] do
          without_token_permissions { denies :show }

          denies :show
        end

        with_wildcard_permissions { denies :show }
        with_default_permissions  { denies :show }
        without_permissions       { denies :show }
      end
    end
  end

  without_authorization do
    with_scenarios %i[accessing_a_group accessing_its_machines] do
      without_authentication { denies :index }
    end

    with_scenarios %i[accessing_a_group accessing_its_machine] do
      without_authentication { denies :show }
    end
  end
end
