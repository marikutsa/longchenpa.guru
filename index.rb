#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

FILTER_UA_ONLY = true
PATTERNS = [ '*.txt', '*/*.txt', '*/*/*.txt', '*/*/*/*.txt', '*/*/*/*/*.txt' ]
to_size = {}
header = nil
bytes = 0
total = 0
count = 0

PATTERNS.each do |pattern|
  Dir.glob(pattern).each do |file|
    next unless File.file?(file)
    File.foreach(file, encoding: 'UTF-8') do |line|
      size, tmp = line.bytesize, line.scrub.strip
      tmp.start_with?('@#/_/') ? (to_size[header] ||= bytes if header
                header, bytes = tmp, size) : (bytes += size if header) end
    to_size[header] ||= bytes if header
    header = bytes = nil
  end
end

return puts 'Не знайдено жодного заголовка' if to_size.empty?

def human_size(bytes)
  units = %w[B KiB MiB GiB TiB]
  return "#{bytes} B" if bytes < 1024
  exp = (Math.log(bytes) / Math.log(1024)).floor
  format('%.2f %s', bytes.to_f / (1024 ** exp), units[exp])
end

to_size.keys.sort.each do |header|
  has_ua = header.match?(/[\u0400-\u04FF\u0500-\u052F\u2DE0-\u2DFF\uA640-\uA69F\u1C80-\u1C8F]/)
  next if FILTER_UA_ONLY && !has_ua
  bytes = to_size[header]
  total += bytes
  count += 1
  puts "#{human_size(bytes).rjust(12)} #{header}"
end

label = FILTER_UA_ONLY ? 'з українським перекладом' : 'усіх унікальних'
puts "\nЗагальний розмір вмісту творів #{label}: #{human_size(total)}"
puts "Кількість унікальних творів: #{count}"
puts "Оброблено файлів: #{PATTERNS.sum { |p| Dir.glob(p).size }}"

# 2025 (c) Лонгчен Осал
