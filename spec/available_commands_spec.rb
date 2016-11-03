require './spec/spec_helper.rb'

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

describe 'available commands' do
  it 'gives unique commands for spells' do
    AvailableCommands.new.for([Wait.new]).should eq []

    AvailableCommands.new.for([Shock.new]).should eq [:orange]

    AvailableCommands.new.for([CounterSpell.new]).should eq [:indigo,
                                                             :red,
                                                             :green]
  end

  specify 'game provides command list' do
    Game.new([
               Missile.new,
               Shock.new,
               Wait.new
             ]).available_commands.should eq [:orange, :green, :yellow]
  end
end
