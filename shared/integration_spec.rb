# coding: utf-8
EXAMPLE_DECK = Pathname(__FILE__).dirname.join("example_deck.csv")

RSpec.describe Flashcards do
  let(:deck) { Flashcards.load_csv(EXAMPLE_DECK) }

  specify do
    expect(deck.size).to eql 5
  end

  specify do
    expect(deck.first.front).to eql "a"
  end

  describe "a card" do
    let(:card) { deck.first }

    it "will have a front" do
      expect(card.front).to eql "a"
    end

    it "will have a back" do
      expect(card.back).to eql "あ"
    end

    it "will have an initial interval of 10 minutes" do
      expect(card.interval).to be 600
    end
  end

  context "after a correct first answer" do
    before do
      @deck = deck.answer_correct(deck.first)
    end

    let(:card) { @deck.first }

    it "will have an interval of one day" do
      expect(card.interval).to be Flashcards::ONE_DAY
    end
  end

end
