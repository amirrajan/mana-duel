require './spec/spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = Blood Seal
(stab) = Kunai
nothing () = Wait
=end

describe 'Heavy Wounds (indigo, red, violet, yellow): ' do
  let(:game) { Game.new }

  it 'causes three points of damage' do
    sync({ left: HeavyWounds.new.sequence }, {})

    game.damage_for(:b).should eq 3
  end

  it 'is unaffected by opponent casting a shield' do
    sync({ left: HeavyWounds.new.sequence },
         { left: Shield.new.sequence })

    game.damage_for(:b).should eq 3
  end
end
