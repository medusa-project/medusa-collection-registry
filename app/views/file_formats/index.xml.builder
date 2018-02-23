xml.instruct!
xml.file_formats do
  @file_formats.each do |file_format|
    xml.file_format do
      xml.name file_format.name
      xml.policy_summary file_format.policy_summary
      if file_format.file_format_profiles.present?
        xml.rendering_profiles do
          file_format.file_format_profiles.each do |profile|
            xml.rendering_profile do
              xml.name profile.name
              xml.status profile.status
              xml.software profile.software
              xml.software_version profile.software_version
              xml.os_environment profile.os_environment
              xml.os_version profile.os_version
              xml.content_types do
                profile.content_types.each do |content_type|
                  xml.content_type content_type.name
                end
              end
              xml.extensions do
                profile.file_extensions.each do |extension|
                  xml.extension extension.extension
                end
              end
            end
          end
        end
      end
      if file_format.pronoms.present?
        xml.pronoms do
          file_format.pronoms.each do |pronom|
            xml.pronom_id pronom.pronom_id
            xml.version pronom.version
          end
        end
      end
      if file_format.file_format_notes.present?
        xml.notes do
          file_format.file_format_notes.each do |note|
            xml.note do
              xml.user note.user.netid
              xml.date note.created_at.to_date
              xml.content note.note
            end
          end
        end
      end
      if file_format.file_format_normalization_paths.present?
        xml.normalization_paths do
          file_format.file_format_normalization_paths.each do |path|
            xml.normalization_path do
              xml.name path.name
              xml.output_format path.output_format
              xml.software path.software
              xml.operating_system path.operating_system
            end
          end
        end
      end
      if file_format.logical_extensions.present?
        xml.logical_extensions do
          file_format.logical_extensions.each do |logical_extension|
            xml.logical_extension do
              xml.extension logical_extension.extension
              if logical_extension.description.present?
                xml.description logical_extension.description
              end
            end
          end
        end
      end
      if file_format.related_file_formats.present?
        xml.related_file_formats do
          file_format.related_file_formats.each do |related_file_format|
            xml.related_file_format do
              xml.name related_file_format.name
            end
          end
        end
      end
    end
  end
end