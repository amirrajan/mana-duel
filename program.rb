require 'formatador'
require_relative 'lib/spell.rb'
require_relative 'lib/available_commands.rb'
require_relative 'lib/activated_spells.rb'
require_relative 'lib/wait.rb'
require_relative 'lib/paralysis.rb'
require_relative 'lib/fast_lightning_bolt.rb'
require_relative 'lib/lightning_bolt.rb'
require_relative 'lib/silence.rb'
require_relative 'lib/ultimate_defense.rb'
require_relative 'lib/shock.rb'
require_relative 'lib/upheaval.rb'
require_relative 'lib/amnesia.rb'
require_relative 'lib/heal.rb'
require_relative 'lib/greater_heal.rb'
require_relative 'lib/counter_spell.rb'
require_relative 'lib/light_wounds.rb'
require_relative 'lib/shield.rb'
require_relative 'lib/reflect.rb'
require_relative 'lib/missile.rb'
require_relative 'lib/seppuku.rb'
require_relative 'lib/heavy_wounds.rb'
require_relative 'lib/sokushi.rb'
require_relative 'lib/next_sequence.rb'
require_relative 'lib/game.rb'
require 'io/console'
require 'pp'

game = Game.new
continue = true

def puts_f s, color = nil
  if s.is_a? Array
    Formatador.display_table(s)
  else
    if color
      Formatador.display_line("[#{color}]#{s}[/]")
    else
      Formatador.display_line(s)
    end
  end
end

def paralysis
  {
    :name => "Paralysis",
    :short => "v (3x)",
    :command => "violet, violet, violet",
    :description => "Forces one wizard to repeat the hand sign he performed last turn. The target depends on which mana pool executes the spell (left targets left, right targets right). Paralysis can only affect one mana pool at a time. Some hand signs will be changed to another to prevent complete impairment (blue changes to violet, yellow to green, and indigo to red).",
    :countered_by => "Counter Spell, Reflect, Ultimate Defense"
  }
end

def shield
  {
    :name => "Shield",
    :short => "r",
    :command => "red",
    :description => "Stops shock and missle damage from opponent's wizard for one turn.",
    :countered_by => nil
  }
end

def shock
  {
    :name => "Shock",
    :short => "o",
    :command => "orange",
    :description => "Does one point of damage.",
    :countered_by => "Shield, Ultimate Defense"
  }
end

def missile
  {
    :name => "Missile",
    :short => "y, g",
    :command => "yellow, green",
    :description => "Does one point of damage.",
    :countered_by => "Shield, Reflect, Counter Spell, Ultimate Defense"
  }
end

def light_wound
  {
    :name => "Light Wounds",
    :short => "i, v, r",
    :command => "indigo, violet, red (this spell will take three turns to execute, a wizard needs to execute indigo, then violet, then red)",
    :description => "Does two points of damage.",
    :countered_by => "Reflect, Counter Spell, Ultimate Defense"
  }
end

def heavy_wound
  {
    :name => "Heavy Wounds",
    :short => "i, r, v, g",
    :command => "indigo, red, violet, green (this spell will take four turns to execute, a wizard needs to execute indigo, then red, then violet, then green)",
    :description => "Does three points of damage.",
    :countered_by => "Reflect, Counter Spell, Ultimate Defense"
  }
end

def lighting_bolt
  {
    :name => "Lightning Bolt",
    :short => "g, v, v, g, g",
    :command => "green, violet, violet, green, green (the last command doubles up as the first command if executed one after another)",
    :description => "Does five points of damage.",
    :countered_by => "Reflect, Counter Spell, Ultimate Defense"
  }
end

def fast_lighting_bolt
  {
    :name => "Fast Lightning Bolt",
    :short => "i, g, g, [b, b] (once per game)",
    :command => "indigo, green, green, [blue, blue] (both mana pools of the wizard must cast the last color for spell to execute)",
    :description => "Does five points of damage. This spell can only be used once per match by each wizard.",
    :countered_by => "Reflect, Counter Spell, Ultimate Defense"
  }
end

def seppuku
  {
    :name => "Seppuku",
    :short => "[o, o] or [r, r] (instant forfeit)",
    :command => "[orange, orange] or [red, red] (if both mana pools on the wizard cast either orange or red, it's instant death for that wizard)",
    :description => "Curse does 30 points of damage to the wizard that casts the spell. Instant death.",
    :countered_by => nil
  }
end

def reflect
  {
    :name => "Reflect",
    :short => "[b, b], [i, i]",
    :command => "[blue, blue], [indigo, indigo] (both mana pools must issue both commands in unison)",
    :description => "Reflects spell back at opponent. Will not reflect Shock however.",
    :countered_by => nil
  }
