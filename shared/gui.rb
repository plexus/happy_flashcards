#!/usr/bin/env ruby

require "pathname"

unless %w[fp oop].include?(ARGV[0])
  STDERR.puts "Usage: #{$0} fp"
  STDERR.puts "       #{$0} oop"
  exit -1
end

$LOAD_PATH.unshift(Pathname(__FILE__).join("../../#{ARGV[0]}/lib"))

require "flashcards"
require_relative "persistence"

require "shoes"

EXAMPLE_DECK = if ARGV[1]
                 Pathname(ARGV[1]).expand_path
               else
                 Pathname(__FILE__).dirname.join("example_deck.csv")
               end

NBSP="\u00A0"

def print_inspect!(deck)
  puts "-"*80
  deck.each do |card|
    puts " %4s | %4s | %.2f | %8.0f | %5s | %s " % [
           card.front,
           card.back,
           card.factor,
           card.interval,
           card.due?(Time.now).to_s,
           card.last_review_time && card.last_review_time.strftime("%Y-%m-%d %H:%M")
         ]
  end
end

Shoes.app do
  @deck = Flashcards.load_csv(EXAMPLE_DECK)

  def next!
    print_inspect!(@deck)

    @card = @deck.next(Time.now)

    if @card
      @front.text = @card.front
      @back.text = NBSP
      @show.show
      [@right, @wrong, @recheck].each(&:hide)
    else
      @front.text = "- done -"
      @back.text = NBSP
      [@right, @wrong, @show].each(&:hide)
      @recheck.show
    end
  end

  stack margin: 30 do
    @front = para NBSP, font: "50", margin: 20
    @back = para NBSP, font: "50", margin: 20

    flow do
      @show = button "Show", margin: 5 do
        @back.text = @card.back
        @show.hide
        [@right, @wrong].each(&:show)
      end

      @right = button "Right", margin: 5 do
        @deck = @deck.answer_correct(@card, Time.now)
        next!
      end

      @wrong = button "Wrong", margin: 5 do
        @deck = @deck.answer_false(@card, Time.now)
        next!
      end

      @recheck = button "Recheck", margin: 5 do
        next!
      end
    end
  end

  next!
end
