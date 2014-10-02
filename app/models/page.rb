class Page < ActiveRecord::Base
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = title.to_s.downcase.gsub(/\W/, "-") if slug.blank?
  end
end
