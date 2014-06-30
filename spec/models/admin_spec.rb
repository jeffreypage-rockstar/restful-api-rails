require "rails_helper"

describe Admin do
  describe ".create" do

    let(:attrs) do
      {
        email: "valid@example.com",
        username: "username",
        password: "123testing",
        password_confirmation: "123testing"
      }
    end

    it "creates a valid admin" do
      expect(Admin.new(attrs)).to be_valid
    end

    it "requires an email" do
      admin = Admin.new(attrs.merge(email: ""))
      expect(admin).to_not be_valid
    end

    it "requires a valid email format" do
      admin = Admin.new(attrs.merge(email: "invalid.com"))
      expect(admin).to_not be_valid
    end

    it "does not accepts duplicated email" do
      admin = create(:admin)
      other = Admin.new(attrs.merge(email: admin.email))
      expect(other).to_not be_valid
      expect(other.errors[:email].first).to match("taken")
    end

    it "does not accepts username with special chars" do
      admin = Admin.new(attrs.merge(username: "userName%"))
      expect(admin).to_not be_valid
      expect(admin.errors[:username].first).to match("invalid")
    end

    it "does not accepts duplicated username" do
      admin = create(:admin)
      other = Admin.new(attrs.merge(username: admin.username))
      expect(other).to_not be_valid
      expect(other.errors[:username].first).to match("taken")
    end

    it "requires a username" do
      admin = Admin.new(attrs.merge(username: ""))
      expect(admin).to_not be_valid
    end

    it "requires a password" do
      admin = Admin.new(attrs.merge(password: ""))
      expect(admin).to_not be_valid
    end

    it "requires a password confirmation" do
      admin = Admin.new(attrs.merge(password_confirmation: "otherpass123"))
      expect(admin).to_not be_valid
      expect(admin.errors[:password_confirmation].first).to match("match")
    end
  end

end
