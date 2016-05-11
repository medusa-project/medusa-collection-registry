# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.register 'application/xls', :xls # for exporting book tracker items
Mime::Type.register 'text/tab-separated-values', :tsv # for exporting cfs directory trees as tsv