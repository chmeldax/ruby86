module Ruby86
  module Loaders
    class MachO
      attr_reader :file, :segments

      Header = Struct.new(:cpu_type, :cpu_subtype, :filetype, :ncmds, :sizeofcmds, :flags, :reserved)
      Segment = Struct.new(:name, :vm_address, :vm_size, :file_offset, :file_size)
      EntryPoint = Struct.new(:entryoff, :stacksize)

      def initialize(file_path, memory)
        @file = File.open(file_path, 'rb')
        @memory = memory
        @entry_point = nil
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
        run!
      end

      # FIXME: Move out of this class
      def run!
        puts @app_address
        puts @memory[@app_address + @entry_point.entryoff/4]
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

      def read_uint8
        file.read(1).unpack('C').first
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
        when  0x80000028 # LC_MAIN
          handle_main
        else
          @file.read(size - (2*4))
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
        @app_address = vm_address if name.strip == '__DATA' # FIXME

        segments << Segment.new(name, vm_address, vm_size, file_offset, file_size)
      end

      def handle_main
        entryoff = read_uint64
        puts entryoff
        stacksize = read_uint64
        @entry_point = EntryPoint.new(entryoff, stacksize)
      end

      def load_segments!
        segments.each do |segment|
          (segment.file_size / 4).times do |i|
            @memory[segment.vm_address + i] = read_uint8 # FIXME
          end
        end
      end
    end
  end
end
