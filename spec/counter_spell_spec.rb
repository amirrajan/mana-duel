require './spec/spec_helper.rb'

=begin
F = Tiger
P = Dragon
S = Snake
W = Rat
D = Dog
C = [Ox, Ox]
(stab) = Ram
nothing () = Wait
=end

describe 'CounterSpell: :rat, :dragon, :dragon, or :rat, :rat, :snake' do
  let(:game) { Game.new }

  it 'cancels damage from spell (variation rat, dragon, dragon)' do
    sync({ left: LightningBolt.new.sequence },
         { left: CounterSpell.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'LightningBolt'
    summary[:a][:left][:spell][:nullified].should eq true

    summary[:b][:left][:spell][:name].should eq 'CounterSpell'
    summary[:b][:left][:spell][:nullified].should eq false

    game.damage_for(:a).should be 0
    game.damage_for(:b).should be 0
  end

  it 'cancels damage from spell (variation rat, rat, snake)' do
    sync({ left: LightningBolt.new.sequence },
         { left: CounterSpell.new.alternate_sequence })

    summary[:a][:left][:spell][:name].should eq 'LightningBolt'
    summary[:a][:left][:spell][:nullified].should eq true

    summary[:b][:left][:spell][:name].should eq 'CounterSpell'
    summary[:b][:left][:spell][:nullified].should eq false

    game.damage_for(:a).should be 0
    game.damage_for(:b).should be 0
  end

  it 'cant stop shock' do
    sync({ left: Shock.new.sequence },
         { left: CounterSpell.new.alternate_sequence })

    summary[:a][:left][:spell][:name].should eq 'Shock'
    summary[:a][:left][:spell][:nullified].should eq false

    summary[:b][:left][:spell][:name].should eq 'CounterSpell'
    summary[:b][:left][:spell][:nullified].should eq false

    game.damage_for(:a).should be 0
    game.damage_for(:b).should be 1
  end

  it 'cannot be shielded' do
    sync({ left: CounterSpell.new.sequence },
         { left: Shield.new.sequence, right: HeavyWounds.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'CounterSpell'
    summary[:a][:left][:spell][:nullified].should eq false

    summary[:b][:left][:spell][:name].should eq 'Shield'
    summary[:b][:left][:spell][:nullified].should eq false
    summary[:b][:right][:spell][:name].should eq 'HeavyWounds'
    summary[:b][:right][:spell][:nullified].should eq true

    game.damage_for(:a).should be 0
    game.damage_for(:b).should be 0
  end
end
