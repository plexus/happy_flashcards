require "delegate"
require "equalizer"

module Flashcards
  ONE_MINUTE = 60
  TEN_MINUTES = 10*60
  ONE_DAY = 24*60*60
  INITIAL_EASE_FACTOR = 2.5
  INTERVALS = [ONE_MINUTE, TEN_MINUTES, ONE_DAY]

  class Deck < SimpleDelegator
    def answer_right(card, time)
      card.answer_right!(time)
      self
    end

    def answer_wrong(card, time)
      card.answer_wrong!(time)
      self
    end

    def next(now)
      detect {|card| card.due?(now) }
    end

    def eql?(other)
      zip(other).all? {|a,b| a.eql?(b) }
    end
  end

  class Card
    ATTRS = [:front, :back, :factor, :interval, :streak, :last_review_time]

    include Equalizer.new(*ATTRS)
    attr_accessor *ATTRS

    def initialize(**args)
      @front = args.fetch(:front)
      @back = args.fetch(:back)
      @factor = args.fetch(:factor, INITIAL_EASE_FACTOR)
      @interval = args.fetch(:interval, TEN_MINUTES)
      @streak = args.fetch(:streak, 1)
      @last_review_time = args.fetch(:last_review_time, nil)
    end

    def due?(now)
      last_review_time.nil? || now > last_review_time + interval
    end

    def answer_right!(time)
      self.streak += 1
      self.interval = INTERVALS.fetch(streak) { interval * factor }
      self.last_review_time = time
      self.factor += 0.15
    end

    def answer_wrong!(time)
      self.streak = 0
      self.interval = ONE_MINUTE
      self.last_review_time = time
      self.factor -= 0.15
    end

    def to_h
      {
        front: @front,
        back: @back,
        factor: @factor,
        interval: @interval,
        streak: @streak,
        last_review_time: @last_review_time,
      }
    end
  end
end
