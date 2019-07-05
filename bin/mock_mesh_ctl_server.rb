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
        },
        {
          "index":2,
          "boundNetKey":0,
          "key":"6bb4a6ded5a0798ceab5787ca3ae39fc"
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
          "deviceKey":"b15e6966aafeded163d1f28aaa70cf52",
          "configuration":{
            "netKeys":[
              "0000"
            ],
            "elements":[
              {
                "elementIndex":0,
                "unicastAddress":"0100"
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
                  "1001"
                ]
              }
            ]
          },
          "IVindex":5,
          "sequenceNumber":7
        },
        {
          "deviceKey":"7e2cb7c43f5bfe65bf9c922755d4c60d",
          "configuration":{
            "netKeys":[
              "0000"
            ],
            "elements":[
              {
                "elementIndex":0,
                "unicastAddress":"0101"
              }
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
                  "1001"
                ]
              }
            ]
          },
          "IVindex":5,
          "sequenceNumber":3
        },
        {
          "deviceKey":"84b8ac19ecb2ee43278a779a039946a6",
          "configuration":{
            "netKeys":[
              "0000"
            ],
            "elements":[
              {
                "elementIndex":0,
                "unicastAddress":"0102",
                "models":[
                  {
                    "modelId":"1001",
                    "bind":[
                      1
                    ],
                    "publish":{
                      "address":"ceef",
                      "index":"0001",
                      "ttl":255
                    }
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
                  "1001"
                ]
              }
            ]
          },
          "IVindex":5,
          "sequenceNumber":20
        },
        {
          "deviceKey":"783642b08feaa0eea8366c8a30430156",
          "configuration":{
            "netKeys":[
              "0000"
            ],
            "elements":[
              {
                "elementIndex":0,
                "unicastAddress":"0103",
                "models":[
                  {
                    "modelId":"1001",
                    "bind":[
                      2
                    ],
                    "publish":{
                      "address":"ceef",
                      "index":"0002",
                      "ttl":255
                    }
                  }
                ]
              }
            ],
            "appKeys":[
              "0002"
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
                  "1001"
                ]
              }
            ]
          },
          "IVindex":5,
          "sequenceNumber":14
        },
        {
          "deviceKey":"0832e764c48c7b8e82fbf36de14837ab",
          "configuration":{
            "netKeys":[
              "0000"
            ],
            "elements":[
              {
                "elementIndex":0,
                "unicastAddress":"0104",
                "models":[
                  {
                    "modelId":"1001",
                    "bind":[
                      1
                    ],
                    "publish":{
                      "address":"ceef",
                      "index":"0001",
                      "ttl":255
                    }
                  }
                ]
              }
            ],
            "appKeys":[
              "0001"
            ],
            "defaultTTL":7
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
                  "1001"
                ]
              }
            ]
          },
          "IVindex":5,
          "sequenceNumber":17
        },
        {
          "deviceKey":"8e25ed49c8c897950c6dc86a30fe0f48",
          "configuration":{
            "netKeys":[
              "0000"
            ],
            "elements":[
              {
                "elementIndex":0,
                "unicastAddress":"0105"
              }
            ]
          }
        },
        {
          "deviceKey":"35c850de797ff758028812392b9382ae",
          "configuration":{
            "netKeys":[
              "0000"
            ],
            "elements":[
              {
                "elementIndex":0,
                "unicastAddress":"0106",
                "models":[
                  {
                    "modelId":"1001",
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
                  "1001"
                ]
              }
            ]
          },
          "IVindex":5,
          "sequenceNumber":12
        }
      ],
      "IVindex":5,
      "IVupdate":0
    }

    EOF

    @client.puts response
  end
end

MockMeshCtlServer.new(5678)