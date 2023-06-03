# frozen_string_literal: false

# This module is for utility functions
module UtilityMod
  def obtain_files_list
    Dir.glob('saves/*.yml').sort_by { |f| File.mtime(f) }.reverse
  end
end
