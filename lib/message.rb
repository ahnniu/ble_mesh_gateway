class Message

  GenericOnOffGet = 0x8201
  GenericOnOffSet = 0x8202
  GenericOnOffSetUnacknowledged = 0x8203
  GenericOnOffStatus = 0x8204

  @@OPCODES = [
    { model_id: 1001, opcode: GenericOnOffGet },
    { model_id: 1001, opcode: GenericOnOffSet },
    { model_id: 1001, opcode: GenericOnOffSetUnacknowledged },
    { model_id: 1000, opcode: GenericOnOffStatus }
  ]

  def self.get_model_id(opcode)
    @@OPCODES.each do |item|
      return item[:model_id] if item[:opcode] == opcode
    end

    nil
  end

end