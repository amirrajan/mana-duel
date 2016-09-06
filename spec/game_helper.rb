def summary
  game.turn_summaries.last
end

# times the execution of spells so that land on the same turn by padding the smaller one with :waits
def sync team_a_sequences, team_b_sequences
  a_left_array = team_a_sequences[:left] || []
  a_right_array = team_a_sequences[:right] || []

  b_left_array = team_b_sequences[:left] || []
  b_right_array = team_b_sequences[:right] || []

  all_arrays = [a_left_array, a_right_array, b_left_array, b_right_array]

  max_padding = all_arrays.map(&:count).max

  all_arrays.each { |a| pad_with_waits a, max_padding }

  a_left_array.count.times do |i|
    game.turn({ left: a_left_array[i], right: a_right_array[i] },
              { left: b_left_array[i], right: b_right_array[i] })
  end
end

def pad_with_waits array, to_size
  (to_size - array.count).times { array.insert(0, :wait) }
end
