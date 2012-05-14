require "sinatra"
require "google_drive"

post "/expenses" do
  raise params.inspect

  amount      = params[:amount]
  description = params[:description]
  date        = Time.now.strftime("%-m/%-d/%Y")

  session     = GoogleDrive.login(ENV["GOOGLE_EMAIL"], ENV["GOOGLE_PASSWORD"])
  spreadsheet = session.spreadsheet_by_key("0AkvbHgDD4uKFdGJ0N3RsWHNiaGRnYk5hdlp3ZEZVaWc")
  worksheet   = spreadsheet.worksheets[1]
  row         = worksheet.num_rows + 1

  worksheet[row, 1] = description
  worksheet[row, 2] = date
  worksheet[row, 3] = amount

  worksheet.save

  "Success!"
end
