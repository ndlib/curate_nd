require 'rmagick'

module Sufia
  module GenericFile
    module Thumbnail
      extend ActiveSupport::Concern
      # Create thumbnail requires that the characterization has already been run (so mime_type, width and height is available)
      # and that the object is already has a pid set
      def create_thumbnail
        return unless self.content.has_content?

        if video?
          create_video_thumbnail
        elsif pdf?
          create_pdf_thumbnail
        else
          create_derivatives
        end
        self.save
      end

      protected
      def create_video_thumbnail
        return unless Sufia.config.enable_ffmpeg
      
        output_file = Dir::Tmpname.create(['sufia', ".png"], Sufia.config.temp_file_base){}
        content.to_tempfile do |f|
          # we could use something like this in order to find a frame in the middle.
          #ffprobe -show_files video.avi 2> /dev/null | grep duration | cut -d= -f2 53.399999  
          command = "#{Sufia.config.ffmpeg_path} -i \"#{f.path}\" -loglevel quiet -vf \"scale=338:-1\"  -r  1  -t  1 #{output_file}"
          system(command)
          raise "Unable to execute command \"#{command}\"" unless $?.success?
        end

        self.thumbnail.content = File.open(output_file, 'rb').read
        self.thumbnail.mimeType = 'image/png'
      end

      def create_pdf_thumbnail

        # Create PDF file  from Active Object
        thumb_filename = nil

        content.to_tempfile do |temp_info|
          pdf_filename = temp_info.path
          thumb_filename = File.join(File.dirname(pdf_filename),File.basename(pdf_filename, ".*") + ".png")
        
          #Create RMagick object from PDF
          # Get and resize First page of PDF
          # Size to 198x288 or 338x493, based on page size
          # Write to Thumbnail FileName
          pdf_first_page = Magick::ImageList.new(pdf_filename + "[0]")
          if pdf_first_page.filesize > 300000
            pdf_thumbnail = pdf_first_page.resize_to_fit(198, 288)
          else
            pdf_thumbnail = pdf_first_page.resize_to_fit(338, 493)
          end

          pdf_thumbnail.write(thumb_filename) { [ self.compression = Magick::ZipCompression, self.depth = 8, self.quality = 0] }
          File.delete(pdf_filename)
        end
        
        #Using new thumbnail, set thumbnail datastream in Active Object
        self.thumbnail.content = File.open(thumb_filename, 'rb').read
        self.thumbnail.mimeType = 'image/png'
        self.save

        #cleanup /tmp
        File.delete(thumb_filename)
      end

    end
  end
end
