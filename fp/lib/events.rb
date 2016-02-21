require 'securerandom'

module Flashcards
  class Event
    include Attribs.new(:uuid, :timestamp, :parents, :params)

    def initialize(**args)
      super(
        {
          uuid: SecureRandom.uuid.freeze,
          timestamp: Time.now,
          parents: [].freeze,
          params: nil
        }.merge(args)
      )
    end

    def [](x)
      params[x]
    end

    def call(deck)
      raise "Unimplemented: this is an abstract method"
    end

    def self.add_card(params)
      AddCardEvent.new(params: params)
    end

    def self.right_answer(card)
      RightAnswerEvent.new(params: {card_uuid: card.id})
    end

    def self.wrong_answer(card)
      WrongAnswerEvent.new(params: {card_uuid: card.id})
    end
  end

  class AddCardEvent < Event
    def call(deck)
      deck.add(Card.new(params))
    end
  end

  class RightAnswerEvent < Event
    def call(deck)
      deck.update(params[:card_uuid]) do |card|
        card.answer_right(timestamp)
      end
    end
  end

  class WrongAnswerEvent < Event
    def call(deck)
      deck.update(params[:card_uuid]) do |card|
        card.answer_wrong(timestamp)
      end
    end
  end
end
