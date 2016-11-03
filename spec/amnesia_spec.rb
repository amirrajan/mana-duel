require 'spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = [blue, blue]
(stab) = orange
nothing () = Wait
=end

describe 'Amnesia: :yellow, red, red' do
  let(:game) { Game.new }

  specify 'team b must repeat the commands from the last turn (the spell only lasts for one turn)' do
    sync({ left: Amnesia.new.sequence }, { left: Shock.new.sequence, right: Shield.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Amnesia'
    summary[:b][:left][:restrictions][:commands].should eq [:orange]
    summary[:b][:left][:restrictions][:because_of].should eq 'Amnesia'
    summary[:b][:right][:restrictions][:commands].should eq [:red]
    summary[:b][:right][:restrictions][:because_of].should eq 'Amnesia'
    game.amnesia?(:a).should eq false
    game.amnesia?(:b).should eq true

    summary = game.turn({ left: :red },
                        { left: :wait, right: :wait })

    summary[:b][:left][:command].should eq :orange
    summary[:b][:right][:command].should eq :red

    summary = game.turn({ left: :red },
                        { left: :yellow, right: :yellow })

    summary[:b][:left][:command].should eq :yellow
    summary[:b][:right][:command].should eq :yellow
  end

  specify 'team a must repeat the commands from the last turn (the spell only lasts for one turn)' do
    sync({ left: Shock.new.sequence, right: Shield.new.sequence },
         { left: Amnesia.new.sequence })

    summary[:b][:left][:spell][:name].should eq 'Amnesia'
    summary[:a][:left][:restrictions][:commands].should eq [:orange]
    summary[:a][:left][:restrictions][:because_of].should eq 'Amnesia'
    summary[:a][:right][:restrictions][:commands].should eq [:red]
    summary[:a][:right][:restrictions][:because_of].should eq 'Amnesia'

    game.turn({ left: :wait, right: :wait },
              { left: :red })

    summary[:a][:left][:command].should eq :orange
    summary[:a][:right][:command].should eq :red

    summary = game.turn({ left: :yellow, right: :yellow },
                        { left: :red })

    summary[:a][:left][:command].should eq :yellow
    summary[:a][:right][:command].should eq :yellow
  end

  it 'cannot be shielded' do
    sync({ left: Amnesia.new.sequence },
         { left: Shield.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Amnesia'
    summary[:a][:left][:spell][:nullified].should eq false
    summary[:b][:left][:restrictions][:commands].should eq [:red]
    summary[:b][:left][:restrictions][:because_of].should eq 'Amnesia'
  end

  it 'can be countered' do
    sync({ left: Amnesia.new.sequence },
         { left: CounterSpell.new.sequence })

    summary[:a][:left][:spell][:name].should eq 'Amnesia'
    summary[:a][:left][:spell][:nullified].should eq true
    summary[:b][:left][:spell][:name].should eq 'CounterSpell'
    summary[:b][:left][:spell][:nullified].should eq false
    summary[:b][:left][:restrictions].should be nil
    summary[:b][:right][:restrictions].should be nil
    summary[:a][:left][:restrictions].should be nil
    summary[:a][:right][:restrictions].should be nil

    game.amnesia?(:b).should eq false
  end

  it 'can be reflected' do
    sync({ left: Amnesia.new.sequence },
         { left: Reflect.new.sequence, right: Reflect.new.assist_sequence })

    summary[:a][:left][:spell][:name].should eq 'Amnesia'
    summary[:a][:left][:spell][:nullified].should eq true
    summary[:a][:left][:restrictions][:commands].should eq [:red]
    summary[:a][:right][:restrictions][:commands].should eq [:wait]

    summary[:b][:right][:spell][:name].should eq 'Reflect'
    summary[:b][:right][:spell][:nullified].should eq false
    summary[:b][:left][:restrictions].should be nil
    summary[:b][:right][:restrictions].should be nil

    game.amnesia?(:b).should eq false
    game.amnesia?(:a).should eq true
  end
end
