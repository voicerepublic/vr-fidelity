require 'csv'
class CsvDb
  class << self
    def convert_save(model_name, csv_data)
      csv_file = csv_data.read
      target_model = model_name.classify.constantize
      csv = CSV.parse(csv_file, headers: true, quote_char: '"')
      csv.each do |row|
        target_model.create!(row.to_hash)
      end
      return csv.length
    end
  end
end
