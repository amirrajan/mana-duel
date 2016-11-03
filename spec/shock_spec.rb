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

describe 'Shock:' do
  let(:game) { Game.new([Shock.new, Wait.new]) }

  it 'a ninja team shocks another, causing damage' do
    game.turn({ left: :orange },
              {})

    game.damage_for(:b).should eq 1
  end

  it 'both teams throw shock causing damage (eventually refactor this to not allow both members to shock)' do
    game.turn({ left: :orange },
              { left: :orange })

    game.damage_for(:b).should eq 1
    game.damage_for(:a).should eq 1
  end

  it 'all members shock causing damage' do
    game.turn({ left: :orange, right: :orange },
              { left: :orange, right: :orange })

    game.damage_for(:b).should eq 2
    game.damage_for(:a).should eq 2
  end
end

describe 'Shock: summary' do
  let(:game) { Game.new([Shock.new, Wait.new]) }

  it 'displays a summary' do
    summary = game.turn({ left: :orange },
                        {})

    game.damage_for(:b).should eq 1

    summary[:turn].should eq 1

    summary[:a][:left][:command].should eq :orange
    summary[:a][:left][:spell][:name].should eq 'Shock'
    summary[:a][:left][:spell][:nullified].should eq false

    summary[:b][:right][:command].should eq :wait
    summary[:b][:right][:spell][:name].should eq ''
    summary[:b][:right][:spell][:nullified].should eq false

    summary[:a][:right][:command].should eq :wait
    summary[:a][:right][:spell][:name].should eq ''
    summary[:a][:right][:spell][:nullified].should eq false

    summary[:b][:left][:command].should eq :wait
    summary[:b][:left][:spell][:name].should eq ''
    summary[:b][:left][:spell][:nullified].should eq false
  end
end
