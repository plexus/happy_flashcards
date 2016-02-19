require 'csv'
require 'delegate'

module Flashcards
  TEN_MINUTES = 10*60
  ONE_DAY = 24*60*60

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

    def answer_correct(card)
      if card.interval = TEN_MINUTES
        card.interval = ONE_DAY
      end
      self
    end
  end

  class Card < Struct.new(:front, :back, :interval)
    def self.create(front, back)
      new(front, back, TEN_MINUTES)
    end
  end
end
