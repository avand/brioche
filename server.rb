require "sinatra"
require "google_drive"
require 'twilio-ruby'

TWILIO = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

post "/expenses" do
  to_number   = params["To"]
  from_number = params["From"]

  text  = params["Body"]
  match = text.match(/^(\S*)(.*)/)

  amount      = match[1].to_f
  description = match[2].strip
  date        = Time.now.strftime("%-m/%-d/%Y")

  session     = GoogleDrive.login(ENV["GOOGLE_EMAIL"], ENV["GOOGLE_PASSWORD"])
  spreadsheet = session.spreadsheet_by_key(ENV["SPREADSHEET_KEY"])
  worksheet   = spreadsheet.worksheets[ENV["WORKSHEET_INDEX"].to_i]
  row         = worksheet.num_rows + 1

  worksheet[row, 1] = description
  worksheet[row, 2] = date
  worksheet[row, 3] = amount

  worksheet.save

  confirmation = "Recorded $#{amount} on #{date} for \"#{description}\""

  TWILIO.account.sms.messages.create({
    to:   from_number,
    from: to_number,
    body: confirmation
  }) if to_number && from_number
end
