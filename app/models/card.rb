class Card < ActiveRecord::Base
  include Votable
  include Flaggable
  include PublicActivity::Model
  tracked owner: :user, recipient: :stack

  SOURCES = %w(device bing)

  validates :name, :stack, :user, presence: true
  validates :source, inclusion: SOURCES
  attr_readonly :score

  belongs_to :stack, touch: true
  belongs_to :user
  has_many :images, -> { order("position ASC") },
           class_name: "CardImage",
           dependent: :destroy,
           inverse_of: :card
  accepts_nested_attributes_for :images
  has_many :comments

  scope :uploaded, -> { where(uploaded: true) }
  scope :max_score, ->(score) { where("score <= ?", score) }
  scope :newest, -> { order("created_at DESC") }
  scope :best, -> { order("score DESC") }
  scope :up_voted_by, ->(user_id) do
    joins(:up_votes).where("votes.user_id = ?", user_id).
                     order("votes.created_at DESC")
  end

  def to_param
    hash_id
  end

  def hash_id
    reload if persisted? && short_id.blank?
    self.class.hashids.encrypt(short_id)
  end

  def self.find_by_hash_id!(hash_id)
    self.find_by! short_id: hashids.decrypt(hash_id)
  end

  def self.hashids
    @hashids ||= Hashids.new("Hyper card short_id salt")
  end

  def self.popularity
    select("*, hot_score(up_score, down_score, created_at) as rank").
      order("rank DESC, created_at DESC")
  end

  def notification_image_url
    images.first.try(:image_url)
  end

  # ======= SEARCHKICK (ELASTICSEARCH) SETTINGS =========================
  searchkick

  def search_data
    as_json(only: [:name, :stack_id, :user_id, :hot_score, :created_at])
  end

  # scope used to build the index
  def self.search_import
    select("id, name, stack_id, user_id, created_at, "\
      "hot_score(up_score, down_score, created_at) as hot_score").
    order("short_id DESC")
  end
end
