require "sinatra"
require "google_drive"

post "/expenses" do
  text  = params["Body"]
  match = text.match(/^(\S*)(.*)/)

  amount      = match[1].to_f
  description = match[2].strip
  date        = Time.now.strftime("%-m/%-d/%Y")

  session     = GoogleDrive.login(ENV["GOOGLE_EMAIL"], ENV["GOOGLE_PASSWORD"])
  spreadsheet = session.spreadsheet_by_key("0AkvbHgDD4uKFdGJ0N3RsWHNiaGRnYk5hdlp3ZEZVaWc")
  worksheet   = spreadsheet.worksheets[1]
  row         = worksheet.num_rows + 1

  worksheet[row, 1] = description
  worksheet[row, 2] = date
  worksheet[row, 3] = amount

  worksheet.save

  "Saved $#{amount} on #{date} for #{description}"
end