end

def counter_spell
  {
    :name => "Counter Spell",
    :short => "i, r, r or i, i, y",
    :command => "indigo, red, red or indigo, indigo, yellow",
    :description => "Nullifies all attack spell except Shock or Sokushi.",
    :countered_by => nil
  }
end

def ultimate_defense
  {
    :name => "Ultimate Defense",
    :short => "[b, b], g, r, i",
    :command => "[blue, blue], green, red, indigo",
    :description => "Nullifies all attack spell.",
    :countered_by => nil
  }
end

def sokushi
  {
    :name => "Sokushi",
    :short => "r, i, r, v, y (3x), g",
    :command => "red, indigo, red, violet, yellow, yellow, yellow, green",
    :description => "Does 100 points of damage.",
    :countered_by => "Ultimate Defense"
  }
end

def heal
  {
    :name => "Heal",
    :short => "g, v, i",
    :command => "green, violet, indigo",
    :description => "Removes one point of damage.",
    :countered_by => nil
  }
end

def amnesia
  {
    :name => "Amnesia",
    :short => "g, r, r",
    :command => "green, red, red",
    :description => "When Amnesia is cast, opponent will be forced to repeat the same signs he performed before.",
    :countered_by => "Reflects, Counter Spell, Ultimate Defense"
  }
end

def upheaval
  {
    :name => "Upheaval",
    :short => "y, r, v",
    :command => "yellow, red, violet",
    :description => "When Upheaval is cast, opponent will have all of his sequences reset.",
    :countered_by => "Reflects, Counter Spell, Ultimate Defense"
  }
end

def silence
  {
    :name => "Silence",
    :short => "y, i, g",
    :command => "yellow, indigo, green",
    :description => "Disables the opponents ability to cast blue, green, violet, yellow.",
    :countered_by => "Reflects, CounterSpell, Ultimate Defense"
  }
end

def greater_heal
  {
    :name => "Greater Heal",
    :short => "g, v, r, i",
    :command => "green, violet, red, indigo",
    :description => "Removes two points of damage.",
    :countered_by => nil
  }
end

def color_to_hand_sign_map
  {
    'r' => :dragon,
    'o' => :ram,
    'g' => :snake,
    'y' => :dog,
    'b' => :ox,
    'i' => :rat,
    'v' => :tiger
  }
end

def hand_sign_to_color_map
  {
    dragon: 'red (r)',
    ram: 'orange (o)',
    snake: 'yellow (y)',
    dog: 'green (g)',
    ox: 'blue (b)',
    rat: 'indigo (i)',
    tiger: 'tiger (v)'
  }
end

def class_to_display_name
  {
    Sokushi => 'Sokushi',
    Silence => 'Silence',
    Paralysis => 'Paralysis',
    Upheaval => 'Upheaval',
    Amnesia => 'Amnesia',
    Heal => 'Heal',
    GreaterHeal => 'Greater Heal',
    UltimateDefense => 'Ultimate Defence',
    CounterSpell => 'Counter Spell',
    HeavyWounds => 'Heavy Wounds',
    LightWounds => 'Light Wounds',
    Shock => 'Shock',
    Shield => 'Shield',
    Missile => 'Missle',
    LightningBolt => 'Lightning Bolt',
    Reflect => 'Reflect',
    FastLightningBolt => 'Fast Lightning Bolt'
  }
end

def pretty_print_spells_by_command k, v
  puts_f hand_sign_to_color_map[k]

  puts_f v.sort_by { |s| s[:countdown] }.map do |s|
    {
      spell: class_to_display_name[s[:spell]],
      'turns til': s[:countdown]
    }
  end

  puts_f ""
end

def left_right_table_status_for_player id, sequence
  number = { a: 'P1', b: 'P2' }
  table = [ ]

  sequence[id][:left][:mins]
           .sort_by { |k, v| v[:countdown] }
           .each do |k, v|
    table << {
      "#{number[id]}, L Spell" => class_to_display_name[k],
      "#{number[id]}, L Time" => v[:countdown]
    }
  end

  i = 0
  sequence[id][:right][:mins]
           .sort_by { |k, v| v[:countdown] }
           .each do |k, v|
    table[i]["#{number[id]}, R Spell"] = class_to_display_name[k]
    table[i]["#{number[id]}, R Time"] = v[:countdown]
    i += 1
  end

  table
end

