class TwilioCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def status

    sid        = params["CallSid"]
    status     = params["CallStatus"]

    record = CallLog.find_by(twilio_sid: sid)
    if record      
      record.status = status
      if status == "completed"
        duration = params["CallDuration"]
        record.duration = duration
      end

      record.save!
    end
    head :ok
  end
end
