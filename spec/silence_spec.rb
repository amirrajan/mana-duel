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

=begin
S, W, D
snake, rat, dog
C, D, F or S

ox, dog, tiger, snake

doesn't disable
dragon, rat, ram, wait
=end

describe 'Silence: snake, rat, dragon' do
  let(:game) { Game.new }

  it 'restricts the use of ox, dog, tiger, and snake' do
    sync({ left: Silence.new.sequence },
         {})

    summary[:a][:left][:spell][:name].should eq 'Silence'
    summary[:b][:left][:restrictions][:commands].should eq [:dragon, :rat, :ram, :wait]
    summary[:b][:right][:restrictions][:commands].should eq [:dragon, :rat, :ram, :wait]

    game.enchantment_status[:b][:left].should eq Silence
  end

  it 'restricted commands are changed on subsquent turn' do
    sync({ left: Silence.new.sequence },
         {})

    game.turn({ left: :dragon }, { left: :dog, right: :dog })
    summary[:b][:left][:command].should eq :wait
  end

  it 'can be reflected' do
    sync({ left: Silence.new.sequence },
         { left: Reflect.new.sequence,
           right: Reflect.new.assist_sequence })

    summary[:a][:left][:spell][:name].should eq 'Silence'
    summary[:a][:left][:spell][:nullified].should eq true
    summary[:a][:left][:restrictions][:commands].should eq [:dragon, :rat, :ram, :wait]
    summary[:a][:right][:restrictions][:commands].should eq [:dragon, :rat, :ram, :wait]
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
    summary[:b][:left][:restrictions][:commands].should eq [:dragon, :rat, :ram, :wait]
    summary[:b][:right][:restrictions][:commands].should eq [:dragon, :rat, :ram, :wait]
  end
end
