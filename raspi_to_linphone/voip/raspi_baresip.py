import threading
from baresipy import BareSIP
from time import sleep
from baresipy.utils.log import LOG

class RaspiBaresip(BareSIP):

    def __init__(self, user, pwd, gateway, allowed_callers, event_queue, **kwargs):

        # Make sure we have allowed callers.
        self.event_queue = event_queue
        self.whitelist = set()
        if allowed_callers:
         self.whitelist = set(i.strip().lower() for i in allowed_callers.split(",") if i)
        super().__init__(user, pwd, gateway, **kwargs)
        print(self.whitelist)


    # Adjust baresip function ot handle incoming calls using Raspberry Pi.
    def handle_incoming_call(self, number):
        LOG.info("Incoming CALL: " + number)
        if self.call_established:
            LOG.info("already in a call, rejecting")
            sleep(0.1)
            self.do_command("b")
        else:
            # Check if the caller is in our allowed contact list.
            print(self.whitelist)
            if number.lower() in self.whitelist:
                LOG.info("trying to establishing call: " + number)
                caller_name = number
                if number.startswith("sip:"):
                    sip_uri = number[4:]  # remove "sip:"
                    caller_name = sip_uri.split("@")[0]
                    self.event_queue.put(caller_name)














