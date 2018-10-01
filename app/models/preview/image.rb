module Preview
  class Image < Base

    delegate :image_server_config, to: :class

    def view_partial
      'preview_viewer_iiif_image'
    end

    def is_iiif_compatible?
      return false if image_server_config[:disabled].present?
      result = Net::HTTP.get_response(URI.parse(iiif_info_json_url))
      result.code == '200' && result.body.index('http://iiif.io/api/image/2/level2.json')
    rescue Exception => e
      Rails.logger.error "Problem determining iiif compatibility for cfs file: #{cfs_file.id}.\n #{e}."
      return false
    end

    def self.image_server_config
      @image_server_config = Settings.iiif.to_h
    end

    def iiif_url(iiif_parameters, format)
      "#{iiif_base_url}/#{iiif_parameters}.#{format}"
    end

    def iiif_info_json_url
      "#{iiif_base_url}/info.json"
    end

    def iiif_base_url
      image_server_base_url = "http://#{iiif_host}:#{iiif_port}/#{image_server_config[:root]}"
      "#{image_server_base_url}/#{CGI.escape(cfs_file.relative_path)}"
    end

    def iiif_host
      image_server_config[:host] || 'localhost'
    end

    def iiif_port
      image_server_config[:port] || 3000
    end

    #The IIIF server returns @id in the JSON with _its_ url information, but for seadragon to work properly
    #proxying through this app we need it to refer back to our medusa URL. This fixes that.
    def fix_json_id(json)
      parsed_json = JSON.parse(json)
      parsed_json['@id'] = "/cfs_files/#{cfs_file.id}/preview_iiif_image"
      parsed_json.to_json
    end

    def iiif_image_response_info(params)
      Hash.new.tap do |h|
        if params[:iiif_parameters] == 'info' and params[:format] == 'json'
          h[:response_type] = 'application/json'
          json = Net::HTTP.get(URI.parse(iiif_info_json_url))
          h[:data] = fix_json_id(json)
        else
          h[:response_type] = 'image/jpeg'
          h[:data] = Net::HTTP.get(URI.parse(iiif_url(params[:iiif_parameters], params[:format])))
        end
      end
    end

    def thumbnail_data
        iiif_thumbnail_data
    end

    def iiif_thumbnail_data
      Net::HTTP.get(URI.parse(iiif_url("full/!#{Settings.cfs_file_viewers.thumbnail_size},#{Settings.cfs_file_viewers.thumbnail_size}/0/default", 'jpg')))
    end

  end
end