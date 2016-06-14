require "io/console"

module ET
  class Formatter
    attr_reader :data, :headers

    def initialize(data, *headers)
      @data = data
      @headers = headers
    end

    def print_table
      table = build_table
      table.each { |row| puts row }
    end

    def build_table
      return ["No challenges assigned"] if data.empty?

      result = []

      result << build_row(headers, column_widths, YELLOW)
      result << "\e[34m" + ("-" * total_width) + "\e[0m"

      data.each do |row|
        values = headers.map { |header| row[header] }
        result << build_row(values, column_widths, WHITE)
      end

      result
    end

    private

    def column_widths
      headers.map do |header|
        data.map { |row| row[header].length }.max
      end
    end

    def total_width
      column_widths.reduce(0) do |width, sum|
        sum + width + 3
      end
    end

    def build_row(row, widths, color)
      row.zip(widths).map do |value, width|
        " \e[#{color}m%-#{width}s\e[0m " % value
      end.join("\e[34m|\e[0m")
    end

    def window_width
      IO.console.winsize[1]
    end

    def window_height
      IO.console.winsize[0]
    end

    CLEAR   = 0
    BOLD    = 1
    BLACK   = 30
    RED     = 31
    GREEN   = 32
    YELLOW  = 33
    BLUE    = 34
    MAGENTA = 35
    CYAN    = 36
    WHITE   = 37
  end
end
