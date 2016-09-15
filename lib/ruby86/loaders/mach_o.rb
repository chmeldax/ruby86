module Ruby86
  module Loaders
    class MachO
      attr_reader :file, :segments

      Header = Struct.new(:cpu_type, :cpu_subtype, :filetype, :ncmds, :sizeofcmds, :flags, :reserved)
      Segment = Struct.new(:name, :vm_address, :vm_size, :file_offset, :file_size)

      def initialize(file_path, memory)
        @file = File.open(file_path, 'rb')
        @memory = memory
        @segments = []
      end

      def load!
        check_magic_number
        header = load_header
        header.ncmds.times do
          command = read_uint32
          size = read_uint32
          handle_command(command, size)
        end
        load_segments!
      end

      private

      def check_magic_number
        magic_number = read_uint32
        raise 'Unsupported architecture' unless magic_number == 0xfeedfacf # x64, little_endian
      end

      def load_header
        header_raw = file.read(7 * 4).unpack('L7')
        Header.new(*header_raw)
      end

      def read_uint32
        file.read(4).unpack('L').first
      end

      def read_uint64
        file.read(8).unpack('Q').first
      end

      def read_char
        file.read(1).unpack('C').first.chr
      end

      def handle_command(command, size)
        case command
        when 0x19 # LC_SEGMENT_64
          handle_segment(size)
        when 0x80000028 # LC_MAIN
          # FIXME
        else
          # noop
        end
      end

      def handle_segment(size)
        name = ''
        16.times { name += read_char }
        vm_address = read_uint64
        vm_size = read_uint64
        file_offset = read_uint64
        file_size =  read_uint64
        @file.read(size - (2*4 + 16 +  4*8))

        segments << Segment.new(name, vm_address, vm_size, file_offset, file_size)
      end

      def load_segments!
        segments.each do |segment|
          segment.file_size.times do |i|
            @memory[segment.vm_address + i] = @file.read(1)
          end
        end
      end
    end
  end
end
