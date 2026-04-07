namespace :import do
  desc "Import unqualified investors XLSX into local DB"
  task unqualified_investors_xlsx: :environment do
    require Rails.root.join("lib/importers/unqualified_investors_xlsx_importer")

    file_path = ENV["FILE"].presence || Importers::UnqualifiedInvestorsXlsxImporter::DEFAULT_PATH
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV["DRY_RUN"])
    user_id = ENV["USER_ID"].presence
    sheet_name = ENV["SHEET"].presence

    unless File.exist?(file_path)
      abort("File not found: #{file_path}")
    end

    importer = Importers::UnqualifiedInvestorsXlsxImporter.new(
      file_path: file_path,
      dry_run: dry_run,
      user_id: user_id,
      sheet_name: sheet_name
    )
    importer.run
  end
end
