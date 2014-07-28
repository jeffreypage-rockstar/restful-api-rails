class AdminAbility
  include CanCan::Ability

  def initialize(admin)
    can :manage, :all
    cannot :create, Setting
  end
end
