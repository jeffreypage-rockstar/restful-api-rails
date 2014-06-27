require 'rails_helper'

RSpec.describe Card, type: :model do

  describe '.create' do
    let(:stack) { create(:stack) }

    let(:attrs) do
      {
        name: 'My Card Title',
        description: 'My card description',
        stack: stack,
        user: stack.user
      }
    end

    it 'creates a valid card' do
      expect(Card.new(attrs)).to be_valid
    end

    it 'requires a name' do
      stack = Card.new(attrs.merge(name: ''))
      expect(stack).to_not be_valid
    end

    it 'requires a user_id' do
      stack = Card.new(attrs.merge(user: nil))
      expect(stack).to_not be_valid
    end

    it 'requires a stack_id' do
      stack = Card.new(attrs.merge(stack: nil))
      expect(stack).to_not be_valid
    end

    it 'generates a short_id on save' do
      card = create(:card)
      expect(card.short_id).to_not be_blank
    end
  end

  describe '#images' do
    let(:card) { create(:card) }

    it 'accepts images setting positions' do
      card.images << build(:card_image)
      card.images << build(:card_image)
      expect(card.save).to eql true
      card.reload
      expect(card.images.size).to eql 2
      expect(card.images.map(&:position)).to eql [1, 2]
    end
  end
end
