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

describe 'spell sequence' do
  let(:next_sequence) { NextSequence.new }

  specify 'shock' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Shock.new])

    result[:by_spell][Shock][:command].should eq :orange
    result[:by_spell][Shock][:countdown].should eq 1
    result[:by_command][:orange].should eq [{ spell: Shock, countdown: 1 }]
  end

  specify 'shield' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Shield.new, Wait.new])

    result[:by_spell][Shield][:command].should eq :red
    result[:by_spell][Shield][:countdown].should eq 1
    result[:by_command][:red].should eq [{ spell: Shield, countdown: 1 }]
  end

  specify 'missile' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Missile.new])
    result[:by_spell][Missile][:command].should eq :green
    result[:by_spell][Missile][:countdown].should eq 2

    result = next_sequence.for({ primary: [:orange, :orange, :green], assist: [] },
                               [Missile.new])
    result[:by_spell][Missile][:command].should eq :yellow
    result[:by_spell][Missile][:countdown].should eq 1
  end

  specify 'sokushi' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :red
    result[:by_spell][Sokushi][:countdown].should eq 8

    result = next_sequence.for({ primary: [:red], assist: [] },
                               [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :indigo
    result[:by_spell][Sokushi][:countdown].should eq 7

    result = next_sequence.for({ primary: [:orange, :red], assist: [] },
                               [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :indigo
    result[:by_spell][Sokushi][:countdown].should eq 7

    result = next_sequence.for({ primary: [:red, :indigo, :red], assist: [] },
                               [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :violet
    result[:by_spell][Sokushi][:countdown].should eq 5

    result = next_sequence.for({ primary: [:red, :indigo, :red, :yellow],
                                 assist: [] }, [Sokushi.new])
    result[:by_spell][Sokushi][:command].should eq :red
    result[:by_spell][Sokushi][:countdown].should eq 8
  end

  specify 'lightning bolt' do
    result = next_sequence.for({ primary: [:orange], assist: [] },
                               [LightningBolt.new])
    result[:by_spell][LightningBolt][:command].should eq :yellow
    result[:by_spell][LightningBolt][:countdown].should eq 5

    result = next_sequence.for({ primary: [:yellow], assist: [] },
                               [LightningBolt.new])
    result[:by_spell][LightningBolt][:command].should eq :violet
    result[:by_spell][LightningBolt][:countdown].should eq 4

    result = next_sequence.for({ primary: [:yellow, :violet, :violet, :yellow, :yellow],
                                 assist: [] }, [LightningBolt.new])
    result[:by_spell][LightningBolt][:command].should eq :violet
    result[:by_spell][LightningBolt][:countdown].should eq 4
  end

  specify 'lightning bolt treats last command as first command' do
    result = next_sequence.for({
                                 primary:
                                   [
                                     :yellow,
                                     :violet,
                                     :violet,
                                     :yellow,
                                     :yellow,
                                     :violet
                                   ], assist: []
                               },
                               [LightningBolt.new])
    result[:by_spell][LightningBolt][:command].should eq :violet
    result[:by_spell][LightningBolt][:countdown].should eq 3
  end

  specify 'counter spell' do
    result = next_sequence.for({
                                 primary: [:indigo],
                                 assist: []
                               },
                               [CounterSpell.new])

    result[:by_spell][CounterSpell][:command].should eq :red
    result[:by_spell][CounterSpell][:countdown].should eq 2
    result[:by_spell][CounterSpell][:alternate_command].should eq :indigo
    result[:by_spell][CounterSpell][:alternate_countdown].should eq 2

    result[:by_command][:red].should eq [
      { spell: CounterSpell, countdown: 2 }
    ]

    result[:by_command][:indigo].should eq [
      { spell: CounterSpell, countdown: 2 }
    ]

    result = next_sequence.for({
                                 primary: [],
                                 assist: []
                               },
                               [CounterSpell.new])

    result[:by_spell][CounterSpell][:command].should eq :indigo
    result[:by_spell][CounterSpell][:countdown].should eq 3
    result[:by_spell][CounterSpell][:alternate_command].should eq :indigo
    result[:by_spell][CounterSpell][:alternate_countdown].should eq 3

    result[:by_command][:indigo].should eq [
      { spell: CounterSpell, countdown: 3 }
    ]
  end

  specify 'reflect' do
    result = next_sequence.for({ primary: [], assist: [] },
                               [Reflect.new])
    result[:by_spell][Reflect][:command].should eq :blue
    result[:by_spell][Reflect][:countdown].should eq 2
  end

  specify 'reflect takes assist into consideration' do
    result = next_sequence.for({ primary: [:blue], assist: [:wait] },
                               [Reflect.new])
    result[:by_spell][Reflect][:command].should eq :blue
    result[:by_spell][Reflect][:countdown].should eq 2
  end

  specify 'reflect takes assist into consideration' do
    result = next_sequence.for({ primary: [:blue], assist: [:blue] },
                               [Reflect.new])
    result[:by_spell][Reflect][:command].should eq :indigo
    result[:by_spell][Reflect][:countdown].should eq 1
  end

  specify '"by command" grouping' do
    result = next_sequence.for({ primary: [:indigo], assist: [] },
                               [HeavyWounds.new, Shield.new])

    result[:by_command][:red].should eq [
      { spell: HeavyWounds, countdown: 3 },
      { spell: Shield, countdown: 1 }
    ]

    result[:by_command][:indigo].should eq [ { spell: HeavyWounds, countdown: 4 } ]
  end

  specify 'in game' do
    game = Game.new

    game.next_sequence_for_turn[0][:a][:left][:by_spell][Shield][:command].should eq :red
    game.next_sequence_for_turn[0][:b][:left][:by_spell][Shield][:command].should eq :red

    game.turn({ }, { })

    game.next_sequence_for_turn[1][:a][:left][:by_spell][Shield][:command].should eq :red
    game.next_sequence_for_turn[1][:b][:left][:by_spell][Shield][:command].should eq :red
  end

  specify 'reflect in game' do
    game = Game.new

    game.turn({ left: :blue, right: :blue }, { })

    game.next_sequence_for_turn[1][:a][:left][:by_spell][Reflect][:command].should eq :indigo
  end
end
