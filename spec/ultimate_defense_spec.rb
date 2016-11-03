require './spec/spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = [blue, blue]
(stab) = Kunai
nothing () = Wait
=end

describe 'UltimateDefense: [:blue, :blue], :yellow, :red, :indigo' do
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
