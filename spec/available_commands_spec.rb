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

describe 'available commands' do
  it 'gives unique commands for spells' do
    AvailableCommands.new.for([Wait.new]).should eq []

    AvailableCommands.new.for([Shock.new]).should eq [:ram]

    AvailableCommands.new.for([CounterSpell.new]).should eq [:rat,
                                                             :dragon,
                                                             :snake]
  end

  specify 'game provides command list' do
    Game.new([
               Missile.new,
               Shock.new,
               Wait.new
             ]).available_commands.should eq [:ram, :snake, :dog]
  end
end
