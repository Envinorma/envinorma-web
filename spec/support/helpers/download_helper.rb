# frozen_string_literal: true

require 'zip'

module DownloadHelpers
  TIMEOUT = 1
  PATH    = Rails.root.join('tmp/downloads')

  module_function

  def downloads
    Dir[PATH.join('*')]
  end

  def output
    Dir[PATH.join('*')]
  end

  def download
    downloads.first
  end

  def download_content(filename)
    wait_for_download
    parse(DOWNLOAD_DIR.join(filename))
  end

  def raw_download_content(filename)
    wait_for_download
    unzip_file(DOWNLOAD_DIR.join(filename))
    File.open(OUTPUT_DIR.join('content.xml')).read.force_encoding(Encoding::UTF_8)
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?
    end
  end

  def downloaded?
    !downloading? && downloads.any?
  end

  def downloading?
    downloads.grep(/\.part$/).any?
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
    FileUtils.rm_r(output)
  end

  DOWNLOAD_DIR = Rails.root.join('tmp/downloads')
  OUTPUT_DIR = DOWNLOAD_DIR.join('output')

  def unzip_file(file, destination = OUTPUT_DIR)
    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        f_path = File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      end
    end
  end

  def parse(file)
    unzip_file(file)
    OUTPUT_DIR.join('content.xml')
    a = ActionController::Base.new
    a.append_view_path OUTPUT_DIR
    a.render_to_string template: 'content', layout: false
  end
end
