from obspy.clients.iris import Client
from obspy import UTCDateTime
client = Client()
dt = UTCDateTime("2015-10-01T06:30:00.000")
data = client.resp("7Z", "ALMA", "00", "BHZ", dt)

print(data.decode())  
