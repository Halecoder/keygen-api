# frozen_string_literal: true

module Users
  class GroupPolicy < ApplicationPolicy
    authorize :user

    def show?
      verify_permissions!('group.read')

      case bearer
      in role: { name: 'admin' | 'developer' | 'sales_agent' | 'support_agent' | 'read_only' }
        allow!
      in role: { name: 'product' } if user.user?
        allow!
      in role: { name: 'user' } if user == bearer
        allow!
      else
        deny!
      end
    end

    def update?
      verify_permissions!('user.group.update')

      case bearer
      in role: { name: 'admin' | 'developer' | 'sales_agent' }
        allow!
      in role: { name: 'product' } if user.user?
        allow!
      else
        deny!
      end
    end
  end
end