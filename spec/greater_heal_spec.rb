require './spec/spec_helper.rb'

=begin
F = Tiger
P = Dragon
S = Snake
W = Rat
D = Dog
C = Blood Seal
(stab) = Ram
nothing () = Wait
=end

describe 'Greater Heal (dog, tiger, dragon, rat): ' do
  let(:game) { Game.new }

  it 'heals two damage' do
    game.turn({ left: :ram },
              { right: :ram })
    game.turn({ left: :ram },
              { right: :ram })

    game.damage_for(:a).should eq 2
    game.damage_for(:b).should eq 2

    sync({},
         { right: GreaterHeal.new.sequence })

    game.damage_for(:a).should eq 2
    game.damage_for(:b).should eq 0
  end
end
