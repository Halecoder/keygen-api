# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe AddUserRelationshipToMachineMigration do
  let(:account)               { create(:account) }
  let(:license_without_owner) { create(:license, :without_owner, account:) }
  let(:license_with_owner)    { create(:license, :with_owner, account:) }

  before do
    RequestMigrations.configure do |config|
      config.current_version = CURRENT_API_VERSION
      config.versions        = {
        '1.0' => [AddUserRelationshipToMachineMigration],
      }
    end
  end

  context "when the machine's license does not have an owner" do
    subject { create(:machine, :without_owner, license: license_without_owner, account:) }

    it 'should migrate a machine user relationship' do
      migrator = RequestMigrations::Migrator.new(from: CURRENT_API_VERSION, to: '1.0')
      data     = Keygen::JSONAPI.render(
        subject,
        api_version: CURRENT_API_VERSION,
        account:,
      )

      expect(data).to include(
        data: include(
          relationships: include(
            owner: {
              data: nil,
              links: {
                related: v1_account_machine_owner_path(subject.account_id, subject.id),
              },
            },
          ).and(
            exclude(
              user: anything,
            ),
          ),
        ),
      )

      migrator.migrate!(data:)

      expect(data).to include(
        data: include(
          relationships: include(
            user: {
              data: nil,
              links: {
                related: v1_account_machine_v1_5_user_path(subject.account_id, subject.id),
              },
            },
          ).and(
            exclude(
              owner: anything,
            ),
          ),
        ),
      )
    end
  end

  context "when the machine's license has an owner" do
    subject { create(:machine, :with_owner, license: license_with_owner, account:) }

    it 'should migrate a machine user relationship' do
      migrator = RequestMigrations::Migrator.new(from: '1.0', to: '1.0')
      data     = Keygen::JSONAPI.render(
        subject,
        api_version: CURRENT_API_VERSION,
        account:,
      )

      expect(data).to include(
        data: include(
          relationships: include(
            owner: {
              data: { type: :users, id: subject.owner_id },
              links: {
                related: v1_account_machine_owner_path(subject.account_id, subject.id),
              },
            },
          ).and(
            exclude(
              user: anything,
            ),
          ),
        ),
      )

      migrator.migrate!(data:)

      expect(data).to include(
        data: include(
          relationships: include(
            user: {
              data: { type: :users, id: subject.license.user_id },
              links: {
                related: v1_account_machine_v1_5_user_path(subject.account_id, subject.id),
              },
            },
          ).and(
            exclude(
              owner: anything,
            ),
          ),
        ),
      )
    end
  end
end
