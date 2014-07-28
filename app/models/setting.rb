class Setting < ActiveRecord::Base
  validates :key, presence: true,
                  uniqueness: true,
                  format: { with: /\A[a-z0-9_]*\z/ }


  def name
    key.to_s.humanize    
  end

  def value_enum
    ["enabled", "disabled"]
  end

  class << self
    def [](key)
      Setting.find_by(key: key).try(:value)
    end

    def []=(key, value)
      setting = Setting.find_or_create_by(key: key)
      setting.value = value.to_s
      setting.save!
    end
  end
end
