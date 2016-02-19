require "csv"
require "pathname"
require "attribs"
require "hamster"
require "fn/global"

module Flashcards
  TEN_MINUTES = 10*60
  ONE_DAY = 24*60*60
  Vector = Hamster::Vector

  def self.load_csv(input)
    Deck.new(CSV.open(input).map {|f,b| Card.new(front: f, back: b) })
  end

  class Deck < Vector
    def answer_correct(card, time)
      put(
        index(card),
        card.with(interval: ONE_DAY, last_review_time: time)
      )
    end

    def next(now)
      detect &fn(:due?, now)
    end
  end

  class Card
    include Attribs.new(
      :front,
      :back,
      interval: TEN_MINUTES,
      last_review_time: nil
    )

    def due?(now)
      last_review_time.nil? || now > last_review_time + interval
    end
  end
end
