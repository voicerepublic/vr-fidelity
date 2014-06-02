require 'csv'
class CsvDb
  class << self
    def convert_save(model_name, csv_data, default_columns = {})
      csv_file = csv_data.read
      target_model = model_name.classify.constantize
      csv = CSV.parse(csv_file, headers: true, quote_char: '"')
      # validation
      csv.each_with_index do |row, i|
        obj = target_model.new(row.to_hash.merge(default_columns))
        unless obj.valid?
          return { error: "Error in line #{i+1}: #{obj.errors.full_messages.join(';')}" }
        end
      end
      # creation
      csv.each do |row|
        target_model.create!(row.to_hash.merge(default_columns))
      end
      return { success: csv.length }
    end
  end
end
