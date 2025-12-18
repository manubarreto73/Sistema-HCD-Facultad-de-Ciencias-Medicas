WickedPdf.configure do |config|
  if Gem.win_platform?
    # Windows
    config.exe_path = 'C:/Program Files/wkhtmltopdf/bin/wkhtmltopdf.exe'
  else
    # Linux / macOS
    # wkhtmltopdf debe estar instalado y disponible en el PATH
    config.exe_path = `which wkhtmltopdf`.strip
  end

  config.enable_local_file_access = true
  config.layout = 'pdf'
end

