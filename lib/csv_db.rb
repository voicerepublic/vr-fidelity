require 'csv'

module CsvDb

  def import(csv_data, default_columns = {})
    csv_file = csv_data.read
    csv = CSV.parse(csv_file, headers: true, quote_char: '"')
    # validation
    objs, errors = [], []
    csv.each_with_index do |row, i|
      obj = find_or_init_by(uri: row.to_hash[:uri])
      obj.attributes.reverse_merge!(default_columns)
      obj.attributes.merge!(row.to_hash)
      unless obj.valid?
        errors << "Error in line #{i+1}: #{obj.errors.full_messages.join(';')}"
      end
      objs << obj
    end
    return { error: errors * "\n" } unless errors.empty?
    # creation
    objs.each(&:save!)
    return { success: objs.length }
  end

end
