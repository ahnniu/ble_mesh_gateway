#!/usr/bin/env ruby

require "socket"

class MockMeshCtlServer
  def initialize(ip = "127.0.0.1", port)
    @server = TCPServer.new(ip, port)
    puts "listening port: #{port}"
    @client = nil
    start_listening
    manual_response
  end

  def start_listening
    t = Thread.start(@server.accept) do |client|
      puts "Connection #{client}"
      @client ||= client
      loop do
        msg = client.gets
        msg && parse(msg)
      end

    end
    t.join
  end

  def parse(msg)
    args = msg.split(' ')
    cmd = args.shift.to_sym

    begin
      send cmd, args
    rescue Exception => e
      puts "Command: #{cmd} not implemented, please send response through the command line"
    end
  end

  def manual_response
    loop do
      response = $stdin.gets.chomp
      @client.puts(response) if @client
    end
  end


  def discover_unprovisioned(onoff)

    on_response = <<-EOF
      SetDiscoveryFilter success
      Discovery started
      Adapter property changed
      [CHG] Controller B8:27:EB:29:BA:EF Discovering: yes
                      Mesh Provisioning Service (00001827-0000-1000-8000-00805f9b34fb)
                              Device UUID: dd010000000000000000000000000000
                              OOB: 0000
      [NEW] Device D4:97:69:32:FD:FA Embest_SW_001
      [config: Target = 0100]# provision dd010000000000000000000000000000
      Attempting to disconnect from F4:F8:CD:C2:49:60
      Trying to connect Device D4:97:69:32:FD:FA Embest_SW_001
      Characteristic property changed /org/bluez/hci0/dev_F4_F8_CD_C2_49_60/service000a/char000d
      Adapter property changed
      [CHG] Controller B8:27:EB:29:BA:EF Discovering: no
      Connection successful
      Service added /org/bluez/hci0/dev_D4_97_69_32_FD_FA/service0006
      Service added /org/bluez/hci0/dev_D4_97_69_32_FD_FA/service000a
      Char added /org/bluez/hci0/dev_D4_97_69_32_FD_FA/service000a/char000b:
      Char added /org/bluez/hci0/dev_D4_97_69_32_FD_FA/service000a/char000d:
      Services resolved yes
      Found matching char: path /org/bluez/hci0/dev_D4_97_69_32_FD_FA/service000a/char000b, uuid 00002adb-0000-1000-8000-00805f9b34fb
      Found matching char: path /org/bluez/hci0/dev_D4_97_69_32_FD_FA/service000a/char000d, uuid 00002adc-0000-1000-8000-00805f9b34fb
      Start notification on /org/bluez/hci0/dev_D4_97_69_32_FD_FA/service000a/char000d
      Characteristic property changed /org/bluez/hci0/dev_D4_97_69_32_FD_FA/service000a/char000d
      AcquireNotify success: fd 7 MTU 69
      Notify for Mesh Provisioning Out Data started
      Open-Node: 0xf8d9b0
      Open-Prov: 0xf90ba0
      Open-Prov: proxy 0xf8da20
      GATT-TX:         03 00 10
      Initiated provisioning
      Write closed
      Services resolved no
      Characteristic property changed /org/bluez/hci0/dev_F4_F8_CD_C2_49_60/service000a/char000b
    EOF

    off_response = <<-EOF
      Discovery stopped
      Adapter property changed
      [CHG] Controller B8:27:EB:33:2B:8E Discovering: no
    EOF

    @client.puts on_response
    sleep(10)
    @client.puts off_response
  end

  def provision(uuid)
    response = <<-EOF
      Composition data for node 0100 {
        "cid":"05f1",
        "pid":"0000",
        "vid":"0000",
        "crpl":"000a",
        "features":{
          "relay":true,
          "proxy":true,
          "friend":false,
          "lpn":false
        },
        "elements":[
          {
            "elementIndex":0,
            "location":"0000",
            "models":[
              "0000",
              "1000"
            ]
          }
        ]
      }
    EOF
    @client.puts response
  end

  def info_dev(uuid)
    response = <<-EOF
      Device F4:F8:CD:C2:49:60
              Name: Embest_LT_001
              Alias: Embest_LT_001
              Trusted: no
              Blocked: no
              Connected: yes
              UUID: Generic Access Profile    (00001800-0000-1000-8000-00805f9b34fb)
              UUID: Generic Attribute Profile (00001801-0000-1000-8000-00805f9b34fb)
              UUID: Mesh Proxy                (00001828-0000-1000-8000-00805f9b34fb)
              ServiceDataKey: 00001828-0000-1000-8000-00805f9b34fb
              ServiceData Value: 0x01
              ServiceData Value: 0x9d
              ServiceData Value: 0x86
              ServiceData Value: 0x38
              ServiceData Value: 0xfc
              ServiceData Value: 0x5d
              ServiceData Value: 0x62
              ServiceData Value: 0xa8
              ServiceData Value: 0xd8
              ServiceData Value: 0xbf
              ServiceData Value: 0xe2
              ServiceData Value: 0xee
              ServiceData Value: 0xac
              ServiceData Value: 0xea
              ServiceData Value: 0x75
              ServiceData Value: 0x01
              ServiceData Value: 0xec
    EOF
    @client.puts response
  end

  def appkey_add(app_idx)
    response = <<-EOF
      GATT-TX:         00 f4 df 76 6b 5e 11 26 db 7f a6 aa 7c 02 c3 2b
      GATT-TX:         9a e0 0d 70 4c 93 d8 6b 1a 65 89 0b e3 c4
      GATT-TX:         00 f4 88 14 71 fc f9 dd 70 59 1e 4e 60 2d 73 42
      GATT-TX:         09 67 51 ed ba b3 76 dd 32 aa b0 e5 d6 e4
      GATT-RX:         00 f4 84 5a 7b f6 07 5f 70 55 86 27 56 4d d1 09
      GATT-RX:         6b 32 0b 39 1e 99 22 d0 fe
      GATT-RX:         00 f4 dc f7 84 fe ac 16 eb a8 78 43 8b b2 82 74
      GATT-RX:         04 70 b8 53 21 ef e0 cc 88
      Node 0100 AppKey status Success
      NetKey  000
      AppKey  001
    EOF
    @client.puts response
  end

  def bind(ele_idx, app_idx, mod_id)
    response = <<-EOF
      GATT-TX:         00 f4 bb da 17 c6 75 21 fd 7b cf 52 12 41 89 e7
      GATT-TX:         c4 43 6d ea 2d 79 3d 24 7f aa a2
      GATT-RX:         00 f4 47 ab be 15 be b5 22 a8 00 4b 49 09 4c a0
      GATT-RX:         0b 8f 5e f3 1e 30 07 52 33 34 dc eb
      Node 0100 Model App status Success
      Element Addr    0100
      Model Id        1000
      AppIdx          001
    EOF
    @client.puts response
  end

  def target(unicast_address)
    response = "Configuring node #{unicast_address}"
    @client.puts response
  end

  def pub_set(ele_addr, pub_addr, app_idx, per, re_xmt, mod_id)
    response = <<-EOF
      GATT-TX:         00 f4 29 47 80 03 01 86 25 b0 c7 68 9d 9b fd 5e
      GATT-TX:         bf 0a de 4f 15 1f 71 90 5f 8f 72 5a 1b dc
      GATT-TX:         00 f4 9d d1 6a 00 b9 fe 1a ac 51 36 64 47 f2 95
      GATT-TX:         04 38 4e dd 04 aa
      GATT-RX:         00 f4 bf b1 7b 03 34 d3 ff 17 cd 25 5c 89 c8 70
      GATT-RX:         5a e1 cc 21 a9 63 d9 93 a8
      GATT-RX:         00 f4 95 2b 7d d3 96 05 c0 8d cf c4 15 9e e3 ea
      GATT-RX:         f2 82 9e 2e 6d a0 75 66 34 9e 0d c1 b8 27
      GATT-RX:         00 f4 f3 57 c3 f7 07 79 68 37 dc 56 65 8a e6 a7
      GATT-RX:         bf 24 71 59 8b 7f e5 ca

      Node 0100 Publication status Success
      Element Addr    0100
      Model Id        1000
      Pub Addr        0c00
      Period          0 ms
      Rexmit count    0
      Rexmit steps    0
      GATT-TX:         00 f4 b4 35 1c d1 71 d2 94 46 58 49 05 6f a4 f3
      GATT-TX:         34 4c 99 45 60 92 49 c1 33
    EOF
    @client.puts response
  end

  def sub_add(ele_addr, sub_addr, mod_id)
    response = <<-EOF
      GATT-TX:         00 f4 29 b4 f8 fc 5e 6a 1a ac d1 c6 0f c1 a1 76
      GATT-TX:         9b 08 ff ed 0b b2 65 bf 68 77 23
      GATT-RX:         00 f4 4b 1b 5b f6 dc 10 c0 8d 4f 1b 2b 0e a8 c3
      GATT-RX:         73 e3 3b 0e 9c 09 a2 3c 0c dc aa 99

      Node 0100 Subscription status Success
      Element Addr    0100
      Model Id        1000
      Subscr Addr     ceef
    EOF
    @client.puts response
  end

  def mesh_info
    response = <<-EOF
      {
        "$schema":"file:\/\/\/BlueZ\/Mesh\/schema\/mesh.jsonschema",
        "meshName":"BT Mesh",
        "netKeys":[
          {
            "index":0,
            "keyRefresh":0,
            "key":"18eed9c2a56add85049ffc3c59ad0e12"
          }
        ],
        "appKeys":[
          {
            "index":0,
            "boundNetKey":0,
            "key":"4f68ad85d9f48ac8589df665b6b49b8a"
          },
          {
            "index":1,
            "boundNetKey":0,
            "key":"2aa2a6ded5a0798ceab5787ca3ae39fc"
          }
        ],
        "provisioners":[
          {
            "provisionerName":"BT Mesh Provisioner",
            "unicastAddress":"0077",
            "allocatedUnicastRange":[
              {
                "lowAddress":"0100",
                "highAddress":"7fff"
              }
            ]
          }
        ],
        "nodes":[
          {
            "deviceKey":"37fef1f4ce72e6028c29dae98a1c721e",
            "configuration":{
              "netKeys":[
                "0000"
              ],
              "elements":[
                {
                  "elementIndex":0,
                  "unicastAddress":"0100",
                  "models":[
                    {
                      "modelId":"1000",
                      "publish":{
                        "address":"0c00",
                        "index":"0001",
                        "ttl":255
                      },
                      "bind":[
                        1
                      ],
                      "subscribe":[
                        "ceef"
                      ]
                    }
                  ]
                }
              ],
              "appKeys":[
                "0001"
              ]
            },
            "composition":{
              "cid":"05f1",
              "pid":"0000",
              "vid":"0000",
              "crpl":"000a",
              "features":{
                "relay":true,
                "proxy":true,
                "friend":false,
                "lpn":false
              },
              "elements":[
                {
                  "elementIndex":0,
                  "location":"0000",
                  "models":[
                    "0000",
                    "1000"
                  ]
                }
              ]
            },
            "IVindex":5,
            "sequenceNumber":11
          }
        ],
        "IVindex":5,
        "IVupdate":0
      }

    EOF
    @client.puts response
  end

  def local_info
    response = <<-EOF
      {
        "$schema":"file:\/\/\/BlueZ\/Mesh\/local_schema\/mesh.jsonschema",
        "meshName":"BT Mesh",
        "netKeys":[
          {
            "index":0,
            "keyRefresh":0
          }
        ],
        "appKeys":[
          {
            "index":0,
            "boundNetKey":0
          },
          {
            "index":1,
            "boundNetKey":0
          }
        ],
        "node":{
          "composition":{
            "cid":"0002",
            "pid":"0010",
            "vid":"0001",
            "crpl":"000a",
            "features":{
              "relay":false,
              "proxy":true,
              "friend":false,
              "lowPower":false
            },
            "elements":[
              {
                "elementIndex":0,
                "location":"0001",
                "models":[
                  "0000",
                  "0001",
                  "1001"
                ]
              }
            ]
          },
          "configuration":{
            "netKeys":[
              0
            ],
            "appKeys":[
              0,
              1
            ],
            "defaultTTL":10,
            "elements":[
              {
                "elementIndex":0,
                "unicastAddress":"0077",
                "models":[
                  {
                    "modelId":"1001",
                    "bind":[
                      1
                    ]
                  }
                ]
              }
            ]
          },
          "IVindex":5,
          "IVupdate":0,
          "sequenceNumber":100
        }
      }
    EOF
    @client.puts response
  end

end

MockMeshCtlServer.new(4000)