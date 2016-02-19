# coding: utf-8
EXAMPLE_DECK = Pathname(__FILE__).dirname.join("example_deck.csv")

RSpec.describe Flashcards do
  let(:deck) { Flashcards.load_csv(EXAMPLE_DECK) }
  let(:a_time) { Time.parse("2016-02-19 7:25:11+11:00") }

  def minutes(m)
    m * 60
  end

  def days(d)
    d * 60 * 60 * 24
  end

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
      @deck = deck.answer_correct(deck.first, a_time)
    end

    let(:card) { @deck.first }

    it "will have an interval of one day" do
      expect(card.interval).to be Flashcards::ONE_DAY
    end

    it "will keep track of the last review time" do
      expect(card.last_review_time).to eql a_time
    end

    it "will keep track of the last review time" do
      expect(card.last_review_time).to eql a_time
    end

    it "will not be due yet in 5 minutes" do
      expect(@deck.next(a_time + minutes(5))).to_not eql card
    end

    it "will be due in a day" do
      expect(@deck.next(a_time + minutes(1) + days(1))).to eql card
    end
  end

end
