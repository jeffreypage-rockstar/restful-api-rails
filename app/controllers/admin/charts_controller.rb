class Admin
  class ChartsController < ApplicationController
    before_filter :authenticate_admin!
    USER_LIMIT = 30

    def users
      klass = Stats.group(:date).limit(USER_LIMIT).latest

      render json: [{ name: "New Users", data: klass.sum(:users) },
                    { name: "Deleted Users", data: klass.sum(:deleted_users) }]
    end
  end
end
