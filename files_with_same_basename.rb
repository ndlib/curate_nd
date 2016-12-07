filenames = {}
%w(lib app).each do |subdir|
  Dir.glob("/Users/jfriesen/git/curate_nd/#{subdir}/**/*.rb").each do |filename|
    basename = File.basename(filename)
    filenames[basename] ||= []
    filenames[basename] << filename
  end
end

filenames.each do |basename, paths|
  next if paths.size == 1
  puts "=-"*40
  puts "#{basename}"
  paths.each do |path|
    puts "\t#{path}"
  end
end
