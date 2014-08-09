describe "list challenges" do
  let(:sample_challenges) do
    {
      challenges: [
        { title: "Guess the Number", slug: "guess-the-number" },
        { title: "Blackjack", slug: "blackjack" }
      ]
    }
  end

  it "prints the titles and slug" do
    expect_any_instance_of(ET::API).to receive(:list_challenges).
      and_return(sample_challenges)

    stdout, _ = capture_output do
      expect(ET::Runner.go(["challenges"])).to eq(0)
    end

    expect(stdout).to include("Guess the Number")
    expect(stdout).to include("guess-the-number")

    expect(stdout).to include("Blackjack")
    expect(stdout).to include("blackjack")
  end
end