def print_left_right_status_for_player id, sequence
  number = { a: 1, b: 2 }

  puts_f "Player #{number[id]}", 'cyan'

  puts_f left_right_table_status_for_player(id, sequence)

  puts ""
end

def spell_descriptions
  [
    shield,
    shock,
    seppuku,
    missile,
    light_wound,
    heavy_wound,
    lighting_bolt,
    fast_lighting_bolt,
    amnesia,
    upheaval,
    paralysis,
    silence,
    heal,
    greater_heal,
    reflect,
    counter_spell,
    ultimate_defense,
    sokushi
  ]
end

def pretty_print_spells_full
  spell_descriptions.each do |s|
    puts_f "=== #{s[:name]}  ==="
    puts_f "#{s[:command]}"
    puts_f "Countered/Nullified by: #{s[:countered_by]}" if s[:countered_by]
    puts_f "#{s[:description]}"
    puts_f "\n"
  end
end

def pretty_print_spells_short
  spell_descriptions.each do |s|
    t = "#{s[:name]}: #{s[:short]}"
    t = t + " (#{s[:countered_by]})" if s[:countered_by]
    puts_f t
  end
end

current_turn = :player_1
turn = { player_1: { }, player_2: { } }
me = { player_1: :a, player_2: :b }
opponent = { player_1: :b, player_2: :a }

while continue
  if current_turn == :player_1
    puts_f 'Player 1, enter one of the commands below:', 'cyan'
  else
    puts_f 'Player 2, enter one of the commands below:', 'cyan'
  end

  puts_f [
    { command: 'c!', description: 'cast' },
    { command: 'a',  description: 'status all players' },
    { command: 't',  description: 'status for opponent (them)' },
    { command: 'u',  description: 'current player status (us)' },
    { command: 'fl', description: 'full list spells' },
    { command: 'l',  description: 'short list spells' },
    { command: 'e!', description: 'exits the game' },
  ]

  text = STDIN.noecho(&:gets).chomp

  next_sequence = game.next_sequence_for_turn[game.current_turn]

  if text == 'a'
    table_a = left_right_table_status_for_player :a, next_sequence
    table_b = left_right_table_status_for_player :b, next_sequence
    i = 0
    table_a_b = []
    table_a.each do |k, v|
      table_a_b_record = { }
      table_a_b_record['P1, L Spell'] = table_a[i]['P1, L Spell']
      table_a_b_record['P1, L Time'] = table_a[i]['P1, L Time']
      table_a_b_record['P1, R Spell'] = table_a[i]['P1, R Spell']
      table_a_b_record['P1, R Time'] = table_a[i]['P1, R Time']
      table_a_b_record['P2, L Spell'] = table_b[i]['P2, L Spell']
      table_a_b_record['P2, L Time'] = table_b[i]['P2, L Time']
      table_a_b_record['P2, R Spell'] = table_b[i]['P2, R Spell']
      table_a_b_record['P2, R Time'] = table_b[i]['P2, R Time']
      table_a_b << table_a_b_record
      i += 1
    end

    puts_f table_a_b
  elsif text == 't'
    puts_f left_right_table_status_for_player(opponent[current_turn], next_sequence)
  elsif text == 'u'
    puts_f left_right_table_status_for_player(me[current_turn], next_sequence)
  elsif text == 'l' || text == 'fl'
    if text == 'fl'
      pretty_print_spells_full
    else
      pretty_print_spells_short
    end
  elsif text == 'c!'
    casted = false
    mana_pool = :left

    while !casted
      if(mana_pool == :left)
        puts_f "What mana do you want to infuse for the LEFT spell? (roygbiv)"
        pp next_sequence[:a][:left][:by_command]
        turn_or_command = STDIN.noecho(&:gets).chomp
        turn[current_turn][:left] = turn_or_command
        mana_pool = :right
      else
        puts_f "What mana do you want to infuse for the Right spell? (roygbiv)"
        turn_or_command = STDIN.noecho(&:gets).chomp
        turn[current_turn][:right] = turn_or_command
        casted = true
        if(current_turn == :player_1)
          current_turn = :player_2
        else
          converted_turn_a = {
            left: color_to_hand_sign_map[turn[:player_1][:left]],
            right: color_to_hand_sign_map[turn[:player_1][:right]],
          }

          converted_turn_b = {
            left: color_to_hand_sign_map[turn[:player_2][:left]],
            right: color_to_hand_sign_map[turn[:player_2][:right]],
          }

          puts_f turn
          result = game.turn(converted_turn_a, converted_turn_b)
          puts_f result
          current_turn = :player_1
        end
      end
    end
  elsif text == 'exit'
    continue = false
  end
end
