#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

FILTER_UA_ONLY = false
PATTERNS = ['*.txt', '*/*.txt', '*/*/*.txt', '*/*/*/*.txt', '*/*/*/*/*.txt']

header_to_file = {}
total = 0
count = 0

PATTERNS.each do |pattern|
  Dir.glob(pattern) do |file|
    next unless File.file?(file)
    File.foreach(file, encoding: 'UTF-8') do |line|
      header = line.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').chomp.strip
      next if header.empty? || !header.start_with?('@#/_/')
      header_to_file[header] ||= file
    end
  rescue
    next
  end
end

return puts 'Не знайдено жодного заголовка' if header_to_file.empty?

def human_size(bytes)
  units = %w[B KiB MiB GiB TiB]
  return "#{bytes} B" if bytes < 1024
  exp = (Math.log(bytes) / Math.log(1024)).floor
  format('%.2f %s', bytes.to_f / (1024 ** exp), units[exp])
end

header_to_file.keys.sort.each do |header|
  title = header.split('/').last.strip
  has_ua = title.match?(/[\u0400-\u04FF\u0500-\u052F\u2DE0-\u2DFF\uA640-\uA69F\u1C80-\u1C8F]/)
  next if FILTER_UA_ONLY && !has_ua
  size = File.size(header_to_file[header])
  total += size
  count += 1
  puts "#{human_size(size).rjust(12)} #{header}"
end

label = FILTER_UA_ONLY ? 'з українським перекладом' : 'усіх унікальних'
puts "\nЗагальний розмір файлів #{label}: #{human_size(total)}"
puts "Кількість унікальних творів: #{count}"
puts "Оброблено файлів: #{PATTERNS.sum { |p| Dir.glob(p).size }}"

# 2025 (c) Лонгчен Осал
