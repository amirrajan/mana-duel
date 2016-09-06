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

describe 'Light Wounds (rat, tiger, dragon): ' do
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
