require "rails_helper"

describe DeletedUser do
  let(:user) { create(:user) }
  let(:deleted_user) { create(:deleted_user) }

  it "should have the same attributes as user" do
    expect(DeletedUser.column_names).to match_array(User.column_names)
  end

  it "should receive a new user entry when deleting" do
    user_id = user.id
    user.destroy!
    deleted = DeletedUser.find(user_id)
    expect(deleted.deleted_at).to be_within(1.second).of(Time.now.utc)
  end

  describe ".restore" do
    it "restores the record to users table" do
      user_id = deleted_user.id
      expect(deleted_user.restore).to_not be_nil
      expect(User.find(user_id)).to be_valid
      expect { deleted_user.reload }.to raise_exception
    end

    it "does not restore an invalid user, presenving deleted entry" do
      deleted_user = create(:deleted_user, sign_in_count: nil)
      expect(deleted_user).to be_valid
      expect(deleted_user.restore).to be_nil
      expect(deleted_user).to_not be_destroyed
    end
  end

  describe "#restore" do
    it "restores a set of users" do
      deleted_ids = (1..5).map { create(:deleted_user)  }.map(&:id)
      expect do
        DeletedUser.restore(deleted_ids)
      end.to change(DeletedUser, :count).by(-5)
      expect(User.where(id: deleted_ids).count).to eql 5
    end

    it "restores only valid users, presenving invalid ones as deleted" do
      deleted_ids = (1..3).map do
        create(:deleted_user, sign_in_count: nil)
      end.map(&:id)

      expect do
        DeletedUser.restore(deleted_ids)
      end.to change(DeletedUser, :count).by(0)
      expect(User.where(id: deleted_ids).count).to eql 0
    end
  end
end
