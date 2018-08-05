open Lwt.Infix

let reporter path =
  let buf_fmt ~like =
    let b = Buffer.create 512 in
    Fmt.with_buffer ~like b,
    fun () -> let m = Buffer.contents b in Buffer.reset b; m
  in
  let app, app_flush = buf_fmt ~like:Fmt.stdout in
  let dst, dst_flush = buf_fmt ~like:Fmt.stderr in
  let reporter = Logs_fmt.reporter ~app ~dst () in
  let report src level ~over k msgf =
    let k () =
      let write () =
        let flags = [Unix.O_WRONLY; Unix.O_CREAT; Unix.O_APPEND] in
        let perm = 0o777 in
        let log_file = path ^ "/libmpdclient.log" in
        let err_file =  path ^ "/libmpdclient.err" in
        Lwt_io.open_file ~flags ~perm ~mode:Lwt_io.Output log_file
        >>= fun fd_log ->
          Lwt_io.open_file ~flags ~perm ~mode:Lwt_io.Output err_file
          >>= fun fd_err ->
            Lwt.return (fd_log, fd_err)
            >>= fun (fd_log', fd_err') ->
              match level with
              | Logs.App -> Lwt_io.write fd_log' (app_flush ())
              | _ -> Lwt_io.write fd_err' (dst_flush ())
                >>= fun () ->
                  Lwt_io.close fd_log'
                  >>= fun () ->
                    Lwt_io.close fd_err'
      in
      let unblock () = over (); Lwt.return_unit in
      Lwt.finalize write unblock |> Lwt.ignore_result;
      k ()
    in
    reporter.Logs.report src level ~over:(fun () -> ()) k msgf;
  in
  { Logs.report = report }

let file_exists f = try ignore (Unix.stat f); true with _ -> false

let setup () =
    let path = "./" in
    Logs.set_reporter (reporter path);
    Logs.set_level (Some Debug);
    Lwt.return_unit

let debuf message =
  Logs_lwt.debug (fun m -> m "%s" message)

let err message =
  Logs_lwt.err (fun m -> m "%s" message)
