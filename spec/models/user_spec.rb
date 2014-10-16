require "rails_helper"

describe User do
  let(:user) { create(:user) }

  describe ".create" do

    let(:attrs) do
      {
        email: "valid@example.com",
        username: "username",
        password: "123testing",
        password_confirmation: "123testing"
      }
    end

    it "creates a valid user" do
      expect(User.new(attrs)).to be_valid
    end

    it "requires an email" do
      user = User.new(attrs.merge(email: ""))
      expect(user).to_not be_valid
    end

    it "requires a valid email format" do
      user = User.new(attrs.merge(email: "invalid.com"))
      expect(user).to_not be_valid
    end

    it "does not accepts duplicated email" do
      user = create(:user)
      other = User.new(attrs.merge(email: user.email))
      expect(other).to_not be_valid
      expect(other.errors[:email].first).to match("taken")
    end

    it "does not accepts username with special chars" do
      user = User.new(attrs.merge(username: "userName%"))
      expect(user).to_not be_valid
      expect(user.errors[:username].first).to match("invalid")
    end

    it "does not accepts username with blank spaces" do
      user = User.new(attrs.merge(username: "my user name"))
      expect(user).to_not be_valid
      expect(user.errors[:username].first).to match("invalid")
    end

    it "deals with case insensitive usernames" do
      user = User.new(attrs.merge(username: "MyUserName"))
      expect(user.save).to eql true
      result = User.find_for_database_authentication(username: "myusername")
      expect(result.id).to eql user.id
    end

    it "does not accepts duplicated username, case insensitive" do
      user = create(:user)
      other = User.new(attrs.merge(username: user.username.upcase))
      expect(other).to_not be_valid
      expect(other.errors[:username].first).to match("taken")
    end

    it "requires a username" do
      user = User.new(attrs.merge(username: ""))
      expect(user).to_not be_valid
    end

    it "requires a password" do
      user = User.new(attrs.merge(password: ""))
      expect(user).to_not be_valid
    end

    it "requires a password confirmation" do
      user = User.new(attrs.merge(password_confirmation: "otherpass123"))
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation].first).to match("match")
    end

    it "does not accepts duplicated facebook_id" do
      user = create(:user)
      other = User.new(attrs.merge(facebook_id: user.facebook_id))
      expect(other).to_not be_valid
      expect(other.errors[:facebook_id].first).to match("taken")
    end

    it "accepts a blank facebook_id" do
      user = User.new(attrs.merge(facebook_id: ""))
      expect(user).to be_valid
    end

    it "requires facebook_id if facebook_token is present" do
      user = User.new(attrs.merge(facebook_token: "facebooktoken",
                                  facebook_id: ""))
      expect(user).to_not be_valid
      expect(user.errors[:facebook_token].first).to match("is invalid")
    end

  end

  describe "#sign_in_from_device!" do
    let(:req) { Hashie::Mash.new(remote_ip: "127.0.0.1") }

    it "creates a new device, updating tackable fields" do
      expect(user.devices.count).to eql 0
      expect(user.current_sign_in_ip).to be_blank

      user.sign_in_from_device!(req, nil, device_type: "android")

      device = user.devices.recent.first
      expect(device.device_type).to eql "android"

      expect(user.current_sign_in_ip).to eql("127.0.0.1")
    end
  end

  describe "#flag_by!" do
    it "stores a flag to the user, updating flags_count" do
      expect(user.flag_by!(user)).to be_valid
      expect(user.reload.flags.size).to eql 1
      expect(user.flags_count).to eql 1
    end

    it "does not acceps duplicated flag" do
      flag = user.flag_by!(user)
      other_flag = user.flag_by!(user)
      expect(flag.id).to eql other_flag.id
      expect(user.reload.flags_count).to eql 1
    end
  end

  describe "#add_facebook_network" do
    it "adds a network entry for facebook" do
      network = user.add_facebook_network
      expect(network).to be_valid
      user.save
      user.reload
      expect(user.networks.first.token).to eql user.facebook_token
    end

    it "updates the facebook network when facebook_token is updated" do
      network = user.add_facebook_network
      user.facebook_token = "newfacebooktoken"
      user.save
      expect(network.reload.token).to eql "newfacebooktoken"
    end
  end

  describe "#subscribe" do
    it "subscribe the user to a stack" do
      stack = create(:stack)
      subscription = user.subscribe(stack)
      expect(subscription.stack_id).to eql stack.id
      expect(subscription.user_id).to eql user.id
      expect(subscription).to be_valid

      expect(user.subscribe(stack).id).to eql subscription.id
    end
  end

  describe "#calculate_score" do
    it "updates the user score field" do
      create(:card, user: user).vote_by!(user)
      create(:comment, user: user).vote_by!(user)
      expect(user.score).to eql 0
      user.calculate_score
      expect(user.score).to eql 2
    end
  end

  describe "#delete" do
    it "moved the user to deleted users" do
      user.destroy!
      expect(user).to be_destroyed
      expect { User.find(user.id) }.to raise_exception
      expect(DeletedUser.find(user.id)).to_not be_nil
    end
  end

end
