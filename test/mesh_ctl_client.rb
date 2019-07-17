#!/usr/bin/env ruby

# Menu main:
# Available commands:
# -------------------
# config                                            Configuration Model Submenu
# onoff                                             On/Off Model Submenu
# list                                              List available controllers
# show [ctrl]                                       Controller information
# select <ctrl>                                     Select default controller
# security [0(low)/1(medium)/2(high)]               Display or change provision security level
# info [dev]                                        Device information
# connect [net_idx] [dst]                           Connect to mesh network or node on network
# discover-unprovisioned <on/off>                   Look for devices to provision
# provision <uuid>                                  Initiate provisioning
# power <on/off>                                    Set controller power
# disconnect [dev]                                  Disconnect device
# mesh-info                                         Mesh networkinfo (provisioner)
# local-info                                        Local mesh node info
# menu <name>                                       Select submenu
# version                                           Display version
# quit                                              Quit program
# exit                                              Quit program
# help                                              Display help about this program
# export                                            Print evironment variables

# Menu config:
# Available commands:
# -------------------
# target <unicast>                                  Set target node to configure
# composition-get [page_num]                        Get composition data
# netkey-add <net_idx>                              Add network key
# netkey-del <net_idx>                              Delete network key
# appkey-add <app_idx>                              Add application key
# appkey-del <app_idx>                              Delete application key
# bind <ele_idx> <app_idx> <mod_id> [cid]           Bind app key to a model
# mod-appidx-get <ele_addr> <model id>              Get model app_idx
# ttl-set <ttl>                                     Set default TTL
# ttl-get                                           Get default TTL
# pub-set <ele_addr> <pub_addr> <app_idx> <per (step|res)> <re-xmt (cnt|per)> <mod id> [cid]
#                                                   Set publication
# pub-get <ele_addr> <model>                        Get publication
# proxy-set <proxy>                                 Set proxy state
# proxy-get                                         Get proxy state
# ident-set <net_idx> <state>                       Set node identity state
# ident-get <net_idx>                               Get node identity state
# beacon-set <state>                                Set node identity state
# beacon-get                                        Get node beacon state
# relay-set <relay> <rexmt count> <rexmt steps>     Set relay
# relay-get                                         Get relay
# hb-pub-set <pub_addr> <count> <period> <ttl> <features> <net_idx> Set heartbeat publish
# hb-pub-get                                        Get heartbeat publish
# hb-sub-set <src_addr> <dst_addr> <period>         Set heartbeat subscribe
# hb-sub-get                                        Get heartbeat subscribe
# sub-add <ele_addr> <sub_addr> <model id>          Add subscription
# sub-get <ele_addr> <model id>                     Get subscription
# node-reset                                        Reset a node and remove it from network
# back                                              Return to main menu
# version                                           Display version
# quit                                              Quit program
# exit                                              Quit program
# help                                              Display help about this program
# export                                            Print evironment variables

require "socket"
require "../lib/command"

server = TCPSocket.new("127.0.0.1", 4000)
cmd = Command.new(server)

loop do
  print "Type a command to send: \n => "
  request = gets
  cmd.new_command(request)

  loop do
    line = cmd.response_gets(5000)
    break unless line
    puts line
  end
  cmd.processed

end