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

describe 'spell sequence' do
  let(:next_sequence) { NextSequence.new }

  specify 'shock' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Shock.new])

    result[:by_spell][Shock][:command].should eq :ram
    result[:by_spell][Shock][:countdown].should eq 1
    result[:by_command][:ram].should eq [{ spell: Shock, countdown: 1 }]
  end

  specify 'shield' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Shield.new, Wait.new])

    result[:by_spell][Shield][:command].should eq :dragon
    result[:by_spell][Shield][:countdown].should eq 1
    result[:by_command][:dragon].should eq [{ spell: Shield, countdown: 1 }]
  end

  specify 'missile' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Missile.new])
    result[:by_spell][Missile][:command].should eq :snake
    result[:by_spell][Missile][:countdown].should eq 2

    result = next_sequence.for({ primary: [:ram, :ram, :snake], assist: [] },
                               [Missile.new])
    result[:by_spell][Missile][:command].should eq :dog
    result[:by_spell][Missile][:countdown].should eq 1
  end

  specify 'sokushi' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :dragon
    result[:by_spell][Sokushi][:countdown].should eq 8

    result = next_sequence.for({ primary: [:dragon], assist: [] },
                               [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :rat
    result[:by_spell][Sokushi][:countdown].should eq 7

    result = next_sequence.for({ primary: [:ram, :dragon], assist: [] },
                               [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :rat
    result[:by_spell][Sokushi][:countdown].should eq 7

    result = next_sequence.for({ primary: [:dragon, :rat, :dragon], assist: [] },
                               [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :tiger
    result[:by_spell][Sokushi][:countdown].should eq 5

    result = next_sequence.for({ primary: [:dragon, :rat, :dragon, :dog],
                                 assist: [] }, [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :dragon
    result[:by_spell][Sokushi][:countdown].should eq 8
  end

  specify 'lightning bolt' do
    result = next_sequence.for({ primary: [:ram], assist: [] },
                               [LightningBolt.new])
    result[:by_spell][LightningBolt][:command].should eq :dog
    result[:by_spell][LightningBolt][:countdown].should eq 5

    result = next_sequence.for({ primary: [:dog], assist: [] },
                               [LightningBolt.new])
    result[:by_spell][LightningBolt][:command].should eq :tiger
    result[:by_spell][LightningBolt][:countdown].should eq 4

    result = next_sequence.for({ primary: [:dog, :tiger, :tiger, :dog, :dog],
                                 assist: [] }, [LightningBolt.new])
    result[:by_spell][LightningBolt][:command].should eq :tiger
    result[:by_spell][LightningBolt][:countdown].should eq 4
  end

  specify 'lightning bolt treats last command as first command' do
    result = next_sequence.for({
                                 primary:
                                   [
                                     :dog,
                                     :tiger,
                                     :tiger,
                                     :dog,
                                     :dog,
                                     :tiger
                                   ], assist: []
                               },
                               [LightningBolt.new])
    result[:by_spell][LightningBolt][:command].should eq :tiger
    result[:by_spell][LightningBolt][:countdown].should eq 3
  end

  specify 'counter spell' do
    result = next_sequence.for({
                                 primary: [:rat],
                                 assist: []
                               },
                               [CounterSpell.new])

    result[:by_spell][CounterSpell][:command].should eq :dragon
    result[:by_spell][CounterSpell][:countdown].should eq 2
    result[:by_spell][CounterSpell][:alternate_command].should eq :rat
    result[:by_spell][CounterSpell][:alternate_countdown].should eq 2

    result[:by_command][:dragon].should eq [
      { spell: CounterSpell, countdown: 2 }
    ]

    result[:by_command][:rat].should eq [
      { spell: CounterSpell, countdown: 2 }
    ]

    result = next_sequence.for({
                                 primary: [],
                                 assist: []
                               },
                               [CounterSpell.new])

    result[:by_spell][CounterSpell][:command].should eq :rat
    result[:by_spell][CounterSpell][:countdown].should eq 3
    result[:by_spell][CounterSpell][:alternate_command].should eq :rat
    result[:by_spell][CounterSpell][:alternate_countdown].should eq 3

    result[:by_command][:rat].should eq [
      { spell: CounterSpell, countdown: 3 }
    ]
  end

  specify 'reflect' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Reflect.new])
    result[:by_spell][Reflect][:command].should eq :ox
    result[:by_spell][Reflect][:countdown].should eq 2
  end

  specify 'reflect takes assist into consideration' do
    result = next_sequence.for({ primary: [:ox], assist: [:wait] },
                               [Reflect.new])
    result[:by_spell][Reflect][:command].should eq :ox
    result[:by_spell][Reflect][:countdown].should eq 2
  end

  specify 'reflect takes assist into consideration' do
    result = next_sequence.for({ primary: [:ox], assist: [:ox] },
                               [Reflect.new])
    result[:by_spell][Reflect][:command].should eq :rat
    result[:by_spell][Reflect][:countdown].should eq 1
  end

  specify '"by command" grouping' do
    result = next_sequence.for({ primary: [:rat], assist: [] },
                               [HeavyWounds.new, Shield.new])

    result[:by_command][:dragon].should eq [
      { spell: HeavyWounds, countdown: 3 },
      { spell: Shield, countdown: 1 }
    ]

    result[:by_command][:rat].should eq [ { spell: HeavyWounds, countdown: 4 } ]
  end

  specify 'in game' do
    game = Game.new

    game.next_sequence_for_turn[0][:a][:left][:by_spell][Shield][:command].should eq :dragon
    game.next_sequence_for_turn[0][:b][:left][:by_spell][Shield][:command].should eq :dragon

    game.turn({ }, { })

    game.next_sequence_for_turn[1][:a][:left][:by_spell][Shield][:command].should eq :dragon
    game.next_sequence_for_turn[1][:b][:left][:by_spell][Shield][:command].should eq :dragon
  end

  specify 'reflect in game' do
    game = Game.new

    game.turn({ left: :ox, right: :ox }, { })

    game.next_sequence_for_turn[1][:a][:left][:by_spell][Reflect][:command].should eq :rat
  end
end
