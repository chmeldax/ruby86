module Ruby86
  module Loaders
    class MachO
      Header = Struct.new(:cpu_type, :cpu_subtype, :filetype, :ncmds, :sizeofcmds, :flags, :reserved)

      def initialize(file_path)
        @file = File.open(file_path)
      end

      def load!
        check_magic_number
        header = load_header
        sizes = 0
        header.ncmds.times do
          command = read_uint32(1*4).first
          size = read_uint32(1*4).first
          sizes += size
          handle_command(command, read_uint32(size - 8))
        end
      end

      private

      def check_magic_number
        magic_number = @file.read(4).unpack('N')
        raise 'Unsupported architecture' unless magic_number.first == 0xcffaedfe # x64, big_endian
      end

      def load_header
        header_raw = read_uint32(7 * 4)
        Header.new(*header_raw)
      end

      def read_uint32(count)
        @file.read(count).unpack("V#{count/4}")
      end

      def handle_command(command, raw_command)
        case command
        when 0x19 #LC_SEGMENT
          puts 'LC_SEGMENT_64'
        when 0x80000028 #LC_UNIXTHREAD
          puts 'LC_MAIN'
        end
      end
    end
  end
end
