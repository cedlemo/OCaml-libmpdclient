[1mdiff --git a/lib/Connection_lwt.ml b/lib/Connection_lwt.ml[m
[1mindex f4ce387..150d993 100644[m
[1m--- a/lib/Connection_lwt.ml[m
[1m+++ b/lib/Connection_lwt.ml[m
[36m@@ -224,7 +224,7 @@[m [mlet command_response mpd_data =[m
 [m
 let full_mpd_idle_event mpd_data =[m
   let pattern = "changed: \\(\\(\n\\|.\\)*\\)OK\n" in[m
[31m-  match check_full_response mpd_data pattern 1 13 with[m
[32m+[m[32m  match check_full_response mpd_data pattern 1 12 with[m
   | Incomplete -> command_response mpd_data (* Check if there is an empty response that follow an noidle command *)[m
   | Complete response -> Complete response[m
 [m
