require 'csv'

module CsvImport

  def import(csv_data, default_columns = {})
    csv_file = csv_data.read
    csv = CSV.parse(csv_file, headers: true, quote_char: '"')
    # validation
    objs, errors = [], {}
    csv.each_with_index do |row, i|
      row_hash = convert_to_hash(row)
      obj = find_or_initialize_by(uri: row_hash['uri'])
      default_columns.each do |col, val|
        obj.send("#{col}=", val) if obj.send(col).blank?
      end
      begin
        obj.attributes = obj.attributes.merge(row_hash)
        errors[i+1] = obj.errors.full_messages unless obj.valid?
        objs << obj
      rescue Exception => e
        return { error: e.message }
      end
    end
    # render error if validation failed
    unless errors.empty?
      return { error: errors }
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

  private

  # Basically it does row.to_hash
  # But: It also strips the keys (sanitizing the input CSV headers)
  def convert_to_hash(row)
    row.to_hash.map { |k, v| { k.strip => v } }.reduce Hash.new, :merge
  end

end
