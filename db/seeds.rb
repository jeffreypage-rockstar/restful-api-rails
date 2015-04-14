# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# user = CreateAdminService.new.call
# puts 'CREATED ADMIN USER: ' << user.email

users = []

10.times do |n|
  user = User.create(email: "user#{n}@hyper.com",
                     username: "user_#{n}",
                     password: "hyper123")
  users << user
  stack = user.stacks.create(name: "#StackTitle#{n}",
                             description: "Stack description")
  user.cards.create(stack: stack,
                    name: "#CardTitle#{n}",
                    description: "Card description",
                    source: "device",
                    short_id: n)
end
