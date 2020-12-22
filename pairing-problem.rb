# @param {Integer} n
# @param {Integer} k = 2
# @return {Integer[][]}
# generate combinations or can still use ruby inbuild combination
def get_combination(n, k = 2)
  if n == k
    [(1..n).to_a]
  elsif k == 1
    (1..n).map { |i| [i] }
  else
    (get_combination(n - 1, k - 1).map { |i| i << n }).concat(get_combination(n - 1, k))
  end
end

# @param {Integer} n
# @return {Integer[[]]}
# get all n/2 uniq options that can be used in a week
# eg given 4,=> [[[1, 4], [2, 3]], [[2, 4], [1, 3]], [[3, 4], [1, 2]]]
# eg given 5 => [[[1, 5], [2, 4]], [[2, 5], [1, 4]], [[3, 5], [1, 2]], [[4, 5], [1, 3]]]
# all valid pairs, choose one
def get_all_unique_combinations(n)
  possible_pairs = get_combination(n)
  possible_pairs.combination(n / 2).each_with_object([]) do |group, acc|
    base = n.even? ? n : n - 1
    next unless group.flatten.uniq.length == (base)

    next if acc.find do |existing_pairs|
              existing_pairs & group != []
            end

    acc << group
  end
end

# @params {nested array} all_combo
# @return {array[]}
# track the already chosen then remove from the returning array
def get_uniq_given_past_weeks(all_combo, track)
  good_combo = []
  all_combo.each_with_object([]) do |group, acc|
    track.each { |i| acc << i }
    next if acc.find { |existing_group| existing_group & group != [] }

    good_combo << group
  end
  good_combo
end

# @params {array} weeks
# @return {hash[][]} pair per each week
def pairs(weeks)
  results = Hash.new(0)
  track = []

  weeks.each_with_index do |value, i|
    if value > 1
      idx = i + 1
      all_combo = get_all_unique_combinations(value)
      if idx == 1
        pick = all_combo[0]

      else
        good_combo = get_uniq_given_past_weeks(all_combo, track)
        # when all combination have already been picked,
        # clear, the track to allow dublication now
        if good_combo.empty?
          track = []
          all_combo = get_all_unique_combinations(value)
          good_combo = get_uniq_given_past_weeks(all_combo, track)
        end
        pick = good_combo[0]

      end
      track << pick
      results["week #{idx}"] = pick
    else
      results['Error'] = 'Only when you have more than one student'
    end
  end
  results
end
p pairs([4, 5, 5, 5, 5, 5]) # return pairs but with repeat on the last weeks
p pairs([8, 8, 8, 8, 8, 8, 8]) # return pairs, given the nature, expect no repeat, large number have high combination count
p pairs([2, 3, 3]) # should have no repeat => {"week 1"=>[[1, 2]], "week 2"=>[[1, 3]], "week 3"=>[[2, 3]]}
p pairs([2]) # should have just one pair => {"week 1"=>[[1, 2]]}
p pairs([1]) # should return an error => {"Error"=>"Only when you have more than one student"}
