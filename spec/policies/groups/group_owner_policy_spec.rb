# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe Groups::GroupOwnerPolicy, type: :policy do
  subject { described_class.new(record, account:, bearer:, token:, group:) }

  with_role_authorization :admin do
    with_scenarios %i[accessing_a_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[group.owners.attach] do
          allows :attach
        end

        with_permissions %w[group.owners.detach] do
          allows :detach
        end

        with_wildcard_permissions do
          without_token_permissions do
            denies :show, :attach, :detach
          end

          allows :show, :attach, :detach
        end

        with_default_permissions do
          without_token_permissions do
            denies :show, :attach, :detach
          end

          allows :show, :attach, :detach
        end

        without_permissions do
          denies :show, :attach, :detach
        end
      end
    end

    with_scenarios %i[accessing_another_account accessing_a_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_another_account accessing_a_group accessing_its_owner] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          denies :show
        end

        with_permissions %w[group.owners.attach] do
          denies :attach
        end

        with_permissions %w[group.owners.detach] do
          denies :detach
        end

        with_wildcard_permissions do
          denies :show, :attach, :detach
        end

        with_default_permissions do
          denies :show, :attach, :detach
        end

        without_permissions do
          denies :show, :attach, :detach
        end
      end
    end
  end

  with_role_authorization :product do
    with_scenarios %i[accessing_a_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_permissions %w[group.owners.attach] do
          allows :attach
        end

        with_permissions %w[group.owners.detach] do
          allows :detach
        end

        with_wildcard_permissions do
          allows :show, :attach, :detach
        end

        with_default_permissions do
          allows :show, :attach, :detach
        end

        without_permissions do
          denies :show, :attach, :detach
        end
      end
    end
  end

  with_role_authorization :license do
    with_scenarios %i[accessing_its_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_its_group accessing_its_owners] do
      with_license_authentication do
        with_permissions %w[group.owners.read] do
          allows :show
        end

        with_wildcard_permissions do
          denies :attach, :detach
          allows :show
        end

        with_default_permissions do
          denies :attach, :detach
          allows :show
        end

        without_permissions do
          denies :attach, :detach
          denies :show
        end
      end

      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          denies :attach, :detach
          allows :show
        end

        with_default_permissions do
          denies :attach, :detach
          allows :show
        end

        without_permissions do
          denies :attach, :detach
          denies :show
        end
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :index }

          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_owners] do
      with_license_authentication do
        with_permissions %w[group.owners.read] do
          denies :show
        end

        with_wildcard_permissions do
          denies :show, :attach, :detach
        end

        with_default_permissions do
          denies :show, :attach, :detach
        end

        without_permissions do
          denies :show, :attach, :detach
        end
      end

      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :show }

          denies :show
        end

        with_wildcard_permissions do
          denies :show, :attach, :detach
        end

        with_default_permissions do
          denies :show, :attach, :detach
        end

        without_permissions do
          denies :show, :attach, :detach
        end
      end
    end
  end

  with_role_authorization :user do
    with_scenarios %i[accessing_a_group as_group_owner accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group as_group_owner accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          denies :attach, :detach
          allows :show
        end

        with_default_permissions do
          denies :attach, :detach
          allows :show
        end

        without_permissions do
          denies :attach, :detach
          denies :show
        end
      end
    end

    with_scenarios %i[accessing_its_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :index }

          allows :index
        end

        with_wildcard_permissions { allows :index }
        with_default_permissions  { allows :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_its_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :show }

          allows :show
        end

        with_wildcard_permissions do
          denies :attach, :detach
          allows :show
        end

        with_default_permissions do
          denies :attach, :detach
          allows :show
        end

        without_permissions do
          denies :attach, :detach
          denies :show
        end
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :index }

          denies :index
        end

        with_wildcard_permissions { denies :index }
        with_default_permissions  { denies :index }
        without_permissions       { denies :index }
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_owners] do
      with_token_authentication do
        with_permissions %w[group.owners.read] do
          without_token_permissions { denies :show }

          denies :show
        end

        with_wildcard_permissions do
          denies :show, :attach, :detach
        end

        with_default_permissions do
          denies :show, :attach, :detach
        end

        without_permissions do
          denies :show, :attach, :detach
        end
      end
    end
  end

  without_authorization do
    with_scenarios %i[accessing_a_group accessing_its_owners] do
      without_authentication do
        denies :index
      end
    end

    with_scenarios %i[accessing_a_group accessing_its_owners] do
      without_authentication do
        denies :show, :attach, :detach
      end
    end
  end
end
