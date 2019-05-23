require 'spec_helper'

describe MergeHash do
  let(:h1) do
    {
      pet: {
        cat: ["Melody", "Rosa"],
        dog: ["Mandy"],
        bird: ["Fidget", "Pixel"],
        snake: ["Cilantro"],
        axolotl: ["Kip"],
        ghost: ["Fred", "Wilma"]
      },
      house: "white",
      porch: "1",
      garage: true
    }
  end
  let(:h2) do
    {
      pet: {
        cat: ["Rinascita", "Zephyr", "Bella", "Lola"],
        dog: ["Torque"],
        ghost: ["Fred", "Barney"]
      },
      house: "blue",
      deck: "2",
      garage: {
        stalls: 2
      }
    }
  end
  let(:merged_hash) { described_class.new.merge_hashes(h1, h2) }

  describe 'merging two nested hashes' do
    it 'keeps duplicated keys and comines key values eliminating duplicates' do
      merged_hash
      expect(merged_hash[:pet][:cat]).to include("Melody", "Rosa", "Rinascita", "Zephyr", "Bella", "Lola")
      expect(merged_hash[:pet][:dog]).to include("Mandy", "Torque")
      expect(merged_hash[:pet][:bird]).to include("Fidget", "Pixel")
      expect(merged_hash[:pet][:snake]).to include("Cilantro")
      expect(merged_hash[:pet][:axolotl]).to include("Kip")
      expect(merged_hash[:pet][:ghost]).to include("Fred", "Barney", "Wilma")
      expect(merged_hash[:house]).to include("white", "blue")
      expect(merged_hash[:porch]).to include("1")
      expect(merged_hash[:deck]).to include("2")
    end
  end
end
