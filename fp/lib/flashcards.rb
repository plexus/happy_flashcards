require "csv"
require "pathname"
require "attribs"
require "hamster"
require "fn/global"

module Flashcards
  ONE_MINUTE = 60
  TEN_MINUTES = 10*60
  ONE_DAY = 24*60*60
  INITIAL_EASE_FACTOR = 2.5
  INTERVALS = [ONE_MINUTE, TEN_MINUTES, ONE_DAY]

  Vector = Hamster::Vector

  def self.load_csv(input)
    Deck.new(CSV.open(input).map {|f,b| Card.new(front: f, back: b) })
  end

  class Deck < Vector
    def answer_correct(card, time)
      put(index(card), card.answer_correct(time))
    end

    def answer_false(card, time)
      put(index(card), card.answer_false(time))
    end

    def next(now)
      detect &fn(:due?, now)
    end
  end

  class Card
    include Attribs.new(
      :front,
      :back,
      factor: INITIAL_EASE_FACTOR,
      interval: TEN_MINUTES,
      streak: 1,
      last_review_time: nil
    )

    def due?(now)
      last_review_time.nil? || now > last_review_time + interval
    end

    def answer_correct(time)
      with(
        streak: streak + 1,
        interval: INTERVALS.fetch(streak + 1) { interval * factor },
        last_review_time: time,
        factor: factor + 0.15
      )
    end

    def answer_false(time)
      with(
        interval: ONE_MINUTE,
        last_review_time: time,
        streak: 0,
        factor: factor - 0.15
      )
    end
  end
end
