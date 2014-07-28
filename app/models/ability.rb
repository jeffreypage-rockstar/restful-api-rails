class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, :all
    if Setting.enabled?(:read_only_mode) && !user.confirmed?
      cannot :create, :all
      cannot :vote, :all
      cannot :flag, :all
    end
  end
end
