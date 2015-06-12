(*
 * Copyright (c) 2015 Christiano F. Haesbaert <haesbaert@haesbaert.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Dhcp_cpkt
open Sexplib.Conv

type op =
  | Bootrequest
  | Bootreply
  | Unknown with sexp

type htype =
  | Ethernet_10mb
  | Other with sexp

type flags =
  | Broadcast
  | Unicast with sexp

type chaddr =
  | Hwaddr of Macaddr.t
  | Cliid of string with sexp

type msgtype =
  | DHCPDISCOVER (* value 1 *)
  | DHCPOFFER    (* value 2 *)
  | DHCPREQUEST  (* value 3 *)
  | DHCPDECLINE  (* value 4 *)
  | DHCPACK      (* value 5 *)
  | DHCPNAK      (* value 6 *)
  | DHCPRELEASE  (* value 7 *)
  | DHCPINFORM   (* value 8 *)
  with sexp

let msgtype_of_int = function
  | 1 -> DHCPDISCOVER (* value 1 *)
  | 2 -> DHCPOFFER    (* value 2 *)
  | 3 -> DHCPREQUEST  (* value 3 *)
  | 4 -> DHCPDECLINE  (* value 4 *)
  | 5 -> DHCPACK      (* value 5 *)
  | 6 -> DHCPNAK      (* value 6 *)
  | 7 -> DHCPRELEASE  (* value 7 *)
  | 8 -> DHCPINFORM   (* value 8 *)
  | v -> invalid_arg ("No message type for int " ^ (string_of_int v))

type parameter_request =
  | Subnet_mask                      (* code 1 *)
  | Time_offset                      (* code 2 *)
  | Routers                          (* code 3 *)
  | Time_servers                     (* code 4 *)
  | Name_servers                     (* code 5 *)
  | Dns_servers                      (* code 6 *)
  | Log_servers                      (* code 7 *)
  | Cookie_servers                   (* code 8 *)
  | Lpr_servers                      (* code 9 *)
  | Impress_servers                  (* code 10 *)
  | Rsclocation_servers              (* code 11 *)
  | Hostname                         (* code 12 *)
  | Bootfile_size                    (* code 13 *)
  | Merit_dumpfile                   (* code 14 *)
  | Domain_name                      (* code 15 *)
  | Swap_server                      (* code 16 *)
  | Root_path                        (* code 17 *)
  | Extension_path                   (* code 18 *)
  | Ipforwarding                     (* code 19 *)
  | Nlsr                             (* code 20 *)
  | Policy_filters                   (* code 21 *)
  | Max_datagram                     (* code 22 *)
  | Default_ip_ttl                   (* code 23 *)
  | Pmtu_ageing_timo                 (* code 24 *)
  | Pmtu_plateau_table               (* code 25 *)
  | Interface_mtu                    (* code 26 *)
  | All_subnets_local                (* code 27 *)
  | Broadcast_addr                   (* code 28 *)
  | Perform_mask_discovery           (* code 29 *)
  | Mask_supplier                    (* code 30 *)
  | Perform_router_disc              (* code 31 *)
  | Router_sol_addr                  (* code 32 *)
  | Static_routes                    (* code 33 *)
  | Trailer_encapsulation            (* code 34 *)
  | Arp_cache_timo                   (* code 35 *)
  | Ethernet_encapsulation           (* code 36 *)
  | Tcp_default_ttl                  (* code 37 *)
  | Tcp_keepalive_interval           (* code 38 *)
  | Tcp_keepalive_garbage            (* code 39 *)
  | Nis_domain                       (* code 40 *)
  | Nis_servers                      (* code 41 *)
  | Ntp_servers                      (* code 42 *)
  | Vendor_specific                  (* code 43 *)
  | Netbios_name_servers             (* code 44 *)
  | Netbios_datagram_distrib_servers (* code 45 *)
  | Netbios_node                     (* code 46 *)
  | Netbios_scope                    (* code 47 *)
  | Xwindow_font_servers             (* code 48 *)
  | Xwindow_display_managers         (* code 49 *)
  | Request_ip                       (* code 50 *)
  | Ip_lease_time                    (* code 51 *)
  | Option_overload                  (* code 52 *)
  | Message_type                     (* code 53 *)
  | Server_identifier                (* code 54 *)
  | Parameter_requests               (* code 55 *)
  | Message                          (* code 56 *)
  | Max_message                      (* code 57 *)
  | Renewal_t1                       (* code 58 *)
  | Rebinding_t2                     (* code 59 *)
  | Vendor_class_id                  (* code 60 *)
  | Client_id                        (* code 61 *)
  | Nis_plus_domain                  (* code 64 *)
  | Nis_plus_servers                 (* code 65 *)
  | Tftp_server_name                 (* code 66 *)
  | Bootfile_name                    (* code 67 *)
  | Mobile_ip_home_agent             (* code 68 *)
  | Smtp_servers                     (* code 69 *)
  | Pop3_servers                     (* code 70 *)
  | Nntp_servers                     (* code 71 *)
  | Www_servers                      (* code 72 *)
  | Finger_servers                   (* code 73 *)
  | Irc_servers                      (* code 74 *)
  | Streettalk_servers               (* code 75 *)
  | Streettalk_da                    (* code 76 *)
  | Unknown of int
  with sexp

let int_of_parameter_request = function
  | Subnet_mask                       -> 1  (* code 1 *)
  | Time_offset                       -> 2  (* code 2 *)
  | Routers                           -> 3  (* code 3 *)
  | Time_servers                      -> 4  (* code 4 *)
  | Name_servers                      -> 5  (* code 5 *)
  | Dns_servers                       -> 6  (* code 6 *)
  | Log_servers                       -> 7  (* code 7 *)
  | Cookie_servers                    -> 8  (* code 8 *)
  | Lpr_servers                       -> 9  (* code 9 *)
  | Impress_servers                   -> 10 (* code 10 *)
  | Rsclocation_servers               -> 11 (* code 11 *)
  | Hostname                          -> 12 (* code 12 *)
  | Bootfile_size                     -> 13 (* code 13 *)
  | Merit_dumpfile                    -> 14 (* code 14 *)
  | Domain_name                       -> 15 (* code 15 *)
  | Swap_server                       -> 16 (* code 16 *)
  | Root_path                         -> 17 (* code 17 *)
  | Extension_path                    -> 18 (* code 18 *)
  | Ipforwarding                      -> 19 (* code 19 *)
  | Nlsr                              -> 20 (* code 20 *)
  | Policy_filters                    -> 21 (* code 21 *)
  | Max_datagram                      -> 22 (* code 22 *)
  | Default_ip_ttl                    -> 23 (* code 23 *)
  | Pmtu_ageing_timo                  -> 24 (* code 24 *)
  | Pmtu_plateau_table                -> 25 (* code 25 *)
  | Interface_mtu                     -> 26 (* code 26 *)
  | All_subnets_local                 -> 27 (* code 27 *)
  | Broadcast_addr                    -> 28 (* code 28 *)
  | Perform_mask_discovery            -> 29 (* code 29 *)
  | Mask_supplier                     -> 30 (* code 30 *)
  | Perform_router_disc               -> 31 (* code 31 *)
  | Router_sol_addr                   -> 32 (* code 32 *)
  | Static_routes                     -> 33 (* code 33 *)
  | Trailer_encapsulation             -> 34 (* code 34 *)
  | Arp_cache_timo                    -> 35 (* code 35 *)
  | Ethernet_encapsulation            -> 36 (* code 36 *)
  | Tcp_default_ttl                   -> 37 (* code 37 *)
  | Tcp_keepalive_interval            -> 38 (* code 38 *)
  | Tcp_keepalive_garbage             -> 39 (* code 39 *)
  | Nis_domain                        -> 40 (* code 40 *)
  | Nis_servers                       -> 41 (* code 41 *)
  | Ntp_servers                       -> 42 (* code 42 *)
  | Vendor_specific                   -> 43 (* code 43 *)
  | Netbios_name_servers              -> 44 (* code 44 *)
  | Netbios_datagram_distrib_servers  -> 45 (* code 45 *)
  | Netbios_node                      -> 46 (* code 46 *)
  | Netbios_scope                     -> 47 (* code 47 *)
  | Xwindow_font_servers              -> 48 (* code 48 *)
  | Xwindow_display_managers          -> 49 (* code 49 *)
  | Request_ip                        -> 50 (* code 50 *)
  | Ip_lease_time                     -> 51 (* code 51 *)
  | Option_overload                   -> 52 (* code 52 *)
  | Message_type                      -> 53 (* code 53 *)
  | Server_identifier                 -> 54 (* code 54 *)
  | Parameter_requests                -> 55 (* code 55 *)
  | Message                           -> 56 (* code 56 *)
  | Max_message                       -> 57 (* code 57 *)
  | Renewal_t1                        -> 58 (* code 58 *)
  | Rebinding_t2                      -> 59 (* code 59 *)
  | Vendor_class_id                   -> 60 (* code 60 *)
  | Client_id                         -> 61 (* code 61 *)
  | Nis_plus_domain                   -> 64 (* code 64 *)
  | Nis_plus_servers                  -> 65 (* code 65 *)
  | Tftp_server_name                  -> 66 (* code 66 *)
  | Bootfile_name                     -> 67 (* code 67 *)
  | Mobile_ip_home_agent              -> 68 (* code 68 *)
  | Smtp_servers                      -> 69 (* code 69 *)
  | Pop3_servers                      -> 70 (* code 70 *)
  | Nntp_servers                      -> 71 (* code 71 *)
  | Www_servers                       -> 72 (* code 72 *)
  | Finger_servers                    -> 73 (* code 73 *)
  | Irc_servers                       -> 74 (* code 74 *)
  | Streettalk_servers                -> 75 (* code 75 *)
  | Streettalk_da                     -> 76 (* code 76 *)
  | Unknown x		              -> x

let parameter_request_of_int = function
  | 1  -> Subnet_mask                        (* code 1 *)
  | 2  -> Time_offset                        (* code 2 *)
  | 3  -> Routers                            (* code 3 *)
  | 4  -> Time_servers                       (* code 4 *)
  | 5  -> Name_servers                       (* code 5 *)
  | 6  -> Dns_servers                        (* code 6 *)
  | 7  -> Log_servers                        (* code 7 *)
  | 8  -> Cookie_servers                     (* code 8 *)
  | 9  -> Lpr_servers                        (* code 9 *)
  | 10 -> Impress_servers                    (* code 10 *)
  | 11 -> Rsclocation_servers                (* code 11 *)
  | 12 -> Hostname                           (* code 12 *)
  | 13 -> Bootfile_size                      (* code 13 *)
  | 14 -> Merit_dumpfile                     (* code 14 *)
  | 15 -> Domain_name                        (* code 15 *)
  | 16 -> Swap_server                        (* code 16 *)
  | 17 -> Root_path                          (* code 17 *)
  | 18 -> Extension_path                     (* code 18 *)
  | 19 -> Ipforwarding                       (* code 19 *)
  | 20 -> Nlsr                               (* code 20 *)
  | 21 -> Policy_filters                     (* code 21 *)
  | 22 -> Max_datagram                       (* code 22 *)
  | 23 -> Default_ip_ttl                     (* code 23 *)
  | 24 -> Pmtu_ageing_timo                   (* code 24 *)
  | 25 -> Pmtu_plateau_table                 (* code 25 *)
  | 26 -> Interface_mtu                      (* code 26 *)
  | 27 -> All_subnets_local                  (* code 27 *)
  | 28 -> Broadcast_addr                     (* code 28 *)
  | 29 -> Perform_mask_discovery             (* code 29 *)
  | 30 -> Mask_supplier                      (* code 30 *)
  | 31 -> Perform_router_disc                (* code 31 *)
  | 32 -> Router_sol_addr                    (* code 32 *)
  | 33 -> Static_routes                      (* code 33 *)
  | 34 -> Trailer_encapsulation              (* code 34 *)
  | 35 -> Arp_cache_timo                     (* code 35 *)
  | 36 -> Ethernet_encapsulation             (* code 36 *)
  | 37 -> Tcp_default_ttl                    (* code 37 *)
  | 38 -> Tcp_keepalive_interval             (* code 38 *)
  | 39 -> Tcp_keepalive_garbage              (* code 39 *)
  | 40 -> Nis_domain                         (* code 40 *)
  | 41 -> Nis_servers                        (* code 41 *)
  | 42 -> Ntp_servers                        (* code 42 *)
  | 43 -> Vendor_specific                    (* code 43 *)
  | 44 -> Netbios_name_servers               (* code 44 *)
  | 45 -> Netbios_datagram_distrib_servers   (* code 45 *)
  | 46 -> Netbios_node                       (* code 46 *)
  | 47 -> Netbios_scope                      (* code 47 *)
  | 48 -> Xwindow_font_servers               (* code 48 *)
  | 49 -> Xwindow_display_managers           (* code 49 *)
  | 50 -> Request_ip                         (* code 50 *)
  | 51 -> Ip_lease_time                      (* code 51 *)
  | 52 -> Option_overload                    (* code 52 *)
  | 53 -> Message_type                       (* code 53 *)
  | 54 -> Server_identifier                  (* code 54 *)
  | 55 -> Parameter_requests                 (* code 55 *)
  | 56 -> Message                            (* code 56 *)
  | 57 -> Max_message                        (* code 57 *)
  | 58 -> Renewal_t1                         (* code 58 *)
  | 59 -> Rebinding_t2                       (* code 59 *)
  | 60 -> Vendor_class_id                    (* code 60 *)
  | 61 -> Client_id                          (* code 61 *)
  | 64 -> Nis_plus_domain                    (* code 64 *)
  | 65 -> Nis_plus_servers                   (* code 65 *)
  | 66 -> Tftp_server_name                   (* code 66 *)
  | 67 -> Bootfile_name                      (* code 67 *)
  | 68 -> Mobile_ip_home_agent               (* code 68 *)
  | 69 -> Smtp_servers                       (* code 69 *)
  | 70 -> Pop3_servers                       (* code 70 *)
  | 71 -> Nntp_servers                       (* code 71 *)
  | 72 -> Www_servers                        (* code 72 *)
  | 73 -> Finger_servers                     (* code 73 *)
  | 74 -> Irc_servers                        (* code 74 *)
  | 75 -> Streettalk_servers                 (* code 75 *)
  | 76 -> Streettalk_da                      (* code 76 *)
  | x  -> Unknown x

type dhcp_option =
  | Subnet_mask of Ipaddr.V4.t              (* code 1 *)
  | Time_offset of int32                    (* code 2 *)
  | Routers of Ipaddr.V4.t list             (* code 3 *)
  | Time_servers of Ipaddr.V4.t list        (* code 4 *)
  | Name_servers of Ipaddr.V4.t list        (* code 5 *)
  | Dns_servers of Ipaddr.V4.t list         (* code 6 *)
  | Log_servers of Ipaddr.V4.t list         (* code 7 *)
  | Cookie_servers of Ipaddr.V4.t list      (* code 8 *)
  | Lpr_servers of Ipaddr.V4.t list         (* code 9 *)
  | Impress_servers of Ipaddr.V4.t list     (* code 10 *)
  | Rsclocation_servers of Ipaddr.V4.t list (* code 11 *)
  | Hostname of string                      (* code 12 *)
  | Bootfile_size of int                    (* code 13 *)
  | Merit_dumpfile of string                (* code 14 *)
  | Domain_name of string                   (* code 15 *)
  | Swap_server of Ipaddr.V4.t              (* code 16 *)
  | Root_path of string                     (* code 17 *)
  | Extension_path of string                (* code 18 *)
  | Ipforwarding of bool                    (* code 19 *)
  | Nlsr of bool                            (* code 20 *)
  | Policy_filters of Ipaddr.V4.Prefix.t list (* code 21 *)
  | Max_datagram of int                     (* code 22 *)
  | Default_ip_ttl of int                   (* code 23 *)
  | Pmtu_ageing_timo of int32               (* code 24 *)
  | Pmtu_plateau_table of int list          (* code 25 *)
  | Interface_mtu of int                    (* code 26 *)
  | All_subnets_local of bool               (* code 27 *)
  | Broadcast_addr of Ipaddr.V4.t           (* code 28 *)
  | Perform_mask_discovery of bool          (* code 29 *)
  | Mask_supplier of bool                   (* code 30 *)
  | Perform_router_disc of bool             (* code 31 *)
  | Router_sol_addr of Ipaddr.V4.t          (* code 32 *)
  | Static_routes of Ipaddr.V4.Prefix.t list(* code 33 *)
  | Trailer_encapsulation of bool           (* code 34 *)
  | Arp_cache_timo of int32                 (* code 35 *)
  | Ethernet_encapsulation of bool          (* code 36 *)
  | Tcp_default_ttl of int                  (* code 37 *)
  | Tcp_keepalive_interval of int32         (* code 38 *)
  | Tcp_keepalive_garbage of int            (* code 39 *)
  | Nis_domain of string                    (* code 40 *)
  | Nis_servers of Ipaddr.V4.t list         (* code 41 *)
  | Ntp_servers of Ipaddr.V4.t list         (* code 42 *)
  | Vendor_specific of string               (* code 43 *)
  | Netbios_name_servers of Ipaddr.V4.t list(* code 44 *)
  | Netbios_datagram_distrib_servers of Ipaddr.V4.t list (* code 45 *)
  | Netbios_node of int                     (* code 46 *)
  | Netbios_scope of string                 (* code 47 *)
  | Xwindow_font_servers of Ipaddr.V4.t list(* code 48 *)
  | Xwindow_display_managers of Ipaddr.V4.t list (* code 49 *)
  | Request_ip of Ipaddr.V4.t               (* code 50 *)
  | Ip_lease_time of int32                  (* code 51 *)
  | Option_overload of int                  (* code 52 *)
  | Message_type of msgtype                 (* code 53 *)
  | Server_identifier of Ipaddr.V4.t        (* code 54 *)
  | Parameter_requests of parameter_request list (* code 55 *)
  | Message of string                       (* code 56 *)
  | Max_message of int                      (* code 57 *)
  | Renewal_t1 of int32                     (* code 58 *)
  | Rebinding_t2 of int32                   (* code 59 *)
  | Vendor_class_id of string               (* code 60 *)
  | Client_id of chaddr                     (* code 61 *)
  | Nis_plus_domain of string               (* code 64 *)
  | Nis_plus_servers of Ipaddr.V4.t list    (* code 65 *)
  | Tftp_server_name of string              (* code 66 *)
  | Bootfile_name of string                 (* code 67 *)
  | Mobile_ip_home_agent of Ipaddr.V4.t list(* code 68 *)
  | Smtp_servers of Ipaddr.V4.t list        (* code 69 *)
  | Pop3_servers of Ipaddr.V4.t list        (* code 70 *)
  | Nntp_servers of Ipaddr.V4.t list        (* code 71 *)
  | Www_servers of Ipaddr.V4.t list         (* code 72 *)
  | Finger_servers of Ipaddr.V4.t list      (* code 73 *)
  | Irc_servers of Ipaddr.V4.t list         (* code 74 *)
  | Streettalk_servers of Ipaddr.V4.t list  (* code 75 *)
  | Streettalk_da of Ipaddr.V4.t list       (* code 76 *)
  | Unknown
  with sexp

type pkt = {
  op      : op;
  htype   : htype;
  hlen    : int;
  hops    : int;
  xid     : int32;
  secs    : int;
  flags   : flags;
  ciaddr  : Ipaddr.V4.t;
  yiaddr  : Ipaddr.V4.t;
  siaddr  : Ipaddr.V4.t;
  giaddr  : Ipaddr.V4.t;
  chaddr  : chaddr;
  sname   : string;
  file    : string;
  options : dhcp_option list;
} with sexp

let pkt_min_len = 236

(* 10KB, maybe there is an asshole doing insane stuff with Jumbo Frames *)
let make_buf () = Cstruct.create (1024 * 10) 
let op_of_buf buf = match get_cpkt_op buf with
  | 1 -> Bootrequest
  | 2 -> Bootreply
  | _ -> Unknown

let htype_of_buf buf = match get_cpkt_htype buf with
  | 1 -> Ethernet_10mb
  | _ -> Other

let hlen_of_buf = get_cpkt_hlen
let hops_of_buf = get_cpkt_hops
let xid_of_buf = get_cpkt_xid
let secs_of_buf = get_cpkt_secs

let flags_of_buf buf =
  if ((get_cpkt_flags buf) land 0x8000) <> 0 then
    Broadcast
  else
    Unicast

let ciaddr_of_buf buf = Ipaddr.V4.of_int32 (get_cpkt_ciaddr buf)
let yiaddr_of_buf buf = Ipaddr.V4.of_int32 (get_cpkt_yiaddr buf)
let siaddr_of_buf buf = Ipaddr.V4.of_int32 (get_cpkt_siaddr buf)
let giaddr_of_buf buf = Ipaddr.V4.of_int32 (get_cpkt_giaddr buf)
let chaddr_of_buf buf htype hlen =
  let s = copy_cpkt_chaddr buf in
  if htype = Ethernet_10mb && hlen = 6 then
    Hwaddr (Macaddr.of_bytes_exn (Bytes.sub s 0 6))
  else
    Cliid (copy_cpkt_chaddr buf)

let sname_of_buf buf = copy_cpkt_sname buf
let file_of_buf buf = copy_cpkt_file buf

let options_of_buf buf buf_len =
  let rec collect_options buf options =
    let code = Cstruct.get_uint8 buf 0 in
    let () = Log.debug "saw option code %u" code in
    let len = Cstruct.get_uint8 buf 1 in
    let body = Cstruct.shift buf 2 in
    let bad_len = Printf.sprintf "Malformed len %d in option %d" len code in
    (* discard discards the option from the resulting list *)
    let discard () = collect_options (Cstruct.shift body len) options in
    (* take includes the option in the resulting list *)
    let take op = collect_options (Cstruct.shift body len) (op :: options) in
    let get_8 () = if len <> 1 then invalid_arg bad_len else
        Cstruct.get_uint8 body 0 in
    let get_8_list () =
      let rec loop offset octets =
        if offset = len then octets else
          let octet = Cstruct.get_uint8 body offset in
          loop (succ offset) (octet :: octets)
      in
      if len <= 0 then invalid_arg bad_len else
        List.rev (loop 0 [])
    in
    let get_bool () = match (get_8 ()) with
      | 1 -> true
      | 0 -> false
      | v -> invalid_arg ("invalid value for bool: " ^ string_of_int v)
    in
    let get_16 () = if len <> 2 then invalid_arg bad_len else
        Cstruct.BE.get_uint16 body 0 in
    let get_32 () = if len <> 4 then invalid_arg bad_len else
        Cstruct.BE.get_uint32 body 0 in
    let get_ip () = if len <> 4 then invalid_arg bad_len else
        Ipaddr.V4.of_int32 (get_32 ()) in
    let get_16_list () =
      let rec loop offset shorts =
        if offset = len then shorts else
          let short = Cstruct.BE.get_uint16 body offset in
          loop ((succ offset) * 2) (short :: shorts)
      in
      if ((len mod 2) <> 0) || len <= 0 then invalid_arg bad_len else
        List.rev (loop 0 [])
    in
    (* Fetch ipv4s from options *)
    let get_ip_list ?(min_len=4) () =
      let rec loop offset ips =
        if offset = len then ips else
          let word = Cstruct.BE.get_uint32 body offset in
          let ip = Ipaddr.V4.of_int32 word in
          loop ((succ offset) * 4) (ip :: ips)
      in
      if ((len mod 4) <> 0) || len < min_len then invalid_arg bad_len else
        List.rev (loop 0 [])
    in
    (* Get a list of ip pairs *)
    let get_prefix_list () =
      let rec loop offset prefixes =
        if offset = len then
          prefixes
        else
          let addr = Ipaddr.V4.of_int32 (Cstruct.BE.get_uint32 body offset) in
          let mask = Ipaddr.V4.of_int32
              (Cstruct.BE.get_uint32 body (offset + 4)) in
          try
            let prefix = Ipaddr.V4.Prefix.of_netmask mask addr in
            loop ((succ offset) * 8) (prefix :: prefixes)
          with Ipaddr.Parse_error (a, b) -> invalid_arg (a ^ ": " ^ b)
      in
      if ((len mod 8) <> 0) || len <= 0 then
        invalid_arg bad_len
      else
        List.rev (loop 0 [])
    in
    let get_string () =  if len < 1 then invalid_arg bad_len else
        Cstruct.copy body 0 len
    in
    let get_client_id () =  if len < 2 then invalid_arg bad_len else
        let s = Cstruct.copy body 1 (len - 1) in
        if (Cstruct.get_uint8 body 0) = 1 && len = 7 then
            Hwaddr (Macaddr.of_bytes_exn s)
        else
          Cliid s
    in
    match code with
    | 1 ->   take (Subnet_mask (get_ip ()))
    | 2 ->   take (Time_offset (get_32 ()))
    | 3 ->   take (Routers (get_ip_list ()))
    | 4 ->   take (Time_servers (get_ip_list ()))
    | 5 ->   take (Name_servers (get_ip_list ()))
    | 6 ->   take (Dns_servers (get_ip_list ()))
    | 7 ->   take (Log_servers (get_ip_list ()))
    | 8 ->   take (Cookie_servers (get_ip_list ()))
    | 9 ->   take (Lpr_servers (get_ip_list ()))
    | 10 ->  take (Impress_servers (get_ip_list ()))
    | 11 ->  take (Rsclocation_servers (get_ip_list ()))
    | 12 ->  take (Hostname (get_string ()))
    | 13 ->  take (Bootfile_size (get_16 ()))
    | 14 ->  take (Merit_dumpfile (get_string ()))
    | 15 ->  take (Domain_name (get_string ()))
    | 16 ->  take (Swap_server (get_ip ()))
    | 17 ->  take (Root_path (get_string ()))
    | 18 ->  take (Extension_path (get_string ()))
    | 19 ->  take (Ipforwarding (get_bool ()))
    | 20 ->  take (Nlsr (get_bool ()))
    | 21 ->  take (Policy_filters (get_prefix_list ()))
    | 22 ->  take (Max_datagram (get_16 ()))
    | 23 ->  take (Default_ip_ttl (get_8 ()))
    | 24 ->  take (Pmtu_ageing_timo (get_32 ()))
    | 25 ->  take (Pmtu_plateau_table (get_16_list ()))
    | 26 ->  take (Interface_mtu (get_16 ()))
    | 27 ->  take (All_subnets_local (get_bool ()))
    | 28 ->  take (Broadcast_addr (get_ip ()))
    | 29 ->  take (Perform_mask_discovery (get_bool ()))
    | 30 ->  take (Mask_supplier (get_bool ()))
    | 31 ->  take (Perform_router_disc (get_bool ()))
    | 32 ->  take (Router_sol_addr (get_ip ()))
    | 33 ->  take (Static_routes (get_prefix_list ()))
    | 34 ->  take (Trailer_encapsulation (get_bool ()))
    | 35 ->  take (Arp_cache_timo (get_32 ()))
    | 36 ->  take (Ethernet_encapsulation (get_bool ()))
    | 37 ->  take (Tcp_default_ttl (get_8 ()))
    | 38 ->  take (Tcp_keepalive_interval (get_32 ()))
    | 39 ->  take (Tcp_keepalive_garbage (get_8 ()))
    | 40 ->  take (Nis_domain (get_string ()))
    | 41 ->  take (Nis_servers (get_ip_list ()))
    | 42 ->  take (Ntp_servers (get_ip_list ()))
    | 43 ->  take (Vendor_specific (get_string ()))
    | 44 ->  take (Netbios_name_servers (get_ip_list ()))
    | 45 ->  take (Netbios_datagram_distrib_servers (get_ip_list ()))
    | 46 ->  take (Netbios_node (get_8 ()))
    | 47 ->  take (Netbios_scope (get_string ()))
    | 48 ->  take (Xwindow_font_servers (get_ip_list ()))
    | 49 ->  take (Xwindow_display_managers (get_ip_list ()))
    | 50 ->  take (Request_ip (get_ip ()))
    | 51 ->  take (Ip_lease_time (get_32 ()))
    | 52 ->  take (Option_overload (get_8 ()))
    | 53 ->  take (Message_type (msgtype_of_int (get_8 ())))
    | 54 ->  take (Server_identifier (get_ip ()))
    | 55 ->  take (Parameter_requests (get_8_list () |>
                                       List.map parameter_request_of_int))
    | 56 ->  take (Message (get_string ()))
    | 57 ->  take (Max_message (get_16 ()))
    | 58 ->  take (Renewal_t1 (get_32 ()))
    | 59 ->  take (Rebinding_t2 (get_32 ()))
    | 60 ->  take (Vendor_class_id (get_string ()))
    | 61 ->  take (Client_id (get_client_id ()))
    | 64 ->  take (Nis_plus_domain (get_string ()))
    | 65 ->  take (Nis_plus_servers (get_ip_list ()))
    | 66 ->  take (Tftp_server_name (get_string ()))
    | 67 ->  take (Bootfile_name (get_string ()))
    | 68 ->  take (Mobile_ip_home_agent (get_ip_list ~min_len:0 ()))
    | 69 ->  take (Smtp_servers (get_ip_list ()))
    | 70 ->  take (Pop3_servers (get_ip_list ()))
    | 71 ->  take (Nntp_servers (get_ip_list ()))
    | 72 ->  take (Www_servers (get_ip_list ()))
    | 73 ->  take (Finger_servers (get_ip_list ()))
    | 74 ->  take (Irc_servers (get_ip_list ()))
    | 75 ->  take (Streettalk_servers (get_ip_list ()))
    | 76 ->  take (Streettalk_da (get_ip_list ()))
    | 255 -> options            (* End of option list *)
    | code ->
      Log.warn "Unknown option code %d" code;
      discard ()
  in
  (* Extends options if it finds an Option_overload *)
  let extend_options buf options =
    let rec search = function
      | [] -> None
      | opt :: tl -> match opt with
        | Option_overload v -> Some v
        | _ -> search tl
    in
    match search options with
    | None -> options           (* Nothing to do, identity function *)
    | Some v -> match v with
      | 1 -> collect_options (get_cpkt_file buf) options    (* It's in file *)
      | 2 -> collect_options (get_cpkt_sname buf) options   (* It's in sname *)
      | 3 -> collect_options (get_cpkt_file buf) options |> (* OMG both *)
             collect_options (get_cpkt_sname buf)
      | _ -> invalid_arg ("Invalid overload code: " ^ string_of_int v)
  in
  (* Handle a pkt with no options *)
  if buf_len = pkt_min_len then
    []
  else
    (* Look for magic cookie *)
    let cookie = Cstruct.BE.get_uint32 buf pkt_min_len in
    if cookie <> 0x63825363l then
      invalid_arg "Invalid cookie";
    let options_start = Cstruct.shift buf (pkt_min_len + 4) in
    (* Jump over cookie and start options, also extend them if necessary *)
    collect_options options_start [] |>
    extend_options buf |>
    List.rev

(* Raises invalid_arg if packet is malformed *)
let pkt_of_buf buf len =
  if len < pkt_min_len then
    invalid_arg (Printf.sprintf "packet too small %d < %d" len pkt_min_len);
  let op = op_of_buf buf in
  let htype = htype_of_buf buf in
  let hlen = hlen_of_buf buf in
  let hops = hops_of_buf buf in
  let xid = xid_of_buf buf in
  let secs = secs_of_buf buf in
  let flags = flags_of_buf buf in
  let ciaddr = ciaddr_of_buf buf in
  let yiaddr = yiaddr_of_buf buf in
  let siaddr = siaddr_of_buf buf in
  let giaddr = giaddr_of_buf buf in
  let chaddr = chaddr_of_buf buf htype hlen in
  let sname = sname_of_buf buf in
  let file = file_of_buf buf in
  let options = options_of_buf buf len in
  { op; htype; hlen; hops; xid; secs; flags; ciaddr; yiaddr;
    siaddr; giaddr; chaddr; sname; file; options }

let msgtype_of_options =
  Util.find_map (function Message_type m -> Some m | _ -> None)
let parameter_requests_of_options =
  Util.find_map (function Parameter_requests pr -> Some pr | _ -> None)
let client_id_of_options =
  Util.find_map (function Client_id id -> Some id | _ -> None)

let client_id_of_pkt pkt =
  match client_id_of_options pkt.options with
  | Some id -> id
  | None -> pkt.chaddr

(* str_of_* functions *)
let to_hum f x = Sexplib.Sexp.to_string_hum (f x)
let str_of_op = to_hum sexp_of_op
let str_of_htype = to_hum sexp_of_htype
let str_of_hlen = string_of_int
let str_of_hops = string_of_int
let str_of_xid xid = Printf.sprintf "0x%lx" xid
let str_of_secs = string_of_int
let str_of_flags = to_hum sexp_of_flags
let str_of_ciaddr = Ipaddr.V4.to_string
let str_of_ciaddr = Ipaddr.V4.to_string
let str_of_yiaddr = Ipaddr.V4.to_string
let str_of_siaddr = Ipaddr.V4.to_string
let str_of_giaddr = Ipaddr.V4.to_string
let str_of_chaddr = to_hum sexp_of_chaddr
let str_of_sname sname = sname
let str_of_file file = file
let str_of_msgtype = to_hum sexp_of_msgtype
let str_of_option = to_hum sexp_of_dhcp_option
let str_of_options = to_hum (sexp_of_list sexp_of_dhcp_option)
let str_of_pkt = to_hum sexp_of_pkt
