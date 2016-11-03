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

describe 'Sokushi: red, indigo, red, violet, green, green, green, yellow' do
  let(:game) { Game.new }

  def summary
    game.turn_summaries.last
  end

  it 'does 100 points of damage' do
    sync({ left: Sokushi.new.sequence }, {})

    summary[:a][:left][:spell][:name].should eq 'Sokushi'
    summary[:a][:left][:spell][:nullified].should eq false

    game.damage_for(:b).should be 100
  end

  it 'can be countered by ultimate defense' do
    sync({ left: Sokushi.new.sequence },
         { left: UltimateDefense.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Sokushi'
    summary[:a][:left][:spell][:nullified].should eq true

    summary[:b][:left][:spell][:name].should eq 'UltimateDefense'

    game.damage_for(:b).should be 0
  end

  it 'cannot be countered by counter spell' do
    sync({ left: Sokushi.new.sequence },
         { left: CounterSpell.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Sokushi'
    summary[:a][:left][:spell][:nullified].should eq false

    summary[:b][:left][:spell][:name].should eq 'CounterSpell'
    game.damage_for(:b).should be 100
  end

  it 'cannot be reflected' do
    sync({ left: Sokushi.new.sequence },
         { left: Reflect.new.sequence,
           right: Reflect.new.assist_sequence })

    summary[:a][:left][:spell][:name].should eq 'Sokushi'
    summary[:a][:left][:spell][:nullified].should eq false

    summary[:b][:left][:spell][:name].should eq 'Reflect'
    game.damage_for(:b).should be 100
  end

  it 'cannot be shielded against' do
    sync({ left: Sokushi.new.sequence },
         { left: Shield.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Sokushi'
    summary[:a][:left][:spell][:nullified].should eq false

    summary[:b][:left][:spell][:name].should eq 'Shield'
    game.damage_for(:b).should be 100
  end
end
