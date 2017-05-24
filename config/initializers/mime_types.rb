# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
Mime::Type.register "application/x-pkcs7-certificates", :p7b
Mime::Type.register "application/pkcs7-mime", :p7b

Mime::Type.register "application/x-pkcs7-crl", :crl
Mime::Type.register "application/pkix-crl", :crl