require 'pdf_thumbnailer'

module Sufia
  module GenericFile
    module Thumbnail
      extend ActiveSupport::Concern
      # Create thumbnail requires that the characterization has already been run (so mime_type, width and height is available)
      # and that the object is already has a pid set
      def create_thumbnail
        return unless self.content.has_content?

        logger.info "CURATE228 call create_thumbnail"
        if video?
          create_video_thumbnail
        elsif pdf?
        logger.info "CURATE228 PDF thumbnail"
          create_pdf_thumbnail
        else
        logger.info "CURATE228 derivative thumbnail"
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

        PdfThumbs.configure img_dir: '/tmp', thumb_sizes: 493

        output_file = Dir::Tmpname.create(['PDFThumbnailer', ".png"], '/tmp'){}

        content.to_tempfile do |f|
          num_pages = PdfThumbs.thumbnail_single! "/tmp", File.basename(f.path)
        end

        self.thumbnail.content = File.open(output_file, 'rb').read
        self.thumbnail.mimeType = 'image/png'
        self.save
      end

    end
  end
end
