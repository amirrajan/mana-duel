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

describe 'instant death' do
  let(:game) { Game.new }

  it 'casting ram ram causes instant death' do
    game.turn({ left: :ram, right: :ram },
              {})

    game.damage_for(:a).should eq 30
    game.over?.should be true
    game.winner.should be :b
  end

  it 'casting dragon dragon causes instant death' do
    game.turn({ left: :dragon, right: :dragon },
              {})

    game.damage_for(:a).should eq 30
    game.over?.should be true
    game.winner.should be :b
  end

  it 'can\'t be nullified by a shield' do
    summary = game.turn({ left: :dragon, right: :dragon },
                        { right: :dragon })

    summary[:a][:left][:spell][:nullified].should be false
    summary[:a][:right][:spell][:nullified].should be false
    game.damage_for(:a).should eq 30
    game.over?.should be true
    game.winner.should be :b
  end
end
