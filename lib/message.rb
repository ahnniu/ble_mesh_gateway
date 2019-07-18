class Message

  @@MESSAGES = [
    { opcode: 0x8201, name: "Generic OnOff Get ", model_id: 1001 }
    { opcode: 0x8204, name: "Generic OnOff Status", model_id: 1000 }
  ]

  def self.get_model_id(opcode)
    @@MESSAGES.each do |item|
      return item[:model_id] if item[:opcode] == opcode
    end

    nil
  end

end