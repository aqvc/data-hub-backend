namespace :import do
  desc "Import DB_model_mapped_latest-Final.xlsx into local DB"
  task model_mapped_xlsx: :environment do
    require Rails.root.join("lib/importers/model_mapped_xlsx_importer")

    file_path = ENV["FILE"].presence || Importers::ModelMappedXlsxImporter::DEFAULT_PATH
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV["DRY_RUN"])
    user_id = ENV["USER_ID"].presence

    unless File.exist?(file_path)
      abort("File not found: #{file_path}")
    end

    importer = Importers::ModelMappedXlsxImporter.new(
      file_path: file_path,
      dry_run: dry_run,
      user_id: user_id
    )
    importer.run
  end
end
