from baresipy import BareSIP
from time import sleep
from baresipy.utils.log import LOG
import os

class RaspiBaresip(BareSIP):

    def __init__(self, user, pwd, gateway, allowed_callers, event_queue, **kwargs):

        # Make sure we have allowed callers.
        self.event_queue = event_queue
        self.whitelist = set()
        if allowed_callers:
            self.whitelist = set(i.strip().lower() for i in allowed_callers.split(",") if i)
        super().__init__(user, pwd, gateway, **kwargs)

    # Adjust baresip function ot handle incoming calls using Raspberry Pi.
    def handle_incoming_call(self, number):

        # Play own ringtone.
        base_dir = os.path.dirname(os.path.abspath(__file__))
        ringtone_path = os.path.abspath(os.path.join(base_dir, '../ringtones/ringbell_kompressor.wav'))
        self.play(ringtone_path, blocking=False)

        LOG.info("Incoming CALL: " + number)
        if self.call_established:
            LOG.info("already in a call, rejecting")
            sleep(0.1)
            self.do_command("b")
        else:
            # Only allow callers from allowed contact list.
            if number.lower() in self.whitelist:
                LOG.info("trying to establishing call: " + number)
                caller_name = number
                if number.startswith("sip:"):
                    sip_uri = number[4:]  # remove "sip:"
                    caller_name = sip_uri.split("@")[0]
                self.event_queue.put({"event": "incoming_call", "caller": caller_name})
            else:
                self.hang()

    def handle_call_ended(self, reason):
        super().handle_call_ended("")
        self.event_queue.put({"event": "end_call"})
