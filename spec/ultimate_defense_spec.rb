require './spec/spec_helper.rb'

=begin
F = Tiger
P = Dragon
S = Snake
W = Rat
D = Dog
C = [Ox, Ox]
(stab) = Kunai
nothing () = Wait
=end

describe 'UltimateDefense: [:ox, :ox], :dog, :dragon, :rat' do
  let(:game) { Game.new }

  it 'prevents damage from spells' do
    sync({ left: LightningBolt.new.sequence }, { left: UltimateDefense.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'LightningBolt'
    summary[:b][:left][:spell][:name].should eq 'UltimateDefense'

    summary[:a][:left][:spell][:nullified].should eq true
    summary[:b][:left][:spell][:nullified].should eq false

    game.damage_for(:a).should be 0
    game.damage_for(:b).should be 0
  end

  it 'prevents damage from shock' do
    sync({ left: Shock.new.sequence }, { left: UltimateDefense.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Shock'
    summary[:b][:left][:spell][:name].should eq 'UltimateDefense'

    summary[:a][:left][:spell][:nullified].should eq true
    summary[:b][:left][:spell][:nullified].should eq false

    game.damage_for(:a).should be 0
    game.damage_for(:b).should be 0
  end
end
