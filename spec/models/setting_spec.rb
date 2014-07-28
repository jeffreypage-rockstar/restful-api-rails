require "rails_helper"

RSpec.describe Setting, type: :model do
  describe ".create" do
    let(:attrs) do
      {
        key: "my_key",
        value: "setting value",
        description: "My key description"
      }
    end

    it "creates a valid setting" do
      expect(Setting.new(attrs)).to be_valid
    end

    it "requires a key" do
      setting = Setting.new(attrs.merge(key: ""))
      expect(setting).to_not be_valid
    end

    it "requires a key without spaces" do
      setting = Setting.new(attrs.merge(key: "key with spaces"))
      expect(setting).to_not be_valid
    end

    it "requires a unique key" do
      Setting.create(attrs)
      setting = Setting.new(attrs)
      expect(setting).to_not be_valid
      expect(setting.errors[:key].first).to match "taken"
    end
  end

  describe "#[]" do
    it "stores/retrieves a setting with brackets notation" do
      Setting[:max_number] = "10"
      expect(Setting[:max_number]).to eql "10"
    end
  end
end
