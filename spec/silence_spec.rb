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

=begin
S, W, D
green, indigo, yellow
C, D, F or S

blue, yellow, violet, green

doesn't disable
red, indigo, orange, wait
=end

describe 'Silence: green, indigo, red' do
  let(:game) { Game.new }

  it 'restricts the use of blue, yellow, violet, and green' do
    sync({ left: Silence.new.sequence },
         {})

    summary[:a][:left][:spell][:name].should eq 'Silence'
    summary[:b][:left][:restrictions][:commands].should eq [:red, :indigo, :orange, :wait]
    summary[:b][:right][:restrictions][:commands].should eq [:red, :indigo, :orange, :wait]

    game.enchantment_status[:b][:left].should eq Silence
  end

  it 'restricted commands are changed on subsquent turn' do
    sync({ left: Silence.new.sequence },
         {})

    game.turn({ left: :red }, { left: :yellow, right: :yellow })
    summary[:b][:left][:command].should eq :wait
  end

  it 'can be reflected' do
    sync({ left: Silence.new.sequence },
         { left: Reflect.new.sequence,
           right: Reflect.new.assist_sequence })

    summary[:a][:left][:spell][:name].should eq 'Silence'
    summary[:a][:left][:spell][:nullified].should eq true
    summary[:a][:left][:restrictions][:commands].should eq [:red, :indigo, :orange, :wait]
    summary[:a][:right][:restrictions][:commands].should eq [:red, :indigo, :orange, :wait]
  end

  it 'can be countered' do
    sync({ left: Silence.new.sequence },
         { left: CounterSpell.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Silence'
    summary[:a][:left][:spell][:nullified].should eq true
    summary[:a][:left][:restrictions].should be nil
    summary[:a][:right][:restrictions].should be nil
    summary[:b][:left][:restrictions].should be nil
    summary[:b][:right][:restrictions].should be nil
  end

  it 'cannot be shielded against' do
    sync({ left: Silence.new.sequence },
         { left: Shield.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Silence'
    summary[:a][:left][:spell][:nullified].should eq false
    summary[:b][:left][:restrictions][:commands].should eq [:red, :indigo, :orange, :wait]
    summary[:b][:right][:restrictions][:commands].should eq [:red, :indigo, :orange, :wait]
  end
end
