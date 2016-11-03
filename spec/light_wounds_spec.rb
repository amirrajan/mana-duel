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

describe 'Light Wounds (indigo, violet, red): ' do
  let(:game) { Game.new }

  it 'causes two points of damage' do
    sync({ left: LightWounds.new.sequence }, {})

    game.damage_for(:b).should eq 2
  end

  it 'is unaffected by opponent casting a shield' do
    sync({ left: LightWounds.new.sequence },
         { left: Shield.new.sequence })

    summary[:b][:left][:spell][:name].should eq 'Shield'
    game.damage_for(:b).should eq 2
  end
end
