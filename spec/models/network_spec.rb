require "rails_helper"

RSpec.describe Network, type: :model do
  let(:user) { create(:user) }

  describe ".create" do
    let(:attrs) { attributes_for(:network).merge(user_id: user.id) }

    it "creates a valid network" do
      expect(Network.new(attrs)).to be_valid
    end

    it "creates a valid network without a secret" do
      expect(Network.new(attrs.merge(secret: ""))).to be_valid
    end

    it "requires a user" do
      network = Network.new(attrs.merge(user: nil))
      expect(network).to_not be_valid
    end

    it "requires a provider" do
      network = Network.new(attrs.merge(provider: ""))
      expect(network).to_not be_valid
    end

    it "requires a uid" do
      network = Network.new(attrs.merge(uid: ""))
      expect(network).to_not be_valid
    end

    it "requires a token" do
      network = Network.new(attrs.merge(token: ""))
      expect(network).to_not be_valid
    end

    it "requires a secret if provider is twitter" do
      network = Network.new(attrs.merge(provider: "twitter", secret: ""))
      expect(network).to_not be_valid
      expect(network.errors["secret"].first).to match "blank"
    end

    it "requires a secret if provider is tumblr" do
      network = Network.new(attrs.merge(provider: "tumblr", secret: ""))
      expect(network).to_not be_valid
      expect(network.errors["secret"].first).to match "blank"
    end

    it "requires a provider from the valid list" do
      network = Network.new(attrs.merge(provider: "invalid"))
      expect(network).to_not be_valid
      expect(network.errors[:provider].first).to match "not included in"
    end

    it "requires a unique provider for the user" do
      Network.create(attrs)
      other_network = Network.new(attrs)
      expect(other_network).to_not be_valid
      expect(other_network.errors[:provider].first).to match "taken"
    end

    it "updates the user with facebook credentials if provider is facebook" do
      user = create(:user, facebook_id: nil, facebook_token: nil)
      network = create(:network, provider: "facebook", user: user)
      expect(network).to be_valid
      expect(user.reload.facebook_id).to eql network.uid
      expect(user.facebook_token).to eql network.token
    end

    it "requires a unique facebook network uid" do
      other_user = create(:user)
      network = Network.new(attrs.merge(provider: "facebook",
                                        uid: user.facebook_id,
                                        token: user.facebook_token,
                                        user: other_user))
      expect(network).to_not be_valid
      expect(network.errors[:uid].first).to match "taken"
    end
  end

  describe "#destroy" do
    describe "facebook network" do
      let(:network) { create(:network, user: user, provider: "facebook") }
      it "removes the user facebook credentials" do
        network.destroy
        expect(user.reload.facebook_id).to be_nil
        expect(user.facebook_token).to be_nil
      end
    end
  end
end
