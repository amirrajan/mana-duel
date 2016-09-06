require './spec/spec_helper.rb'

=begin
F = Tiger
P = Dragon
S = Snake
W = Rat
D = Dog
C = Blood Seal
(stab) = Kunai
nothing () = Wait
=end

describe 'Lightning Bolt' do
  let(:game) { Game.new }

  it 'does 5 points of damage' do
    sync({ left: LightningBolt.new.sequence },
         {})

    game.damage_for(:b).should be 5
  end

  it 'is unaffected by opponent casting a shield' do
    sync({ left: LightningBolt.new.sequence },
         { left: Shield.new.sequence })

    game.damage_for(:b).should be 5
    summary[:b][:left][:spell][:name].should eq 'Shield'
  end
end
