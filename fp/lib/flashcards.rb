require "csv"
require "pathname"
require "securerandom"

require "attribs"
require "hamster"
require "fn/global"

require_relative "events"
require_relative "session_service"
require_relative "monkey_patches"

module Flashcards
  ONE_MINUTE = 60
  TEN_MINUTES = 10*60
  ONE_DAY = 24*60*60
  INITIAL_EASE_FACTOR = 2.5
  INTERVALS = [ONE_MINUTE, TEN_MINUTES, ONE_DAY]

  Vector = Hamster::Vector

  class Deck < Vector
    def next(now)
      detect &fn(:due?, now)
    end

    def update(uuid, &block)
      card = detect {|card| card.id == uuid }
      put(index(card), block.call(card))
    end
  end

  class Card
    include Attribs.new(
      :id,
      :front,
      :back,
      factor: INITIAL_EASE_FACTOR,
      interval: TEN_MINUTES,
      streak: 1,
      last_review_time: nil
    )

    def initialize(**args)
      super({id: SecureRandom.uuid}.merge(args))
    end

    def due?(now)
      last_review_time.nil? || now > last_review_time + interval
    end

    def answer_right(time)
      with(
        streak: streak + 1,
        interval: INTERVALS.fetch(streak + 1) { interval * factor },
        last_review_time: time,
        factor: factor + 0.15
      )
    end

    def answer_wrong(time)
      with(
        interval: ONE_MINUTE,
        last_review_time: time,
        streak: 0,
        factor: factor - 0.15
      )
    end
  end
end
