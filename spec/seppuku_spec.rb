require './spec/spec_helper.rb'

=begin
F = violet
P = red
S = green
W = indigo
D = yellow
C = blue, blue
(stab) = Kunai
nothing () = Wait
=end

describe 'instant death' do
  let(:game) { Game.new }

  it 'casting orange orange causes instant death' do
    game.turn({ left: :orange, right: :orange },
              {})

    game.damage_for(:a).should eq 30
    game.over?.should be true
    game.winner.should be :b
  end

  it 'casting red red causes instant death' do
    game.turn({ left: :red, right: :red },
              {})

    game.damage_for(:a).should eq 30
    game.over?.should be true
    game.winner.should be :b
  end

  it 'can\'t be nullified by a shield' do
    summary = game.turn({ left: :red, right: :red },
                        { right: :red })

    summary[:a][:left][:spell][:nullified].should be false
    summary[:a][:right][:spell][:nullified].should be false
    game.damage_for(:a).should eq 30
    game.over?.should be true
    game.winner.should be :b
  end
end
