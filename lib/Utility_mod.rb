
module Utility_mod
  def obtain_files_list
    Dir.glob('saves/*.yml').sort_by { |f| File.mtime(f) }.reverse
  end
end
