require './spec/spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = Blood Seal
(stab) = orange
nothing () = Wait
=end

describe 'Greater Heal (yellow, violet, red, indigo): ' do
  let(:game) { Game.new }

  it 'heals two damage' do
    game.turn({ left: :orange },
              { right: :orange })
    game.turn({ left: :orange },
              { right: :orange })

    game.damage_for(:a).should eq 2
    game.damage_for(:b).should eq 2

    sync({},
         { right: GreaterHeal.new.sequence })

    game.damage_for(:a).should eq 2
    game.damage_for(:b).should eq 0
  end
end
