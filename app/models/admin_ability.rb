class AdminAbility
  include CanCan::Ability

  def initialize(_admin)
    can :manage, :all
    cannot :create, Setting
  end
end
