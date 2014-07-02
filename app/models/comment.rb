class Comment < ActiveRecord::Base
  validates :user, :card, :presence => true
  
  belongs_to :user
  belongs_to :card
  belongs_to :replying, :class_name => "Card"
  
  store_accessor :mentions
  
  before_save :extract_mentions
  
  private #===============================================================
  
  def extract_mentions
    usernames = self.body.scan(/@([[:alnum:].]+)/i).flatten
    users = User.where(username: usernames)
    self.mentions = users.inject({}) do |hash,item|
      hash[item.username] = item.id
      hash
    end
  end
end
