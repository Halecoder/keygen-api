# frozen_string_literal: true

class MachineProcessPolicy < ApplicationPolicy
  def index?
    verify_permissions!('process.read')
    verify_environment!(
      strict: false,
    )

    case bearer
    in role: Role(:admin | :developer | :sales_agent | :support_agent | :read_only | :environment)
      allow!
    in role: Role(:product) if record.all? { _1.product == bearer }
      allow!
    in role: Role(:user) if record.all? { _1.user == bearer }
      allow!
    in role: Role(:license) if record.all? { _1.license == bearer }
      allow!
    else
      deny!
    end
  end

  def show?
    verify_permissions!('process.read')
    verify_environment!(
      strict: false,
    )

    case bearer
    in role: Role(:admin | :developer | :sales_agent | :support_agent | :read_only | :environment)
      allow!
    in role: Role(:product) if record.product == bearer
      allow!
    in role: Role(:user) if record.user == bearer
      allow!
    in role: Role(:license) if record.license == bearer
      allow!
    else
      deny!
    end
  end

  def create?
    verify_permissions!('process.create')
    verify_environment!

    case bearer
    in role: Role(:admin | :developer | :sales_agent | :environment)
      allow!
    in role: Role(:product) if record.product == bearer
      allow!
    in role: Role(:user) if record.user == bearer
      !record.license&.protected?
    in role: Role(:license) if record.license == bearer
      allow!
    else
      deny!
    end
  end

  def update?
    verify_permissions!('process.update')
    verify_environment!

    case bearer
    in role: Role(:admin | :developer | :sales_agent | :support_agent | :environment)
      allow!
    in role: Role(:product) if record.product == bearer
      allow!
    in role: Role(:user) if record.user == bearer
      !record.license.protected?
    in role: Role(:license) if record.license == bearer
      allow!
    else
      deny!
    end
  end

  def destroy?
    verify_permissions!('process.delete')
    verify_environment!

    case bearer
    in role: Role(:admin | :developer | :sales_agent | :environment)
      allow!
    in role: Role(:product) if record.product == bearer
      allow!
    in role: Role(:user) if record.user == bearer
      !record.license.protected?
    in role: Role(:license) if record.license == bearer
      allow!
    else
      deny!
    end
  end
end
