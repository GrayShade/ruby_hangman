require 'fileutils'
class Test
  def test
    files_list = Dir.glob('**/*.yml', base: 'saves')
    # files_list = files_list.sort_by(||)
    files_list = Dir.glob('saves/*.yml').sort_by { |f| File.mtime(f) }.reverse
    # files_list = Dir['*'].sort_by{ |f| File.mtime(f) }

    files_list = files_list.map.with_index { |file, idx| "#{idx + 1}) #{File.basename(file, '.*')}" }
    # puts files_list
    puts FileUtils.rm_rf(Dir.glob('saves/*.yml'))
    puts files_list
  end
end

obj = Test.new
obj.test
