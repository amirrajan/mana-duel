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

describe 'Heal (dog, tiger, rat): ' do
  let(:game) { Game.new }

  it 'heals one damage' do
    game.turn({ left: :ram },
              { right: :ram })

    game.damage_for(:a).should eq 1
    game.damage_for(:b).should eq 1

    sync({},
         { left: Heal.new.sequence })

    game.damage_for(:a).should eq 1
    game.damage_for(:b).should eq 0
  end

  it 'it does nothing if team has no damage' do
    sync({},
         { left: Heal.new.sequence })

    game.damage_for(:a).should eq 0
    game.damage_for(:b).should eq 0
  end

  it 'is unaffected by shield (generally, defensive spells cant be nullified)' do
    game.turn({ left: :ram },
              { right: :ram })

    game.damage_for(:a).should eq 1
    game.damage_for(:b).should eq 1

    sync({ left: Shield.new.sequence },
         { right: Heal.new.sequence })

    game.turn_summaries.last[:b][:right][:spell][:nullified].should be false
  end
end
