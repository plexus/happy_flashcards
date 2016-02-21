# coding: utf-8

require "flashcards"

RSpec.describe Flashcards::Event do
  let(:events) do
    [
      Flashcards::AddCardEvent.new(
        uuid: "92fef8d5-174b-47bb-ae09-a98000dbb8a3",
        timestamp: Time.parse("2016-02-22 09:38:11 +1100"),
        params: {
          id: "c643c27f-8a24-4bec-9feb-069d41950787",
          front: "bird",
          back: "鳥"
        }
      ),
      Flashcards::AddCardEvent.new(
        uuid: "cd9d27dc-916a-4e66-b313-b9713ad0fa34",
        timestamp: Time.parse("2016-02-22 09:41:29 +1100"),
        params: {
          id: "be160fff-aaa0-4757-aacc-a14c6cc17e26",
          front: "ocean",
          back: "海"
        }
      ),
      Flashcards::RightAnswerEvent.new(
        uuid: "500b2b3a-ce00-4135-ac6b-623688d50659",
        timestamp: Time.parse("2016-02-22 09:58:55 +1100"),
        params: {card_uuid: "c643c27f-8a24-4bec-9feb-069d41950787"}
      ),
      Flashcards::WrongAnswerEvent.new(
        uuid: "a6c768c6-41f1-4c50-a222-3038a125841e",
        timestamp: Time.parse("2016-02-22 09:58:55 +1100"),
        params: {card_uuid: "be160fff-aaa0-4757-aacc-a14c6cc17e26"}
      )
    ]
  end

  it do
    deck = events.reduce(Flashcards::Deck[]) {|d,e| e.call(d) }

    expect(deck).to eql Flashcards::Deck[
      Flashcards::Card.new(
        id: "c643c27f-8a24-4bec-9feb-069d41950787",
        front: "bird",
        back: "鳥",
        factor: 2.65,
        interval: 86400,
        streak: 2,
        last_review_time: Time.parse("2016-02-22 09:58:55 +1100")
      ),
      Flashcards::Card.new(
        id: "be160fff-aaa0-4757-aacc-a14c6cc17e26",
        front: "ocean",
        back: "海",
        factor: 2.35,
        interval: 60,
        streak: 0,
        last_review_time: Time.parse("2016-02-22 09:58:55 +1100")
      )
    ]
  end
end
