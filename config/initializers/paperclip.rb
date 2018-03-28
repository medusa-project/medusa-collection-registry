## As of paperclip 5.2, the monkey patch below will disable the content-type spoofing
# test. Why might we do this instead of using the built in means? Preservation may wish
# to attach fairly unusual extension/content types that aren't very well recognized, and
# it might be hard to maintain the list, at least requiring some significant amount of manual
# effort. Conversely, given that only admin types can make attachments we may not be so
# worried about spoofing. So if we ever want to enable this use case in the simplest
# possible way, we just need to activate this code.

# module Paperclip
#   class MediaTypeSpoofDetector
#     def spoofed?
#       false
#     end
#   end
# end
