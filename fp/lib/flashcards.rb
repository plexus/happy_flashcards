require 'csv'
require 'pathname'

module Flashcards
  def self.load_csv(input)
    Deck.new(CSV.open(input).map {|f,b| Card.new(f,b) })
  end

  class Deck
    extend Forwardable

    def initialize(cards)
      @cards = cards
    end

    def_delegators :@cards, :first, :size
  end

  class Card < Struct.new(:front, :back)
  end
end
