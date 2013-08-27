module Curate::BuildIdentifier

  BUILD_ID_FILE_PATH = Rails.root.join("config", "build-identifier.txt")
  DEFAULT_BUILD_ID = "#{DateTime.now.strftime("%Y")}.0"

  module_function

  def generate_next_build_id(path=BUILD_ID_FILE_PATH)
    # The file (BUILD_ID_FILE_PATH) is read to get the current build id.
    # So the following line is required to be outside of the block
    # as it reads the file before the same can be opened again for writing.
    new_build_id = next_id(path)

    File.open(path, 'w+') do |file|
      file.puts new_build_id
    end
  end

  def current_id(path=BUILD_ID_FILE_PATH)
    current_build_id = File.read(path)
    return current_build_id
  rescue
    DEFAULT_BUILD_ID
  end

  def next_id(path=BUILD_ID_FILE_PATH)

    current_build_year, current_build_number = extract_build_info(path)

    next_build_year= DateTime.now.strftime("%Y")
    next_build_number = current_build_number.to_i

    if check_if_same_year?(current_build_year, next_build_year)
      next_build_number += 1
    else
      next_build_number = 1
    end

    "#{next_build_year}.#{next_build_number}"
  end

  def extract_build_info(path)
    current_id(path).split(".")
  end

  def check_if_same_year?(current_year, next_year)
    current_year == next_year ? true : false
  end
end
