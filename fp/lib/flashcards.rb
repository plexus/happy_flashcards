require 'csv'
require 'pathname'
require 'attribs'
require 'hamster'

module Flashcards
  TEN_MINUTES = 10*60
  ONE_DAY = 24*60*60
  Vector = Hamster::Vector

  def self.load_csv(input)
    Deck.new(CSV.open(input).map {|f,b| Card.new(front: f, back: b) })
  end

  class Deck
    extend Forwardable
    include Attribs.new(:cards)

    def_delegators :cards, :first, :size

    def initialize(cards)
      super(cards: Vector.new(cards))
    end

    def answer_correct(card)
      cards.put(cards.index(card), card.with(interval: ONE_DAY))
    end
  end

  class Card
    include Attribs.new(:front, :back, interval: TEN_MINUTES)
  end
end
