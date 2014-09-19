require "rails_helper"

RSpec.describe ShareWorker, type: :worker do
  let(:worker) { ShareWorker.new }
  let(:user) { create(:user) }
  let(:card) { create(:card) }

  before do
    Card.disable_search_callbacks
  end

  it "performs a facebook share" do
    network = create(:network, provider: "facebook", user: user)
    graph = double("graph")
    expect(graph).to receive(:put_wall_post)
    expect(Koala::Facebook::API).to receive(:new).
                                    with(network.token).
                                    and_return(graph)
    worker.perform(user.id, card.id, ["facebook"])
  end

  it "performs a twitter share" do
    create(:network, provider: "twitter", user: user)
    VCR.use_cassette("sharing_twitter") do
      worker.perform(user.id, card.id, ["twitter"])
    end
  end

  it "performs a tumblr share" do
    network = create(:network, provider: "tumblr",
                               user: user,
                               uid: "myblog.tumblr.com")
    client = double("client")
    expect(client).to receive(:consumer_key=)
    expect(client).to receive(:consumer_secret=)
    expect(client).to receive(:oauth_token=).with(network.token)
    expect(client).to receive(:oauth_token_secret=).with(network.secret)
    expect(client).to receive(:link)
    expect(Tumblr::Client).to receive(:new).and_return(client)
    worker.perform(user.id, card.id, ["tumblr"])
  end
end
