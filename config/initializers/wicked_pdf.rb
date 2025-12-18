# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.configure do |config|
  # Ruta al ejecutable de wkhtmltopdf en Windows
  config.exe_path = 'C:/Program Files/wkhtmltopdf/bin/wkhtmltopdf.exe'

  # Necesario para que wkhtmltopdf pueda leer assets locales (CSS, imágenes)
  config.enable_local_file_access = true

  # Layout por defecto (opcional, pero recomendado)
  config.layout = 'pdf'
end

