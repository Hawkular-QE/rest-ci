import yaml
import os
import sys
import tempfile

if not os.getenv("APP_LABEL"):
  print "No APP_LABEL defined.  Did you forget to load env file?"
  sys.exit(1)

with open('service1.yaml', 'r') as f:
    doc = yaml.load(f)

app=os.getenv("APP_NAME")
env=os.getenv("APP_ENV")

metadata=doc["metadata"]
metadata["labels"]["name"]=app
metadata["labels"]["env"]=env
metadata["name"]=os.getenv("SERVICE_NAME")


spec = doc["spec"]
spec["ports"][0]["nodePort"]=int(os.getenv("EXT_PORT"))
spec["selector"]["name"]=app
spec["selector"]["env"]=env

print yaml.dump(doc, default_flow_style=False) 

#svcFile = tempfile.NamedTemporaryFile(delete=False)
#svcFile.write(yaml.dump(doc, default_flow_style=False))
#svcFile.close()


sys.exit(0)
