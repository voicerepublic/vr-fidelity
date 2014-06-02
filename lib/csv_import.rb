require 'csv'

module CsvImport

  def import(csv_data, default_columns = {})
    csv_file = csv_data.read
    csv = CSV.parse(csv_file, headers: true, quote_char: '"')
    # validation
    objs, errors = [], {}
    csv.each_with_index do |row, i|
      obj = find_or_initialize_by(uri: row.to_hash['uri'])
      default_columns.each do |col, val|
        obj.send("#{col}=", val) if obj.send(col).blank?
      end
      obj.attributes = obj.attributes.merge(row.to_hash)
      errors[i+1] = obj.errors.full_messages unless obj.valid?
      objs << obj
    end
    # render error if validation failed
    unless errors.empty?
      error_text = ''
      errors.each do |line, errs|
        error_text +=
          "Errors in line #{line}: " +
          errs.map { |e| "#{e}. " }.join
      end
      return { error: error_text }
    end
    # render error if check uniqueness of uri fails
    if objs.map(&:uri).uniq.size != objs.size
      return { error: "Import canceled. Uris have to be unique." }
    end
    # creation
    result = { updated: 0, created: 0 }
    objs.map do |obj|
      sym = obj.persisted? ? :updated : :created
      result[sym] += 1
      obj.save!
    end
    return result
  end

end
