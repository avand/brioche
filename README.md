# Brioche

The fun way to slice the bread.

## What is it?

A simple way to enter expenses, mileage, and hours into Google Docs from a text/SMS message.  You can specify "m" or "M" for *mileage* driven, "d" or "D" for *dollars* spent and "h" or "H" for *hours* worked--good for overtime.

For example, if you texted:

* "35d Burgers with the team"
* "44.1m Denver Airport"
* ".75h Project X"

You would end up with this:

<table>
  <tr>
    <th>Item</th>
    <th>Type</th>
    <th>Amount</th>
    <th>Date</th>
    <th>Who</th>
  </tr>
  <tr>
    <td>Burgers with the team</td>
    <td>d</td>
    <td>$35.00</td>
    <td>12/05/2013</td>
    <td>+13035555555</td>
  </tr>
  <tr>
    <td>Denver Airport</td>
    <td>m</td>
    <td>44.1</td>
    <td>12/05/2013</td>
    <td>+13035555555</td>
  </tr>
  <tr>
    <td>Project X</td>
    <td>h</td>
    <td>.75</td>
    <td>12/05/2013</td>
    <td>+13035555555</td>
  </tr>
</table>

You can then use the "m" in Google Docs for mileage reimbursement calculation, etc.


## Setup

1. Push this code up to a Heroku Cedar app.
2. Setup the following env variables (.env if you're using [Foreman][1]):
  * `TWILIO_ACCOUNT_SID`: Available on your Twilio dashboard.
  * `TWILIO_AUTH_TOKEN`: Also available on your Twilio dasboard, Keep this a secret.
  * `SPREADSHEET_KEY`: Grab this from the URL for your Google Sheet.
  * `GDRIVE_AUTH`: Base64 encoded service account json from the [Google Console](https://console.developers.google.com/projectselector2/iam-admin/serviceaccounts?supportedpurview=project&project&folder&organizationId) for your app.
  * `EXP_QUERY`: Your Google Sheets query
  * `SUM_QUERY`: Separate Google Sheets for the total row
  * `AWS_SMTP_USER`: AWS STMP username
  * `AWS_SMTP_PASSWORD`: AWS SMTP password
  * `AWS_SMTP_FROM`: Validated "from" address from AWS SES
  * `SMTP_SUBJECT`: Email subject
  * `SMTP_BODY`: Email body
  * Make sure you don't add these files to your git repo!
2. Register a Twilio number.
3. Point the SMS URL for that number to http://your-app.herokuapp.com/expenses.
4. Send a text to the number in the format: "\<amount\> \<description\>".

[1]: https://devcenter.heroku.com/articles/procfile#developing_locally_with_foreman
