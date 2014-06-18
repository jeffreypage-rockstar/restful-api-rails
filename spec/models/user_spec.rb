require "rails_helper"

describe User do
  describe '.create' do

    let(:attrs) do
      {
        email: 'valid@example.com',
        password: '123testing',
        password_confirmation: '123testing'
      }
    end

    it 'creates a valid user' do
      expect(User.new(attrs)).to be_valid
    end

    it 'requires an email' do
      user = User.new(attrs.merge(email: ''))
      expect(user).to_not be_valid
    end

    it 'requires a valid email format' do
      user = User.new(attrs.merge(email: 'invalid.com'))
      expect(user).to_not be_valid
    end

    it 'does not accepts duplicated email' do
      user = create(:user)
      other = User.new(attrs.merge(email: user.email))
      expect(other).to_not be_valid
      expect(other.errors[:email].first).to match('taken')
    end

    it 'does not accepts duplicated username' do
      user = create(:user)
      other = User.new(attrs.merge(username: user.username))
      expect(other).to_not be_valid
      expect(other.errors[:username].first).to match('taken')
    end

    it 'accepts a blank username' do
      user = create(:user, username: '')
      expect(user).to be_valid

      other = User.new(attrs.merge(username: ''))
      expect(other).to be_valid
    end

    it 'requires a password' do
      user = User.new(attrs.merge(password: ''))
      expect(user).to_not be_valid
    end

    it 'requires a password confirmation' do
      user = User.new(attrs.merge(password_confirmation: 'otherpass123'))
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation].first).to match('match')
    end
  end

  describe '#sign_in_from_device!' do
    let(:user) { create(:user) }
    let(:req) { Hashie::Mash.new(remote_ip: '127.0.0.1') }

    it 'creates a new device, updating tackable fields' do
      expect(user.devices.count).to eql 0
      expect(user.current_sign_in_ip).to be_blank

      user.sign_in_from_device!(req, nil, device_type: 'android')

      device = user.devices.recent.first
      expect(device.device_type).to eql 'android'

      expect(user.current_sign_in_ip).to eql('127.0.0.1')
    end
  end

end
