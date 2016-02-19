require 'csv'
require 'delegate'

module Flashcards
  ONE_MINUTE = 60
  TEN_MINUTES = 10*60
  ONE_DAY = 24*60*60
  INITIAL_EASE_FACTOR = 2.5
  INTERVALS = [ONE_MINUTE, TEN_MINUTES, ONE_DAY]

  def self.load_csv(input)
    Deck.new.tap do |deck|
      CSV.open(input).each do |f,b|
        deck << Card.create(f, b)
      end
    end
  end

  class Deck < SimpleDelegator
    def initialize
      super([])
    end

    def answer_correct(card, time)
      card.answer_correct!(time)
      self
    end

    def answer_false(card, time)
      card.answer_false!(time)
      self
    end

    def next(now)
      detect {|card| card.due?(now) }
    end
  end

  class Card < Struct.new(:front, :back, :factor, :interval, :streak, :last_review_time)
    def self.create(front, back)
      new(front, back, INITIAL_EASE_FACTOR, TEN_MINUTES, 1, nil)
    end

    def due?(now)
      last_review_time.nil? || now > last_review_time + interval
    end

    def answer_correct!(time)
      self.streak += 1
      self.interval = INTERVALS.fetch(streak) { interval * factor }
      self.last_review_time = time
      self.factor += 0.15
    end

    def answer_false!(time)
      self.streak = 0
      self.interval = ONE_MINUTE
      self.last_review_time = time
      self.factor -= 0.15
    end
  end
end
