#!/usr/bin/env ruby
# encoding: UTF-8

filter_ua_only = true
patterns = [ '*/*.txt', '*/*/*.txt', '*/*/*/*.txt', '*/*/*/*/*.txt' ]
header_to_file = {}

patterns.each do |pattern|
  Dir.glob(pattern).each do |file|
    begin
      File.open(file, 'r:UTF-8') do |f|
        first_line = f.gets
        if first_line && first_line.start_with?('@#/_/')
          header = first_line.chomp
          header_to_file[header] ||= file
        end
      end
    rescue => e
      warn "Помилка читання #{file}: #{e.message}"
    end
  end
end

def human_size(bytes)
  units = %w[B KiB MiB GiB TiB]
  if bytes < 1024
    "#{bytes} #{units[0]}"
  else
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = units.size - 1 if exp >= units.size
    "%.2f #{units[exp]}" % (bytes.to_f / 1024**exp)
  end
end

unique_headers = header_to_file.keys.sort
total_size_bytes = 0
count = 0

unique_headers.each do |header|
  title_part = header.split('/').last.strip
  has_ukrainian = title_part.match?(/[\u0400-\u04FF\u0500-\u052F\u2DE0-\u2DFF\uA640-\uA69F\u1C80-\u1C8F]/)
  next if filter_ua_only && !has_ukrainian
  file_path = header_to_file[header]
  size_bytes = File.size(file_path)
  total_size_bytes += size_bytes
  count += 1
  size_str = human_size(size_bytes).rjust(10)
  puts "#{size_str} #{header}"
end

summary_label = filter_ua_only ? "файлів з українським перекладом" : "усіх знайдених файлів"
puts "\nЗагальний розмір #{summary_label}: #{human_size(total_size_bytes)}"
puts "Кількість: #{count}"

