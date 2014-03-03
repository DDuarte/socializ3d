import sys;
import os;

if sys.version_info[0] == 3:
    os.system("start python -m http.server")
else:
    os.system("start python -m SimpleHTTPServer")
    
os.system("start /max http://localhost:8000")
