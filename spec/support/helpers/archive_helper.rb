require "zlib"
require "rubygems/package"

module ArchiveHelper
  def read_file_from_gzipped_archive(archive_path, filename)
    Zlib::GzipReader.open(archive_path) do |gz|
      contents = nil

      Gem::Package::TarReader.new(gz) do |tar|
        contents = tar.seek(filename) { |f| f.read }
      end

      contents
    end
  end

  def list_files_in_gzipped_archive(archive_path)
    file_names = nil

    Zlib::GzipReader.open(archive_path) do |gz|
      Gem::Package::TarReader.new(gz) do |tar|
        file_names = tar.entries.map { |entry| entry.full_name }
      end
    end

    file_names
  end
end
