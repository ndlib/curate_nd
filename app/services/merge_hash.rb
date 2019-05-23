class MergeHash
  # we need to merge the hashes, such that we
  # 1) combine data with the same keys
  # 2) do not duplicate any values which are in both
  # 3) do not lose keys from either hash.
  def merge_hashes(h1, h2)
    # first, we do a standard merge
    combined_hash = h2.merge(h1)
    # then we do extra processing, with hashes removed, to add in anything which would have gotten excluded by the first merge.
    h1.merge(h2) do |key, x1, x2|
      # key = key which is in both hashes
      # x1 = value for key from h1
      # x2 = value for key from h2
      if x1.kind_of?(Hash) && x1.kind_of?(Hash)
        (x1.keys + x2.keys).uniq.each do |k|
          combined_hash[key][k] = merge_values(x1[k], x2[k])
        end
      else
        combined_hash[key] = merge_values(x1, x2)
      end
    end
    combined_hash
  end

  def merge_values(x1, x2)
    if x1.kind_of?(Hash) && x1.kind_of?(Hash)
      # these are two hashes with the same key, so we want to continue with a recursive merge.
      merge_hashes(x1, x2)
    else
      # we don't care what type of values we have... we just turn them both into arrays and merge them together into a common array.
      return (Array.wrap(x1)+Array.wrap(x2)).uniq
    end
  end
end
