require "rantly"

RSpec.describe Flashcards, "persistence" do
  def random_deck
    Flashcards::Deck.new(
      Rantly.map(rand(10)) do
        Flashcards::Card.new(
          front: string,
          back: string,
          factor: float,
          interval: integer,
          streak: integer,
          last_review_time: rand(3) == 1 ? nil : Time.new(
            rand(500) + 1750,
            (integer % 12) + 1,
            (integer % 30) + 1,
            integer % 24,
            integer % 60,
            integer % 60,
            "#{rand(2) == 1 ? '+' : '-'}%02d:00" % (integer % 13)
          )
        )
      end
    )
  end

  specify do
    100.times do
      deck = random_deck
      expect(Flashcards.read_deck(Flashcards.write_deck(deck)))
        .to eql deck
    end
  end
end
