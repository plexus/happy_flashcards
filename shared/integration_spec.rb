EXAMPLE_DECK = Pathname(__FILE__).dirname.join("example_deck.csv")

RSpec.describe Flashcards do
  let(:deck) { Flashcards.load_csv(EXAMPLE_DECK) }

  specify do
    expect(deck.size).to eql 5
  end
end
