
      Program main
*     ================================================================ *
      implicit none

*     Arrays           
*     ================================================================ *
      character filename*60
      character foxString*34
      character foxReadString*34
      character sonnetString*31
      character sonnetReadString*31
      character action*15

*     Externals
*     ================================================================ *
      external xdr_open
      external xdr_character

      filename = 'strings.xdr'

*     Part I: Writing
*     ================================================================ *
      action = 'write'

      call xdr_open(filename, action)
      print *, ' '
      print *, '   XDR file opened for writing.'
      print *, '   Strings for transfer are ...'

*     Initialization
*     ==================================================================
      foxString    = "The quick brown fox jumps over ..."
      sonnetString = "A successful use of libsonnet.a"

      print *, '      ', foxString
      print *, '      ', sonnetString

      print *, ' '
      print *, '   Encoding to XDR ....'

      call xdr_character(foxString)
      call xdr_character(sonnetString)

      call xdr_close()

*     Part II: Reading
*     ================================================================ *
      action = 'read'

      call xdr_open(filename, action)
      print *, ' '
      print *, '   XDR file opened for reading.'

      print *, '   Decoding from XDR ...'

      call xdr_character(foxReadString)
      call xdr_character(sonnetReadString)

      print *, ' '
      print *, '   The decoded strings are ..'
      print *, '      ', foxReadString
      print *, '      ', sonnetReadString

      call xdr_close()
      stop ' Normal end in main'
      end


