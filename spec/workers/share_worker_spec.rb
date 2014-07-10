require "rails_helper"

RSpec.describe ShareWorker, type: :worker do
  let(:worker) { ShareWorker.new }
  let(:user) { create(:user) }
  let(:card) { create(:card) }

  it "performs a facebook share" do
    network = create(:network, provider: "facebook", user: user)
    graph = double("graph")
    expect(graph).to receive(:put_wall_post).and_return("id" => "000_000")
    expect(Koala::Facebook::API).to receive(:new).
                                    with(network.token).
                                    and_return(graph)
    result = worker.perform(user.id, card.id, ["facebook"])
    expect(result.first["id"]).to eql "000_000"
  end
end
