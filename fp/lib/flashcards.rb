require 'csv'
require 'pathname'
require 'attribs'

module Flashcards
  TEN_MINUTES = 10*60
  ONE_DAY = 24*60*60

  def self.load_csv(input)
    Deck.new(cards: CSV.open(input).map {|f,b| Card.create(f, b) })
  end

  class Deck
    extend Forwardable
    include Attribs.new(:cards)

    def_delegators :cards, :first, :size

    def answer_correct(card)
      with(
        cards: cards.map do |c|
          if c.equal?(card)
            c.with_interval(ONE_DAY)
          else
            c
          end
        end
      )
    end
  end

  class Card
    include Attribs.new(:front, :back, :interval)

    def self.create(front, back)
      new(front: front, back: back, interval: TEN_MINUTES)
    end

    def with_interval(i)
      with(interval: i)
    end
  end
end
