require "rubygems/package"
require "pry"

class ET::ArchiveManager
  attr_reader :archive, :destination, :unpacked_files

  def initialize(archive, destination)
    @archive = archive
    @destination = destination
  end

  def delete_archive
    File.delete(archive)
  end

  def unpack
    @unpacked_files = []
    File.open(archive, "rb") do |tar_gz|
      uncompress(tar_gz)
    end
    @unpacked_files
  end

  private

  def uncompress(file)
    Zlib::GzipReader.open(file) do |tar|
      process_tar(tar)
    end
  end

  def process_tar(tar)
    Gem::Package::TarReader.new(tar) do |entries|
      entries.each { |entry| create_file(entry) }
    end
  end

  def create_file(entry)
    if entry.file?
      filename = File.join(destination, entry.full_name)
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, "wb") do |f|
        f.write(entry.read)
      end
      File.chmod(entry.header.mode, filename)
      @unpacked_files << filename
    end
  end
end
