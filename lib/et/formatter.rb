module ET
  class Formatter
    def self.print_table(data, *headers)
      column_widths = headers.map do |header|
        data.map { |row| row[header].length }.max
      end

      total_width = column_widths.reduce(0) do |width, sum|
        sum + width + 3
      end

      header = build_row(headers, column_widths, YELLOW)

      puts header
      puts "\e[34m" + ("-" * total_width) + "\e[0m"

      data.each do |row|
        values = headers.map { |header| row[header] }
        puts build_row(values, column_widths, WHITE)
      end
    end

    private

    def self.build_row(row, widths, color)
      row.zip(widths).map do |value, width|
        " \e[#{color}m%-#{width}s\e[0m " % value
      end.join("\e[34m|\e[0m")
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
