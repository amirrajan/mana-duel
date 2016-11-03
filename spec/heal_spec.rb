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

describe 'Heal (yellow, violet, indigo): ' do
  let(:game) { Game.new }

  it 'heals one damage' do
    game.turn({ left: :orange },
              { right: :orange })

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
    game.turn({ left: :orange },
              { right: :orange })

    game.damage_for(:a).should eq 1
    game.damage_for(:b).should eq 1

    sync({ left: Shield.new.sequence },
         { right: Heal.new.sequence })

    game.turn_summaries.last[:b][:right][:spell][:nullified].should be false
  end
end
