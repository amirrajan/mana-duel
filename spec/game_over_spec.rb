require './spec/spec_helper.rb'

=begin
F = Tiger
P = Dragon
S = Snake
W = Rat
D = Dog
C = Ox, Ox
(stab) = Kunai
nothing () = Wait
=end

describe 'game over' do
  let(:game) { Game.new }

  it 'team a wins if they do 15 or more damage to b' do
    15.times do
      game.turn({ left: :ram },
                {})
    end

    game.over?.should be true
    game.winner.should be :a
  end

  it 'team b wins if they do 15 or more damage to a' do
    15.times do
      game.turn({},
                { left: :ram })
    end

    game.over?.should be true
    game.winner.should be :b
  end

  it 'is a draw if both have 15 damage' do
    15.times do
      game.turn({ left: :ram },
                { left: :ram })
    end

    game.over?.should be true
    game.winner.should be :draw
  end
end
